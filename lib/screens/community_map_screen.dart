import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CommunityMapScreen extends StatefulWidget {
  const CommunityMapScreen({Key? key}) : super(key: key);

  @override
  State<CommunityMapScreen> createState() => _CommunityMapScreenState();
}

class _CommunityMapScreenState extends State<CommunityMapScreen> {
  GoogleMapController? mapController;
  Position? _currentPosition;
  Set<Marker> _placeMarkers = {};
  LatLng? _pendingPoint;
  bool _isLoading = true;

  static const List<String> _ratingEmoji = ['🟢', '🟡', '🔴'];
  static const List<String> _ratingLabels = [
    'Clear tags, easy to navigate',
    'A bit busy, manageable',
    'Confusing math, high stress',
  ];

  @override
  void initState() {
    super.initState();
    _initializeMapData();
  }

  Future<void> _initializeMapData() async {
    await _determinePosition();
    await _loadCommunityLocations();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable device location services.')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions were denied.')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are permanently denied in device settings.')),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }

      if (mapController != null && _currentPosition != null) {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              zoom: 14.0,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }

  Future<void> _loadCommunityLocations() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('community_locations').get();
      final Set<Marker> fetchedMarkers = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final double lat = (data['latitude'] as num?)?.toDouble() ?? 0.0;
        final double lng = (data['longitude'] as num?)?.toDouble() ?? 0.0;
        final String name = data['name'] ?? 'Unknown Location';
        final String desc = data['description'] ?? '';

        if (lat != 0.0 && lng != 0.0) {
          fetchedMarkers.add(
            Marker(
              markerId: MarkerId('place_${doc.id}'),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(title: name, snippet: desc),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _placeMarkers = fetchedMarkers;
        });
      }
    } catch (e) {
      debugPrint("Error loading map markers: $e");
    }
  }

  double _hueFor(int rating) {
    if (rating <= 1) return BitmapDescriptor.hueGreen;
    if (rating == 2) return BitmapDescriptor.hueOrange;
    return BitmapDescriptor.hueRed;
  }

  Set<Marker> _buildRatingMarkers(List<QueryDocumentSnapshot> docs) {
    final Map<String, _StoreRatings> stores = {};

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final lat = (data['latitude'] as num?)?.toDouble();
      final lng = (data['longitude'] as num?)?.toDouble();
      final rating = (data['rating'] as num?)?.toInt();
      if (lat == null || lng == null || rating == null) continue;

      final rawName = (data['storeName'] as String?)?.trim() ?? '';
      final name = rawName.isEmpty ? 'Unnamed store' : rawName;
      final key = '${name.toLowerCase()}_${lat.toStringAsFixed(2)}_${lng.toStringAsFixed(2)}';

      stores.putIfAbsent(key, () => _StoreRatings(name)).add(lat, lng, rating);
    }

    return stores.entries.map((entry) {
      final store = entry.value;
      final rating = store.averageRating;
      final countText = store.count == 1 ? '1 rating' : '${store.count} ratings';

      return Marker(
        markerId: MarkerId('rating_${entry.key}'),
        position: LatLng(store.lat, store.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(_hueFor(rating)),
        infoWindow: InfoWindow(
          title: store.name,
          snippet: '${_ratingEmoji[rating - 1]} ${_ratingLabels[rating - 1]} · $countText',
        ),
      );
    }).toSet();
  }

  Future<void> _onMapLongPress(LatLng point) async {
    setState(() => _pendingPoint = point);

    final nameController = TextEditingController();
    String? errorText;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void submit(int rating) {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                setSheetState(() => errorText = "Enter the store name first.");
                return;
              }
              Navigator.pop(sheetContext);
              _submitRemoteRating(point, name, rating);
            }

            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Rate a store",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "The pin will go where you pressed on the map.",
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: "Store name",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.storefront),
                      ),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 8),
                      Text(errorText!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 16),
                    _ratingButton("🟢", "Clear tags, easy to navigate", () => submit(1)),
                    const SizedBox(height: 10),
                    _ratingButton("🟡", "A bit busy, manageable", () => submit(2)),
                    const SizedBox(height: 10),
                    _ratingButton("🔴", "Confusing math, high stress", () => submit(3)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (mounted) setState(() => _pendingPoint = null);
  }

  Widget _ratingButton(String emoji, String title, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black87,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRemoteRating(LatLng point, String name, int rating) async {
    try {
      await FirebaseFirestore.instance.collection('cognitive_ratings').add({
        'storeName': name,
        'latitude': point.latitude,
        'longitude': point.longitude,
        'rating': rating,
        'ratedRemotely': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thanks! $name has been added to the map.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save your rating: $e')),
        );
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_currentPosition != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 14.0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialTarget = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : const LatLng(37.7749, -122.4194);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Safe Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _determinePosition,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('cognitive_ratings').snapshots(),
              builder: (context, snapshot) {
                final Set<Marker> ratingMarkers = snapshot.hasData
                    ? _buildRatingMarkers(snapshot.data!.docs)
                    : <Marker>{};

                final Set<Marker> pendingMarker = _pendingPoint == null
                    ? <Marker>{}
                    : {
                        Marker(
                          markerId: const MarkerId('pending_rating'),
                          position: _pendingPoint!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
                        ),
                      };

                return Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: _onMapCreated,
                      onLongPress: _onMapLongPress,
                      initialCameraPosition: CameraPosition(
                        target: initialTarget,
                        zoom: 14.0,
                      ),
                      myLocationEnabled: _currentPosition != null,
                      myLocationButtonEnabled: false,
                      markers: {..._placeMarkers, ...ratingMarkers, ...pendingMarker},
                    ),
                    if (snapshot.hasError)
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Couldn't load store ratings: ${snapshot.error}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.touch_app_outlined, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Not at the store? Press and hold the map where it is to rate it.",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _StoreRatings {
  final String name;
  double latSum = 0;
  double lngSum = 0;
  int ratingSum = 0;
  int count = 0;

  _StoreRatings(this.name);

  void add(double lat, double lng, int rating) {
    latSum += lat;
    lngSum += lng;
    ratingSum += rating;
    count++;
  }

  double get lat => latSum / count;
  double get lng => lngSum / count;
  int get averageRating => (ratingSum / count).round().clamp(1, 3).toInt();
}
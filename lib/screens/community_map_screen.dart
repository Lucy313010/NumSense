import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class CommunityMapScreen extends StatefulWidget {
  const CommunityMapScreen({super.key});

  @override
  State<CommunityMapScreen> createState() => _CommunityMapScreenState();
}

class _CommunityMapScreenState extends State<CommunityMapScreen> {
  LatLng? _currentLocation;
  bool _isLoadingLocation = true;
  String _locationError = '';
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = "Location permission denied.";
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = "Location permissions are permanently denied.";
          _isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = "Error getting location: $e";
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _centerOnUser() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 14.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cognitive Comfort Map"),
        centerTitle: true,
      ),
      body: _isLoadingLocation
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Finding your location..."),
                ],
              ),
            )
          : _locationError.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      _locationError,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                )
              : Stack(
                  children: [

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('cognitive_ratings')
                          .snapshots(),
                      builder: (context, snapshot) {

                        List<Marker> allMarkers = [];


                        if (_currentLocation != null) {
                          allMarkers.add(
                            Marker(
                              point: _currentLocation!,
                              width: 60,
                              height: 60,
                              child: const Column(
                                children: [
                                  Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
                                  Text("You", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          );
                        }

         
                        if (snapshot.hasData) {
                          final storeMarkers = snapshot.data!.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final lat = data['latitude'] as double;
                            final lng = data['longitude'] as double;
                            final rating = data['rating'] as int; 

                            Color markerColor = Colors.grey;
                            if (rating == 1) markerColor = Colors.green;
                            if (rating == 2) markerColor = Colors.orangeAccent;
                            if (rating == 3) markerColor = Colors.redAccent;

                            return Marker(
                              point: LatLng(lat, lng),
                              width: 40,
                              height: 40,
                              child: GestureDetector(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Store Rating: ${rating == 1 ? "Calm & Clear" : rating == 2 ? "Moderate" : "Overwhelming"}')),
                                  );
                                },
                                child: Icon(Icons.location_on, color: markerColor, size: 40),
                              ),
                            );
                          }).toList();
                          
                          allMarkers.addAll(storeMarkers);
                        }

                        return FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _currentLocation ?? const LatLng(0, 0),
                            initialZoom: 14.0, 
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.dyscalculia.numsense',
                            ),
                            MarkerLayer(markers: allMarkers),
                          ],
                        );
                      },
                    ),

                    Positioned(
                      bottom: 30,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _LegendItem(color: Colors.green, label: "Calm"),
                            _LegendItem(color: Colors.orangeAccent, label: "Moderate"),
                            _LegendItem(color: Colors.redAccent, label: "Busy"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

      floatingActionButton: _isLoadingLocation || _locationError.isNotEmpty
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              onPressed: _centerOnUser,
              child: const Icon(Icons.my_location),
            ),
    );
  }
}


class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.location_on, color: color, size: 24),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
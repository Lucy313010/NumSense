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
  Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMapData();
  }

  Future<void> _initializeMapData() async {
    await _determinePosition();
    await _loadCommunityLocations();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied.');
      return;
    } 

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
    
  
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
  }

  Future<void> _loadCommunityLocations() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('community_locations').get();
      final Set<Marker> fetchedMarkers = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final double lat = data['latitude'] ?? 0.0;
        final double lng = data['longitude'] ?? 0.0;
        final String name = data['name'] ?? 'Unknown Location';
        final String desc = data['description'] ?? '';

        fetchedMarkers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: name,
              snippet: desc,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        );
      }

      setState(() {
        _markers = fetchedMarkers;
      });
    } catch (e) {
      debugPrint("Error loading map markers: $e");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    // Default fallback coordinate if location isn't fetched yet
    final initialTarget = _currentPosition != null 
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : const LatLng(37.7749, -122.4194); // Fallback: San Francisco

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Safe Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _determinePosition,
          )
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: initialTarget,
                zoom: 14.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false, 
              markers: _markers,
            ),
    );
  }
}
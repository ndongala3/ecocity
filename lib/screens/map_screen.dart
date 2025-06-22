import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../widgets/custom_search_bar.dart';
import 'add_report_screen.dart';


class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = LatLng(0.0, 0.0);
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _markers.add(
          Marker(
            markerId: MarkerId('current'),
            position: _currentPosition,
            infoWindow: InfoWindow(title: 'Ma position'),
          ),
        );
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition, 16),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onAddPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddReportScreen()),
    );
  }

  Widget _buildSearchBar() {
    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12),
        ),
        onChanged: (value) {
          // Implémente la recherche si nécessaire
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: CustomSearchBar(
              onChanged: (value) {
                // logiques de recherche ici
                void _initLocation() async {
                  final position = await LocationService.determinePosition();

                  if (position != null) {
                    setState(() {
                      _currentPosition = LatLng(position.latitude, position.longitude);
                      _markers.add(
                        Marker(
                          markerId: MarkerId('current'),
                          position: _currentPosition,
                          infoWindow: InfoWindow(title: 'Ma position'),
                          icon: BitmapDescriptor.defaultMarkerWithHue(210), // gris bleuté
                        ),
                      );
                    });
                  }
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddPressed,
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: Icon(Icons.home), onPressed: () {}),
            SizedBox(width: 48),
            IconButton(icon: Icon(Icons.settings), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
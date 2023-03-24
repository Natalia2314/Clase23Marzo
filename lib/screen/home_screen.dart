import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapapp/constantes/app_constants.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MapController _mapController = MapController();
  LatLng _currentLocation = LatLng(0, 0);
  bool _isLoading = true;

  void _manageZoom(int zoom) {
    final newZoom = _mapController.zoom + zoom;
    final newCenter = _mapController.center;
    _mapController.move(newCenter, newZoom);
  }

  Future<void> _location() async {
    Location location = new Location();
    PermissionStatus _permissionGranted;
    LocationData ? _locationData;

    bool servicioActivo = await location.serviceEnabled();

    if (!servicioActivo) {
      servicioActivo = await location.requestService();
      if (!servicioActivo) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    var currentLocation = await location.getLocation();
    setState(() {
      _currentLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      _isLoading = false;
    });
    print('*****Ubicación: ${currentLocation}');
  }

  @override
  Widget build(BuildContext context) {
    _location();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(150, 72, 5, 110),
          title: const Text('Mapbox'),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                        minZoom: 1,
                        maxZoom: 30,
                        zoom: 13,
                        center: _currentLocation
                        //center:
                        ),
                    children: [
                      TileLayer(
                        urlTemplate: AppConstants.urlTemplate,
                        additionalOptions: {
                          'mapStyleId': AppConstants.mapStyleId,
                          'accesToken': AppConstants.accesToken,
                        },
                      )
                    ],
                  ),
                  Positioned(
                    bottom: 15,
                    right: 8,
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            _manageZoom(1);
                          },
                          icon: Icon(Icons.zoom_in),
                        ),
                        IconButton(
                          onPressed: () {
                            _manageZoom(-1);
                          },
                          icon: Icon(Icons.zoom_out),
                        ),
                      ],
                    )
                  )
                ],
              ),
    );
  }
}
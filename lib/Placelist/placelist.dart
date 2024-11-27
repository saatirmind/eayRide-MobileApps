import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Placelist extends StatefulWidget {
  const Placelist({super.key});

  @override
  State<Placelist> createState() => _PlacelistState();
}

class _PlacelistState extends State<Placelist> {
  final List<String> _places = [
    "Batu Caves",
    "Bukit Bintang Walk",
    "Ceylonz Suites, Persiaran Raja Chulan",
    "Scarletz Suites, Jalan Yap Kwan Seng",
    "Central Market",
    "The Colony by Infinitum, Chow Kit",
    "The Mansion, Brickfields",
    "Thean Hou Temple, Persiaran Endah"
  ];

  final List<LatLng> _locations = [
    LatLng(3.235014, 101.683455),
    LatLng(3.1460887463338447, 101.71770362698292),
    LatLng(3.150236, 101.705465),
    LatLng(3.159932, 101.712492),
    LatLng(3.142896, 101.695771),
    LatLng(3.162606, 101.695721),
    LatLng(3.134852, 101.685504),
    LatLng(3.121977, 101.687094),
  ];

  late GoogleMapController _mapController;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  LatLng? _selectedStartLocation;
  LatLng? _selectedEndLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _createMarkers();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.requestPermission();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    setState(() {});
  }

  void _createMarkers() {
    _markers = _locations.asMap().entries.map((entry) {
      int index = entry.key;
      LatLng location = entry.value;
      return Marker(
        markerId: MarkerId(_places[index]),
        position: location,
        infoWindow: InfoWindow(
          title: _places[index],
          snippet: "Click to select",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    }).toSet();
  }

  Future<void> _createPolylines() async {
    if (_selectedStartLocation != null && _selectedEndLocation != null) {
      final start = _selectedStartLocation!;
      final end = _selectedEndLocation!;

      final route = await _getRoute(start, end);
      if (route != null) {
        setState(() {
          _polylines.add(Polyline(
            polylineId: PolylineId("route"),
            color: Colors.blue,
            width: 5,
            points: route,
            jointType: JointType.round,
          ));
        });

        _mapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(
                  start.latitude < end.latitude ? start.latitude : end.latitude,
                  start.longitude < end.longitude
                      ? start.longitude
                      : end.longitude),
              northeast: LatLng(
                  start.latitude > end.latitude ? start.latitude : end.latitude,
                  start.longitude > end.longitude
                      ? start.longitude
                      : end.longitude),
            ),
            50,
          ),
        );
      }
    }
  }

  List<LatLng> _decodePoly(String encoded) {
    List<LatLng> polylinePoints = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index) - 63;
        index++;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polylinePoints.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polylinePoints;
  }

  void _onTileTap(int index) {
    if (_selectedStartLocation == null) {
      setState(() {
        _selectedStartLocation = _locations[index];
      });
    } else if (_selectedEndLocation == null) {
      setState(() {
        _selectedEndLocation = _locations[index];
      });

      _createPolylines();
    } else {
      setState(() {
        _selectedStartLocation = _locations[index];
        _selectedEndLocation = null;
        _polylines.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start to Ride'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(3.1460887463338447, 101.71770362698292),
                zoom: 10.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _markers,
              polylines: _polylines,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Please first select your starting point, then select your destination point.',
              textAlign: TextAlign.center,
              textWidthBasis: TextWidthBasis.parent,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _places.length,
              itemBuilder: (context, index) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[200],
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      _places[index],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text("Tap to select"),
                    trailing: Icon(
                      Icons.location_on,
                      color: _selectedStartLocation == _locations[index] ||
                              _selectedEndLocation == _locations[index]
                          ? Colors.green
                          : Colors.red,
                    ),
                    onTap: () => _onTileTap(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ignore_for_file: file_names, deprecated_member_use, avoid_print
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';

class PlacelistWaze extends StatefulWidget {
  const PlacelistWaze({super.key});

  @override
  State<PlacelistWaze> createState() => _PlacelistWazeState();
}

class _PlacelistWazeState extends State<PlacelistWaze> {
  LatLng? startLocation;
  LatLng? endLocation;

  @override
  void initState() {
    super.initState();
    _launchMapOnStart();
  }

  Future<LatLng?> getStartLocationFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble('start_latitude');
    final longitude = prefs.getDouble('start_longitude');
    return (latitude != null && longitude != null)
        ? LatLng(latitude, longitude)
        : null;
  }

  Future<LatLng?> getEndLocationFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble('end_latitude');
    final longitude = prefs.getDouble('end_longitude');
    return (latitude != null && longitude != null)
        ? LatLng(latitude, longitude)
        : null;
  }

  void openMap(LatLng startLocation, LatLng endLocation) async {
    final startLat = startLocation.latitude;
    final startLng = startLocation.longitude;
    final endLat = endLocation.latitude;
    final endLng = endLocation.longitude;

    final wazeUrl =
        'https://waze.com/ul?ll=$startLat,$startLng&navigate=yes&zoom=16&daddr=$endLat,$endLng';

    if (await canLaunch(wazeUrl)) {
      await launch(wazeUrl);
    } else {
      throw 'Could not open Waze';
    }
  }

  Future<void> _launchMapOnStart() async {
    startLocation = await getStartLocationFromSharedPreferences();
    endLocation = await getEndLocationFromSharedPreferences();

    if (startLocation != null && endLocation != null) {
      openMap(startLocation!, endLocation!);
    } else {
      print("Start or End Location is null!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Launching Waze...",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';

class Placelist2 extends StatefulWidget {
  const Placelist2({super.key});

  @override
  State<Placelist2> createState() => _Placelist2State();
}

class _Placelist2State extends State<Placelist2> {
  LatLng? startLocation;
  LatLng? endLocation;

  @override
  void initState() {
    super.initState();
    _launchMapOnStart();
  }

  Future<LatLng?> getStartLocationFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble('pickup_latitude');
    final longitude = prefs.getDouble('pickup_longitude');
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

    final googleMapsUrl =
        'comgooglemaps://?saddr=$startLat,$startLng&daddr=$endLat,$endLng&directionsmode=driving';

    final fallbackUrl =
        'https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$endLat,$endLng&travelmode=driving&dir_action=navigate';

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else if (await canLaunch(fallbackUrl)) {
      await launch(fallbackUrl);
    } else {
      throw 'Could not open the map.';
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
          "Launching Map...",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

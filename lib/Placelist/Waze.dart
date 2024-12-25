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

  @override
  void initState() {
    super.initState();
    _launchWazeOnStart();
  }

  Future<LatLng?> getStartLocationFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble('start_latitude');
    final longitude = prefs.getDouble('start_longitude');
    return (latitude != null && longitude != null)
        ? LatLng(latitude, longitude)
        : null;
  }

  void openWaze(LatLng startLocation) async {
    final latitude = startLocation.latitude;
    final longitude = startLocation.longitude;

    final wazeUrl = 'waze://?ll=$latitude,$longitude&navigate=yes';
    final googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&origin=$latitude,$longitude&destination=$latitude,$longitude&travelmode=driving';

    if (await canLaunch(wazeUrl)) {
      await launch(wazeUrl);
    } else {
      if (await canLaunch(googleMapsUrl)) {
        await launch(googleMapsUrl);
      } else {
        throw 'Could not open Waze or Google Maps.';
      }
    }
  }

  Future<void> _launchWazeOnStart() async {
    startLocation = await getStartLocationFromSharedPreferences();

    if (startLocation != null) {
      openWaze(startLocation!);
    } else {
      print("Start Location is null!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Launching Waze...",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

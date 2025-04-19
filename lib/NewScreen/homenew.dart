// ignore_for_file: use_build_context_synchronously, avoid_print
import 'dart:convert';
import 'package:easymotorbike/NewScreen/detail.dart';
import 'package:http/http.dart' as http;
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/DrawerWidget/Logoutfunction.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homenew extends StatefulWidget {
  const Homenew({super.key});

  @override
  State<Homenew> createState() => _HomenewState();
}

class _HomenewState extends State<Homenew> {
  late GoogleMapController mapController;

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    fetchVehicleLocations();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 2.0,
            ),
            markers: _markers,
            myLocationEnabled: false,
            compassEnabled: false,
          ),
          Positioned(
            top: 0,
            left: -10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: true,
                        onChanged: (bool? value) {},
                        activeColor: Colors.green,
                      ),
                      const Text(
                        'Parked Vehicle',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: true,
                        onChanged: (bool? value) {},
                        activeColor: Colors.red,
                      ),
                      const Text(
                        'Current Vehicle',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: true,
                        onChanged: (bool? value) {},
                        activeColor: Colors.blue,
                      ),
                      const Text(
                        'Parked Area',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 350,
            right: -20,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Builder(
                  builder: (BuildContext context) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DetailScreen(),
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 30,
                        backgroundColor: EasyrideColors.buttonColor,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 25,
            left: -25,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor:
                                EasyrideColors.Drawerheaderbackground,
                            title: const Center(
                              child: Icon(
                                Icons.logout,
                                size: 64,
                                color: Colors.red,
                              ),
                            ),
                            content: const Text(
                              'Are you sure you want to log out?',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            actionsAlignment: MainAxisAlignment.spaceEvenly,
                            actions: <Widget>[
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'No',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () {
                                    logout(context);
                                  },
                                  child: const Text(
                                    'Yes',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        });
                  },
                  child: const CircleAvatar(
                    radius: 30,
                    backgroundColor: EasyrideColors.buttonColor,
                    child: Icon(
                      Icons.power_settings_new,
                      color: EasyrideColors.buttontextColor,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchVehicleLocations() async {
    final token = await getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token is missing. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      final response = await http.post(
        Uri.parse(AppApi.Vehiclelocation),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final vehicles = data['data'] as List;
        print('Fetched Vehicles: $vehicles');
        _addMarkers(context, vehicles);
      } else {
        print('Failed to fetch vehicle locations');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _addMarkers(BuildContext context, List vehicles) {
    Set<Marker> markers = {};
    LatLngBoundsBuilder boundsBuilder = LatLngBoundsBuilder();

    for (var vehicle in vehicles) {
      final currentLat = double.parse(vehicle['current_latitude']);
      final currentLng = double.parse(vehicle['current_longitude']);
      final dropLat = double.parse(vehicle['drop_location']['latitude']);
      final dropLng = double.parse(vehicle['drop_location']['longitude']);

      bool isSameLocation = currentLat == dropLat && currentLng == dropLng;

      final currentMarker = Marker(
        markerId: MarkerId('current_${vehicle['booking_id']}'),
        position: LatLng(currentLat, currentLng),
        infoWindow: InfoWindow(
          title: 'Booking ID:-${vehicle['booking_id']}, ${vehicle['name']}',
          snippet: 'Vehicle No:-${vehicle['vehicle_no']}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isSameLocation ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        ),
      );
      markers.add(currentMarker);

      if (!isSameLocation) {
        final dropMarker = Marker(
          markerId: MarkerId('drop_${vehicle['booking_id']}'),
          position: LatLng(dropLat, dropLng),
          infoWindow: InfoWindow(
            title: 'Booking ID:-${vehicle['booking_id']} ,${vehicle['name']}',
            snippet: 'Drop Location:-${vehicle['drop_location']['name']}',
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        );
        markers.add(dropMarker);
      }

      boundsBuilder.include(LatLng(currentLat, currentLng));
      boundsBuilder.include(LatLng(dropLat, dropLng));
    }

    setState(() {
      _markers = markers;
    });

    final bounds = boundsBuilder.build();
    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }
}

class LatLngBoundsBuilder {
  double? minLat, minLng, maxLat, maxLng;

  void include(LatLng position) {
    if (minLat == null || position.latitude < minLat!) {
      minLat = position.latitude;
    }
    if (minLng == null || position.longitude < minLng!) {
      minLng = position.longitude;
    }
    if (maxLat == null || position.latitude > maxLat!) {
      maxLat = position.latitude;
    }
    if (maxLng == null || position.longitude > maxLng!) {
      maxLng = position.longitude;
    }
  }

  LatLngBounds build() {
    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }
}

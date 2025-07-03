// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, non_constant_identifier_names, avoid_print, deprecated_member_use
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/AppColors.dart/VehicleLocationProvider.dart';
import 'package:easymotorbike/AppColors.dart/polyline_provider.dart';
import 'package:easymotorbike/Placelist/Waze.dart';
import 'package:easymotorbike/Placelist/placelist2.dart';
//import 'package:easymotorbike/Placelist/drop_station_screen.dart';
import 'package:easymotorbike/Placelist/toggle.dart';
import 'package:easymotorbike/Screen/Contact.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Screen/Complete.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int batteryCapacity = 20;
  Set<Marker> _markers = {};
  LatLng? _selectedDestination;

  final List<String> _places = [
    "Bukit Bintang Walk",
    "Ceylonz Suites, Persiaran Raja Chulan",
    "Scarletz Suites, Jalan Yap Kwan Seng",
    "Central Market",
    "The Colony by Infinitum, Chow Kit",
    "The Mansion, Brickfields",
    "Batu Caves",
    "Thean Hou Temple, Persiaran Endah",
  ];

  final List<LatLng> _locations = [
    const LatLng(3.1460887463338447, 101.71770362698292),
    const LatLng(3.150236, 101.705465),
    const LatLng(3.159932, 101.712492),
    const LatLng(3.142896, 101.695771),
    const LatLng(3.162606, 101.695721),
    const LatLng(3.134852, 101.685504),
    const LatLng(3.235014, 101.683455),
    const LatLng(3.121977, 101.687094),
  ];

  final LatLng _kualaLumpur = const LatLng(3.1390, 101.6869);
  LatLng? _currentVehiclePosition;
  late GoogleMapController _mapController;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _createRouteMarkers(LatLng pickup, LatLng drop) {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('pickup_point'),
          position: pickup,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Pickup Location'),
        ),
      );

      _markers.add(
        Marker(
          markerId: const MarkerId('drop_point'),
          position: drop,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Drop Location'),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _createMarkers();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider =
          Provider.of<LocationTrackingProvider>(context, listen: false);
      final polylineProvider =
          Provider.of<PolylineProvider>(context, listen: false);

      final prefs = await SharedPreferences.getInstance();
      final startLat = prefs.getDouble('pickup_latitude');
      final startLng = prefs.getDouble('pickup_longitude');
      double? endLat = prefs.getDouble('end_latitude');
      double? endLng = prefs.getDouble('end_longitude');

      print("Start: $startLat, $startLng | End: $endLat, $endLng");

      if (startLat != null &&
          startLng != null &&
          endLat != null &&
          endLng != null) {
        final start = LatLng(startLat, startLng);
        final end = LatLng(endLat, endLng);
        _selectedDestination = end;

        final polylinePoints = await getPolylinePointsFromAPI(
          start.latitude,
          start.longitude,
          end.latitude,
          end.longitude,
        );

        if (polylinePoints.isNotEmpty) {
          final polyline = Polyline(
            polylineId: const PolylineId('route'),
            color: Colors.blue,
            width: 5,
            points: polylinePoints,
          );
          polylineProvider.setPolyline({polyline});
          _createRouteMarkers(start, end);
          _moveCameraToBounds(start, end);
        }
      }

      await provider.fetchAndTrackVehicleLocation();

      provider.addListener(() async {
        if (!mounted) return;

        final updatedLocation = provider.currentLocation;
        if (updatedLocation != null) {
          setState(() {
            _currentVehiclePosition = updatedLocation;
          });

          if (_selectedDestination != null) {
            final polylinePoints = await getPolylinePointsFromAPI(
              updatedLocation.latitude,
              updatedLocation.longitude,
              _selectedDestination!.latitude,
              _selectedDestination!.longitude,
            );

            if (polylinePoints.isNotEmpty) {
              final polyline = Polyline(
                polylineId: const PolylineId('route'),
                color: Colors.blue,
                width: 5,
                points: polylinePoints,
              );
              polylineProvider.setPolyline({polyline});
              _moveCameraToBounds(updatedLocation, _selectedDestination!);
            }
          }
        }
      });
    });
  }

  void _createMarkers() {
    if (mounted) {
      setState(() {
        _markers = _locations.asMap().entries.map((entry) {
          int index = entry.key;
          LatLng location = entry.value;
          return Marker(
              markerId: MarkerId(_places[index]),
              position: location,
              infoWindow: InfoWindow(title: _places[index]),
              onTap: () async {
                final vehiclePos = _currentVehiclePosition;
                if (vehiclePos == null) return;

                _selectedDestination = location;

                final polylinePoints = await getPolylinePointsFromAPI(
                  vehiclePos.latitude,
                  vehiclePos.longitude,
                  location.latitude,
                  location.longitude,
                );

                if (polylinePoints.isEmpty) return;

                final polyline = Polyline(
                  polylineId: const PolylineId('route'),
                  color: Colors.blue,
                  width: 5,
                  points: polylinePoints,
                );

                final polylineProvider =
                    Provider.of<PolylineProvider>(context, listen: false);
                polylineProvider.setPolyline({polyline});

                _moveCameraToBounds(vehiclePos, location);
              });
        }).toSet();
      });
    }
  }

  void _moveCameraToBounds(LatLng start, LatLng end) {
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        start.latitude < end.latitude ? start.latitude : end.latitude,
        start.longitude < end.longitude ? start.longitude : end.longitude,
      ),
      northeast: LatLng(
        start.latitude > end.latitude ? start.latitude : end.latitude,
        start.longitude > end.longitude ? start.longitude : end.longitude,
      ),
    );
    _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  Future<List<LatLng>> getPolylinePointsFromAPI(
    double originLat,
    double originLng,
    double destinationLat,
    double destinationLng,
  ) async {
    final url = AppApi.getDirectionsUrl(
        originLat, originLng, destinationLat, destinationLng);

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final points = data['routes'][0]['overview_polyline']['points'];
      return decodePolyline(points);
    } else {
      print('Failed to fetch route: ${response.body}');
      return [];
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polylineCoordinates.add(
        LatLng(lat / 1E5, lng / 1E5),
      );
    }

    return polylineCoordinates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Consumer<PolylineProvider>(
              builder: (context, polylineProvider, _) {
                return GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _kualaLumpur,
                    zoom: 12.5,
                  ),
                  markers: {
                    ..._markers,
                    if (_currentVehiclePosition != null)
                      Marker(
                        markerId: const MarkerId("current_vehicle"),
                        position: _currentVehiclePosition!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue),
                        infoWindow: const InfoWindow(title: "Your Vehicle"),
                      ),
                  },
                  polylines: polylineProvider.polylines,
                );
              },
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.03,
            right: MediaQuery.of(context).size.height * 0.01,
            child: Consumer<LocationTrackingProvider>(
              builder: (context, provider, child) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Speed: ${provider.speed} km/h',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(width: 7),
                      Icon(
                        Icons.battery_full,
                        color: provider.batteryCapacity > 20
                            ? Colors.white
                            : Colors.red,
                        size: 24,
                      ),
                      Text(
                        '${provider.batteryCapacity}%',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.02,
            left: MediaQuery.of(context).size.height * 0.01,
            right: MediaQuery.of(context).size.height * 0.06,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    retrieveMessageAndShowBottomSheet();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: EasyrideColors.buttonColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "More Options",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showRideFinishAlert(context);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: EasyrideColors.buttonColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Finish Ride",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showRideFinishAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Center(
            child: Icon(
              Icons.logout,
              size: 64,
              color: Colors.red,
            ),
          ),
          content: const Text(
            'Are you sure you want to finish your ride?',
            style: TextStyle(fontSize: 16, color: Colors.green),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: EasyrideColors.buttonColor,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
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
                style: TextButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('VehicleNo');
                  Navigator.of(context).pop();
                  final polylineProvider =
                      Provider.of<PolylineProvider>(context, listen: false);
                  polylineProvider.clearPolylines();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompleteRideScreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text(
                  'Ok',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> retrieveMessageAndShowBottomSheet() async {
    final prefs = await SharedPreferences.getInstance();
    String? message = prefs.getString('Messasge');
    String? Vehicleno = prefs.getString('VehicleNo');
    _showGroupRideBottomSheet(message, Vehicleno);
  }

  void _showGroupRideBottomSheet(message, Vehicleno) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.00001),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Stack(
            children: [
              Container(
                color: Colors.transparent,
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.5,
                minChildSize: 0.5,
                maxChildSize: 0.5,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                message,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Vehicle No.: $Vehicleno',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                  'https://media2.dev.to/dynamic/image/width=800%2Cheight=%2Cfit=scale-down%2Cgravity=auto%2Cformat=auto/https%3A%2F%2Fwww.gravatar.com%2Favatar%2F2c7d99fe281ecd3bcd65ab915bac6dd5%3Fs%3D250',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: const Column(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: EasyrideColors.buttonColor,
                                            size: 50,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Confirmation',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      content: Text(
                                        'Are you sure you want to proceed to the Waze Map screen?',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[800]),
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.spaceAround,
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[300],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Cancel',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const PlacelistWaze(),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                EasyrideColors.buttonColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Yes',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 30),
                                decoration: BoxDecoration(
                                  color: EasyrideColors.buttonColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  "Waze Map",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: const Column(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: EasyrideColors.buttonColor,
                                            size: 50,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Confirmation',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      content: Text(
                                        'Are you sure you want to proceed to the Google Map screen?',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[800]),
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.spaceAround,
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[300],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Cancel',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const Placelist2(),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                EasyrideColors.buttonColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Yes',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: EasyrideColors.buttonColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  "Google Map",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        const CustomVehicleSwitch(),
                        const SizedBox(
                          height: 16,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            launchWhatsApp(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: EasyrideColors.buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            elevation: 5,
                            shadowColor: Colors.black.withOpacity(0.2),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: const FaIcon(
                                      FontAwesomeIcons.whatsapp,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Emergency",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}









/*import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/AppColors.dart/VehicleLocationProvider.dart';
import 'package:easymotorbike/AppColors.dart/polyline_provider.dart';
import 'package:easymotorbike/Placelist/toggle.dart';
import 'package:easymotorbike/Screen/Contact.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Screen/Complete.dart';
import 'Waze.dart';
import 'placelist2.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int batteryCapacity = 20;
  Set<Marker> _markers = {};
  LatLng? _selectedDestination;

  final List<String> _places = [
    "Bukit Bintang Walk",
    "Ceylonz Suites, Persiaran Raja Chulan",
    "Scarletz Suites, Jalan Yap Kwan Seng",
    "Central Market",
    "The Colony by Infinitum, Chow Kit",
    "The Mansion, Brickfields",
    "Batu Caves",
    "Thean Hou Temple, Persiaran Endah",
  ];

  final List<LatLng> _locations = [
    const LatLng(3.1460887463338447, 101.71770362698292),
    const LatLng(3.150236, 101.705465),
    const LatLng(3.159932, 101.712492),
    const LatLng(3.142896, 101.695771),
    const LatLng(3.162606, 101.695721),
    const LatLng(3.134852, 101.685504),
    const LatLng(3.235014, 101.683455),
    const LatLng(3.121977, 101.687094),
  ];

  final LatLng _kualaLumpur = const LatLng(3.1390, 101.6869);
  LatLng? _currentVehiclePosition;
  late GoogleMapController _mapController;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<LatLng?> getCurrentLocationFromDevice() async {
    bool serviceEnabled;
    LocationPermission permission;

    // ✅ Step 1: Check GPS is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('❌ Location services are disabled.');
      return null;
    }

    // ✅ Step 2: Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('❌ Location permissions are denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('❌ Location permissions are permanently denied');
      return null;
    }

    // ✅ Step 3: Get the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    print(
        '📍 Mobile GPS Location: ${position.latitude}, ${position.longitude}');

    return LatLng(position.latitude, position.longitude);
  }

  @override
  void initState() {
    _createMarkers();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<LocationTrackingProvider>(context, listen: false);

      final polylineProvider =
          Provider.of<PolylineProvider>(context, listen: false);

      final prefs = await SharedPreferences.getInstance();
      double? endLat = prefs.getDouble('end_latitude');
      double? endLng = prefs.getDouble('end_longitude');

      if (endLat != null && endLng != null) {
        _selectedDestination = LatLng(endLat, endLng);
      }

      LatLng? gpsLocation = await getCurrentLocationFromDevice();
      if (gpsLocation != null) {
        setState(() {
          _currentVehiclePosition = gpsLocation;
        });

        if (_selectedDestination != null) {
          final polylinePoints = await getPolylinePointsFromAPI(
            gpsLocation.latitude,
            gpsLocation.longitude,
            _selectedDestination!.latitude,
            _selectedDestination!.longitude,
          );

          if (polylinePoints.isNotEmpty) {
            final polyline = Polyline(
              polylineId: const PolylineId('route'),
              color: Colors.blue,
              width: 5,
              points: polylinePoints,
            );

            polylineProvider.setPolyline({polyline});
            _moveCameraToBounds(gpsLocation, _selectedDestination!);
          }
        }
      } else {
        print("❌ Could not fetch mobile location");
      }
    });
  }

  void _createMarkers() {
    {
      setState(() {
        _markers = _locations.asMap().entries.map((entry) {
          int index = entry.key;
          LatLng location = entry.value;
          return Marker(
              markerId: MarkerId(_places[index]),
              position: location,
              infoWindow: InfoWindow(title: _places[index]),
              onTap: () async {
                final vehiclePos = _currentVehiclePosition;
                if (vehiclePos == null) return;

                _selectedDestination = location;

                final polylinePoints = await getPolylinePointsFromAPI(
                  vehiclePos.latitude,
                  vehiclePos.longitude,
                  location.latitude,
                  location.longitude,
                );

                if (polylinePoints.isEmpty) return;

                final polyline = Polyline(
                  polylineId: const PolylineId('route'),
                  color: Colors.blue,
                  width: 5,
                  points: polylinePoints,
                );

                final polylineProvider =
                    Provider.of<PolylineProvider>(context, listen: false);
                polylineProvider.setPolyline({polyline});

                _moveCameraToBounds(vehiclePos, location);
              });
        }).toSet();
      });
    }
  }

  void _moveCameraToBounds(LatLng start, LatLng end) {
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        start.latitude < end.latitude ? start.latitude : end.latitude,
        start.longitude < end.longitude ? start.longitude : end.longitude,
      ),
      northeast: LatLng(
        start.latitude > end.latitude ? start.latitude : end.latitude,
        start.longitude > end.longitude ? start.longitude : end.longitude,
      ),
    );
    _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  Future<List<LatLng>> getPolylinePointsFromAPI(
    double originLat,
    double originLng,
    double destinationLat,
    double destinationLng,
  ) async {
    final url = AppApi.getDirectionsUrl(
        originLat, originLng, destinationLat, destinationLng);

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final points = data['routes'][0]['overview_polyline']['points'];
      return decodePolyline(points);
    } else {
      print('Failed to fetch route: ${response.body}');
      return [];
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polylineCoordinates.add(
        LatLng(lat / 1E5, lng / 1E5),
      );
    }

    return polylineCoordinates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Consumer<PolylineProvider>(
              builder: (context, polylineProvider, _) {
                return GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _kualaLumpur,
                    zoom: 12.5,
                  ),
                  markers: {
                    ..._markers,
                    if (_currentVehiclePosition != null)
                      Marker(
                        markerId: const MarkerId("current_vehicle"),
                        position: _currentVehiclePosition!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue),
                        infoWindow: const InfoWindow(title: "Your Vehicle"),
                      ),
                  },
                  polylines: polylineProvider.polylines,
                );
              },
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.03,
            right: MediaQuery.of(context).size.height * 0.01,
            child: Consumer<LocationTrackingProvider>(
              builder: (context, provider, child) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Speed: ${provider.speed} km/h',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(width: 7),
                      Icon(
                        Icons.battery_full,
                        color: provider.batteryCapacity > 20
                            ? Colors.white
                            : Colors.red,
                        size: 24,
                      ),
                      Text(
                        '${provider.batteryCapacity}%',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.02,
            left: MediaQuery.of(context).size.height * 0.01,
            right: MediaQuery.of(context).size.height * 0.06,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    retrieveMessageAndShowBottomSheet();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: EasyrideColors.buttonColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "More Options",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showRideFinishAlert(context);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: EasyrideColors.buttonColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Finish Ride",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showRideFinishAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Center(
            child: Icon(
              Icons.logout,
              size: 64,
              color: Colors.red,
            ),
          ),
          content: const Text(
            'Are you sure you want to finish your ride?',
            style: TextStyle(fontSize: 16, color: Colors.green),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: EasyrideColors.buttonColor,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
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
                style: TextButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('VehicleNo');
                  Navigator.of(context).pop();
                  final polylineProvider =
                      Provider.of<PolylineProvider>(context, listen: false);
                  polylineProvider.clearPolylines();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompleteRideScreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text(
                  'Ok',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> retrieveMessageAndShowBottomSheet() async {
    final prefs = await SharedPreferences.getInstance();
    String? message = prefs.getString('Messasge');
    String? Vehicleno = prefs.getString('VehicleNo');
    _showGroupRideBottomSheet(message, Vehicleno);
  }

  void _showGroupRideBottomSheet(message, Vehicleno) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.00001),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Stack(
            children: [
              Container(
                color: Colors.transparent,
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.450,
                minChildSize: 0.450,
                maxChildSize: 0.450,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                message,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Vehicle No.: $Vehicleno',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                  'https://media2.dev.to/dynamic/image/width=800%2Cheight=%2Cfit=scale-down%2Cgravity=auto%2Cformat=auto/https%3A%2F%2Fwww.gravatar.com%2Favatar%2F2c7d99fe281ecd3bcd65ab915bac6dd5%3Fs%3D250',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: const Column(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: EasyrideColors.buttonColor,
                                            size: 50,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Confirmation',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      content: Text(
                                        'Are you sure you want to proceed to the Waze Map screen?',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[800]),
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.spaceAround,
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[300],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Cancel',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const PlacelistWaze(),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                EasyrideColors.buttonColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Yes',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 30),
                                decoration: BoxDecoration(
                                  color: EasyrideColors.buttonColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  "Waze Map",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: const Column(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: EasyrideColors.buttonColor,
                                            size: 50,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Confirmation',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      content: Text(
                                        'Are you sure you want to proceed to the Google Map screen?',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[800]),
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.spaceAround,
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[300],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Cancel',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const Placelist2(),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                EasyrideColors.buttonColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Yes',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: EasyrideColors.buttonColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  "Google Map",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        const CustomVehicleSwitch(),
                        const SizedBox(
                          height: 16,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            launchWhatsApp(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: EasyrideColors.buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            elevation: 5,
                            shadowColor: Colors.black.withOpacity(0.2),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: const FaIcon(
                                      FontAwesomeIcons.whatsapp,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Emergency",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
*/
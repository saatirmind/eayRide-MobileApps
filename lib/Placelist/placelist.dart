import 'dart:async';
import 'package:easyride/AppColors.dart/EasyrideAppColors.dart';
import 'package:easyride/Placelist/Waze.dart';
import 'package:easyride/Placelist/placelist2.dart';
import 'package:easyride/Screen/Complete.dart';
import 'package:easyride/Screen/Contact.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PlaceList extends StatefulWidget {
  const PlaceList({
    super.key,
  });

  @override
  State<PlaceList> createState() => _PlaceListState();
}

class _PlaceListState extends State<PlaceList> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  LatLng? startLocation;
  LatLng? endLocation;
  String? destinationCity;
  String? pickupCity;
  LatLng? _currentLocation;
  LatLng? _dropLocation;

  @override
  void initState() {
    super.initState();
    retrieveCities();
    loadBikeMarker();
    useSavedLocations();
    _startLocationUpdates();
  }

  Future<void> retrieveMessageAndShowBottomSheet() async {
    final prefs = await SharedPreferences.getInstance();
    String? message = prefs.getString('Messasge');
    String? Vehicleno = prefs.getString('VehicleNo');
    _showGroupRideBottomSheet(message, Vehicleno);
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

  Future<String?> _getCity(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var value = prefs.get(key);
    if (value is String) {
      return value;
    }
    return null;
  }

  Future<void> retrieveCities() async {
    String? destinationCity = await _getCity('destinationCity');
    String? pickupCity = await _getCity('pickupCity');

    if (destinationCity != null && pickupCity != null) {
      setState(() {
        this.destinationCity = destinationCity;
        this.pickupCity = pickupCity;
      });
    } else if (destinationCity == null && pickupCity == null) {
    } else {
      if (destinationCity == null) if (pickupCity == null) ;
    }
  }

  Future<void> useSavedLocations() async {
    startLocation = await getStartLocationFromSharedPreferences();
    endLocation = await getEndLocationFromSharedPreferences();
    _dropLocation = await getEndLocationFromSharedPreferences();

    if (startLocation != null && endLocation != null) {
      _addMarkers();
      _createPolylines();
    } else {}
  }

  void _addMarkers() {
    if (startLocation != null) {
      _markers.add(Marker(
        markerId: const MarkerId('start_location'),
        position: startLocation!,
        infoWindow: InfoWindow(
          title: pickupCity,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    }

    if (endLocation != null) {
      _markers.add(Marker(
        markerId: const MarkerId('end_location'),
        position: endLocation!,
        infoWindow: InfoWindow(
          title: destinationCity,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }
    setState(() {});
  }

  Future<void> _createPolylines() async {
    if (startLocation != null && endLocation != null) {
      final route = await _getRoute(startLocation!, endLocation!);
      if (route != null) {
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          points: route,
          color: Colors.blue,
          width: 5,
        ));
        setState(() {});
      }
    }
  }

  Future<List<LatLng>?> _getRoute(LatLng start, LatLng end) async {
    String directionsUrl = AppApi.getDirectionsUrl(
        start.latitude, start.longitude, end.latitude, end.longitude);

    final response = await http.get(Uri.parse(directionsUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final route = data['routes'][0]['overview_polyline']['points'];
        return _decodePoly(route);
      }
    }
    return null;
  }

  List<LatLng> _decodePoly(String encoded) {
    List<LatLng> polylinePoints = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polylinePoints.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polylinePoints;
  }

  void _moveCameraToBounds() {
    if (startLocation != null && endLocation != null) {
      final bounds = LatLngBounds(
        southwest: LatLng(
          startLocation!.latitude < endLocation!.latitude
              ? startLocation!.latitude
              : endLocation!.latitude,
          startLocation!.longitude < endLocation!.longitude
              ? startLocation!.longitude
              : endLocation!.longitude,
        ),
        northeast: LatLng(
          startLocation!.latitude > endLocation!.latitude
              ? startLocation!.latitude
              : endLocation!.latitude,
          startLocation!.longitude > endLocation!.longitude
              ? startLocation!.longitude
              : endLocation!.longitude,
        ),
      );

      _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: (controller) {
                setState(() {
                  _mapController = controller;
                });
                if (startLocation != null && endLocation != null) {
                  _moveCameraToBounds();
                }
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(0, 0),
                zoom: 2.0,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.02,
              left: MediaQuery.of(context).size.height * 0.06,
              right: MediaQuery.of(context).size.height * 0.08,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      retrieveMessageAndShowBottomSheet();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: EasyrideColors.buttonColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Contact Us",
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
      ),
    );
  }

  Future<void> _checkPermissionAndGetLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _updateMarker();
      _getPolyline();
      _addMarkers();
      _checkLocationProximity();
    });

    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentLocation!,
          zoom: 18.0,
        ),
      ),
    );

    await _sendLocationToApi(position.latitude, position.longitude);
  }

  Future<void> _updateMarker() async {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: _currentLocation!,
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: bikeMarkerIcon ?? BitmapDescriptor.defaultMarker,
      ),
    );
    setState(() {});
  }

  BitmapDescriptor? bikeMarkerIcon;

  void loadBikeMarker() async {
    bikeMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/mapmarker.png',
    );
  }

  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<LatLng> _polylineCoordinates = [];
  Future<void> _startLocationUpdates() async {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _checkPermissionAndGetLocation();
    });
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getBookingToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('booking_token');
  }

  Future<void> _sendLocationToApi(double latitude, double longitude) async {
    final token = await getToken();
    final bookingToken = await getBookingToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token is missing. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }
    if (bookingToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Your ride has been completed!'),
            backgroundColor: EasyrideColors.successSnak),
      );
      return;
    }
    const String apiUrl = AppApi.ridetracking;
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json', 'token': token},
        body: jsonEncode({
          'booking_token': bookingToken,
          'current_lat': latitude,
          'current_long': longitude,
        }),
      );
      if (response.statusCode == 201) {
        print('Location sent successfully');
      } else {
        print('Failed to send location: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending location: $e');
    }
  }

  Future<void> _getPolyline() async {
    if (_currentLocation == null) return;

    String directionsUrl = AppApi.getDirectionsUrl(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        _dropLocation!.latitude,
        _dropLocation!.longitude);
    var response = await http.get(Uri.parse(directionsUrl));
    var data = json.decode(response.body);

    if (data['routes'].isNotEmpty) {
      String polylinePoints = data['routes'][0]['overview_polyline']['points'];
      _polylineCoordinates = _decodePolyline(polylinePoints);

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: PolylineId('route'),
            points: _polylineCoordinates,
            color: Colors.green,
            width: 7,
          ),
        );
      });
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  Future<void> _checkLocationProximity() async {
    if (_currentLocation != null && _dropLocation != null) {
      double distance = Geolocator.distanceBetween(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        _dropLocation!.latitude,
        _dropLocation!.longitude,
      );

      if (distance < 200) {
        _timer?.cancel();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('booking_token');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CompleteRideScreen(),
          ),
        );
      }
    }
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
                initialChildSize: 0.4,
                minChildSize: 0.4,
                maxChildSize: 0.9,
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
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                message,
                                style: TextStyle(
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
                        Divider(),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Vehicle No.: ${Vehicleno}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(
                                  'https://media2.dev.to/dynamic/image/width=800%2Cheight=%2Cfit=scale-down%2Cgravity=auto%2Cformat=auto/https%3A%2F%2Fwww.gravatar.com%2Favatar%2F2c7d99fe281ecd3bcd65ab915bac6dd5%3Fs%3D250',
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PlacelistWaze()),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 30),
                                decoration: BoxDecoration(
                                  color: EasyrideColors.buttonColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Placelist2()),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: EasyrideColors.buttonColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
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
                        SizedBox(
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
                            padding: EdgeInsets.symmetric(vertical: 15),
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
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: EdgeInsets.all(2),
                                    child: FaIcon(
                                      FontAwesomeIcons.whatsapp,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
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

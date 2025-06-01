// ignore_for_file: non_constant_identifier_names, avoid_print, unused_element, use_build_context_synchronously, deprecated_member_use
import 'dart:async';
import 'dart:math';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/Placelist/Waze.dart';
import 'package:easymotorbike/Placelist/placelist2.dart';
import 'package:easymotorbike/Screen/Complete.dart';
import 'package:easymotorbike/Screen/Contact.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:battery_plus/battery_plus.dart';

class PlaceList extends StatefulWidget {
  const PlaceList({
    super.key,
  });

  @override
  State<PlaceList> createState() => _PlaceListState();
}

class _PlaceListState extends State<PlaceList> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  LatLng? startLocation;
  LatLng? endLocation;
  String? destinationCity;
  String? pickupCity;
  LatLng? _currentLocation;
  LatLng? _dropLocation;
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    retrieveCities();
    loadBikeMarker();
    useSavedLocations();
    _startLocationUpdates();
    retrieveMessageAndShowBottomSheet();
    _addMarkers();
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? vehicleId = prefs.getString('vehicle_id') ?? "";

    await fetchVehicleLocation(vehicleId);
  }

  Future<void> fetchVehicleLocation(String vehicleId) async {
    final url = "${AppApi.Vehicleid}$vehicleId";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData["status"] == true && responseData["data"] != null) {
        setState(() {
          latitude = responseData["data"]["lat"];
          longitude = responseData["data"]["lng"];
          _currentLocation = LatLng(latitude!, longitude!);
          _checkPermissionAndGetLocation();
        });
      }
    } else {
      print("❌ Location API Error: ${response.statusCode}");
    }
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
      if (destinationCity == null) if (pickupCity == null) {}
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

  /* final Battery _battery = Battery();
  int batteryCapacity = 20;
  Future<void> _getBatteryLevel() async {
    final level = await _battery.batteryLevel;
    setState(() {
      batteryCapacity = level;
    });
  }*/

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

  int speed = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            top: MediaQuery.of(context).size.height * 0.03,
            right: MediaQuery.of(context).size.height * 0.01,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Speed : $speed km/h',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(
                    width: 7,
                  ),
                  /*  Icon(
                    Icons.battery_full,
                    color: batteryCapacity > 20 ? Colors.white : Colors.red,
                    size: 24,
                  ),
                  Text(
                    '$batteryCapacity%',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),*/
                ],
              ),
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
                  backgroundColor: Colors.blue,
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
                  Navigator.of(context).pop();
                  _timer?.cancel();
                  _timer = null;
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('VehicleNo');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompleteRideScreen(),
                    ),
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

  Future<void> _checkPermissionAndGetLocation() async {
    _timer = null;

    if (_currentLocation != null) {
      setState(() {
        _updateMarker();
        _getPolyline();
        _updateCameraBounds();
        _addMarkers();
      });

      _sendLocationToApi(
          _currentLocation!.latitude, _currentLocation!.longitude);
    }
  }

  Future<void> _updateCameraBounds() async {
    if (_currentLocation == null || _dropLocation == null) return;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        min(_currentLocation!.latitude, _dropLocation!.latitude),
        min(_currentLocation!.longitude, _dropLocation!.longitude),
      ),
      northeast: LatLng(
        max(_currentLocation!.latitude, _dropLocation!.latitude),
        max(_currentLocation!.longitude, _dropLocation!.longitude),
      ),
    );

    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 20),
    );
  }

  double getBearing(LatLng start, LatLng end) {
    double lat1 = start.latitude * (pi / 180);
    double lon1 = start.longitude * (pi / 180);
    double lat2 = end.latitude * (pi / 180);
    double lon2 = end.longitude * (pi / 180);

    double dLon = lon2 - lon1;

    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double bearing = atan2(y, x) * (180 / pi);

    return (bearing + 360) % 360;
  }

  Future<void> _updateMarker() async {
    if (_polylineCoordinates.length < 2) return;

    double bearing =
        getBearing(_polylineCoordinates[0], _polylineCoordinates[1]);

    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: _currentLocation!,
        rotation: bearing,
        icon: bikeMarkerIcon ?? BitmapDescriptor.defaultMarker,
      ),
    );

    setState(() {});
  }

  void moveMarker(LatLng newPosition) {
    if (_polylineCoordinates.isNotEmpty) {
      double bearing = getBearing(_currentLocation!, newPosition);

      setState(() {
        _currentLocation = newPosition;
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentLocation!,
            rotation: bearing,
            icon: bikeMarkerIcon ?? BitmapDescriptor.defaultMarker,
          ),
        );
      });

      _mapController.animateCamera(
        CameraUpdate.newLatLng(newPosition),
      );
    }
  }

  BitmapDescriptor? bikeMarkerIcon;

  void loadBikeMarker() async {
    bikeMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(2, 2)),
      'assets/markerr.png',
    );
  }

  Timer? _timer;

  List<LatLng> _polylineCoordinates = [];
  Future<void> _startLocationUpdates() async {
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) async {
      await fetchData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
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
    String latitudeStr = latitude.toString();
    String longitudeStr = longitude.toString();

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
    try {
      final response = await http.post(
        Uri.parse(AppApi.ridetracking),
        headers: {'Content-Type': 'application/json', 'token': token},
        body: jsonEncode({
          'booking_token': bookingToken,
          'current_lat': latitudeStr,
          'current_long': longitudeStr
        }),
      );
      if (response.statusCode == 201) {
        print('Location sent successfully');
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final int newSpeed = responseData['data']['Speed'];
        // final int newBatteryCapacity =
        responseData['data']['battery'][0]['capacitysoc'];

        setState(() {
          speed = newSpeed;
          // batteryCapacity = newBatteryCapacity;
        });
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

      if (mounted) {
        setState(() {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: _polylineCoordinates,
              color: Colors.green,
              width: 7,
            ),
          );
        });
      }
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

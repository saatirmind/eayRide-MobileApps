// ignore_for_file: library_private_types_in_public_api, avoid_print, non_constant_identifier_names, use_build_context_synchronously, empty_catches, deprecated_member_use
import 'dart:async';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NextScreen extends StatefulWidget {
  final Map<String, dynamic> vehicleData;

  const NextScreen({super.key, required this.vehicleData});

  @override
  _NextScreenState createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> with WidgetsBindingObserver {
  Timer? timer;
  final Set<Polyline> _polylines = {};
  List<LatLng> _routeCoords = [];
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startPeriodicTracking();
    _getRoute();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPeriodicTracking();
    super.dispose();
  }

  void _startPeriodicTracking() {
    if (timer == null || !timer!.isActive) {
      timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) async {
        await RangerTracking();
      });
      print('Timer started');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _stopPeriodicTracking();
    } else if (state == AppLifecycleState.resumed) {
      _startPeriodicTracking();
    }
  }

  void _stopPeriodicTracking() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
      timer = null;
      print('Timer stopped');
    }
  }

  Future<void> RangerTracking() async {
    print('Ranger HIT API');

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
      Position currentPosition = await _getCurrentLocation();
      double currentLatg = currentPosition.latitude;
      double currentLngg = currentPosition.longitude;
      print("${widget.vehicleData['booking_id']}");

      final response = await http.post(
        Uri.parse(AppApi.RangerTracking),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: jsonEncode({
          'booking_id': widget.vehicleData['booking_id'].toString(),
          'current_lat': currentLatg.toString(),
          'current_long': currentLngg.toString(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
        } else {}
      } else {}
    } catch (error) {}
  }

  Future<void> _getRoute() async {
    try {
      double currentLat =
          double.parse(widget.vehicleData['current_latitude'].toString());
      double currentLng =
          double.parse(widget.vehicleData['current_longitude'].toString());
      double dropLat =
          double.parse(widget.vehicleData['drop_latitude'].toString());
      double dropLng =
          double.parse(widget.vehicleData['drop_longitude'].toString());

      String directionsUrl = AppApi.getDirectionsUrl(
        currentLat,
        currentLng,
        dropLat,
        dropLng,
      );

      final response = await http.get(Uri.parse(directionsUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'].isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          _routeCoords = _decodePolyline(points);
          _addPolyline();
        } else {
          print('No routes found');
        }
      } else {
        print('Failed to fetch route. Status Code: ${response.statusCode}');
      }

      _fitMarkers(currentLat, currentLng, dropLat, dropLng);
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }

  void _addPolyline() {
    setState(() {
      _polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: _routeCoords,
        color: Colors.blue,
        width: 4,
      ));
    });
  }

  void _fitMarkers(
      double currentLat, double currentLng, double dropLat, double dropLng) {
    LatLngBounds bounds;

    if (currentLat > dropLat && currentLng > dropLng) {
      bounds = LatLngBounds(
        southwest: LatLng(dropLat, dropLng),
        northeast: LatLng(currentLat, currentLng),
      );
    } else if (currentLat > dropLat) {
      bounds = LatLngBounds(
        southwest: LatLng(dropLat, currentLng),
        northeast: LatLng(currentLat, dropLng),
      );
    } else if (currentLng > dropLng) {
      bounds = LatLngBounds(
        southwest: LatLng(currentLat, dropLng),
        northeast: LatLng(dropLat, currentLng),
      );
    } else {
      bounds = LatLngBounds(
        southwest: LatLng(currentLat, currentLng),
        northeast: LatLng(dropLat, dropLng),
      );
    }

    _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  @override
  Widget build(BuildContext context) {
    double? currentLat = widget.vehicleData['current_latitude'] != null
        ? double.tryParse(widget.vehicleData['current_latitude'].toString())
        : null;
    double? currentLng = widget.vehicleData['current_longitude'] != null
        ? double.tryParse(widget.vehicleData['current_longitude'].toString())
        : null;
    double? dropLat = widget.vehicleData['drop_latitude'] != null
        ? double.tryParse(widget.vehicleData['drop_latitude'].toString())
        : null;
    double? dropLng = widget.vehicleData['drop_longitude'] != null
        ? double.tryParse(widget.vehicleData['drop_longitude'].toString())
        : null;

    Set<Marker> markers = {};

    if (currentLat != null && currentLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(currentLat, currentLng),
          infoWindow: const InfoWindow(title: 'Current Location'),
        ),
      );
    }

    if (dropLat != null && dropLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('dropLocation'),
          position: LatLng(dropLat, dropLng),
          infoWindow: const InfoWindow(title: 'Drop Location'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Booking ID: ${widget.vehicleData['booking_id']}',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: currentLat != null && currentLng != null
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(currentLat, currentLng),
                      zoom: 14,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;

                      if (dropLat != null && dropLng != null) {
                        _fitMarkers(currentLat, currentLng, dropLat, dropLng);
                      }
                    },
                    polylines: _polylines,
                    markers: markers,
                  )
                : const Center(
                    child: Text(
                      'Error: Location data is missing!',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: _isLoading
                  ? Center(
                      child: Container(
                        margin: const EdgeInsets.all(4.0),
                        child: const CircularProgressIndicator(),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        _stopPeriodicTracking();

                        _submitButton();
                        print("Submit button pressed!");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String message = "";
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error('Location permission denied');
      }
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  bool _isLoading = false;

  Future<void> _submitButton() async {
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

    setState(() {
      _isLoading = true;
    });

    try {
      Position currentPosition = await _getCurrentLocation();
      double currentLatg = currentPosition.latitude;
      double currentLngg = currentPosition.longitude;
      print(currentLatg);
      print(currentLngg);
      print("${widget.vehicleData['booking_id']}");

      final response = await http.post(
        Uri.parse(AppApi.CorrectParking),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: jsonEncode({
          'booking_id': widget.vehicleData['booking_id'].toString(),
          'current_lat': currentLatg.toString(),
          'current_long': currentLngg.toString(),
        }),
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            message = data['message'][0];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            message = data['message'][0];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        final data = json.decode(response.body);
        setState(() {
          message = data['message'][0];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        message = 'Error occurred: $error';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

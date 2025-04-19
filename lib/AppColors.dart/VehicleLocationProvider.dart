// ignore_for_file: file_names, prefer_const_constructors, avoid_print
import 'dart:convert';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationTrackingProvider extends ChangeNotifier {
  double? latitude;
  double? longitude;
  LatLng? _currentLocation;
  bool _isTracking = false;
  int speed = 0;
  int batteryCapacity = 0;

  LatLng? get currentLocation => _currentLocation;
  bool get isTracking => _isTracking;

  Future<void> fetchAndTrackVehicleLocation() async {
    if (_isTracking) return;
    _isTracking = true;
    notifyListeners();

    while (_isTracking) {
      await _fetchVehicleLocation();
      if (latitude != null && longitude != null) {
        await _sendLocationToApi(latitude!, longitude!);
      }
      await Future.delayed(Duration(seconds: 3));
    }
  }

  Future<void> stopTracking() async {
    _isTracking = false;
    notifyListeners();
    print("📴 App tracking Stop!");
  }

  Future<void> _fetchVehicleLocation() async {
    dynamic vehicleId = await AppApi.getVehicleId();

    if (vehicleId == null) {
      print("🚨 Error: Vehicle ID not found in SharedPreferences!");
      return;
    }

    final url = "${AppApi.Vehicleid}$vehicleId";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData["status"] == true && responseData["data"] != null) {
          latitude = double.tryParse(responseData["data"]["lat"].toString());
          longitude = double.tryParse(responseData["data"]["lng"].toString());

          if (latitude != null && longitude != null) {
            _currentLocation = LatLng(latitude!, longitude!);
            notifyListeners();
          }
        }
      } else {
        print("❌ Location API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("🚨 Error fetching vehicle location: $e");
    }
  }

  Future<void> _sendLocationToApi(double latitude, double longitude) async {
    final token = await AppApi.getToken();
    final bookingToken = await AppApi.getBookingToken();

    if (token == null) {
      print("🚨 Token is missing. Please log in again.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(AppApi.ridetracking),
        headers: {'Content-Type': 'application/json', 'token': token},
        body: jsonEncode({
          'booking_token': bookingToken,
          'current_lat': latitude.toString(),
          'current_long': longitude.toString(),
        }),
      );

      if (response.statusCode == 201) {
        print('✅ Location sent successfully');
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        speed = responseData['data']['Speed'];
        batteryCapacity = responseData['data']['battery'][0]['capacitysoc'];
        notifyListeners();
      } else {
        print('❌ Failed to send location: ${response.statusCode}');
      }
    } catch (e) {
      print('🚨 Error sending location: $e');
    }
  }
}

// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VehicleVisibilityProvider extends ChangeNotifier {
  bool _isVisible = true;
  bool get isVisible => _isVisible;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  VehicleVisibilityProvider() {
    _loadSavedStatus();
  }

  Future<void> _loadSavedStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? savedStatus = prefs.getBool("vehicle_status");
    if (savedStatus != null) {
      _isVisible = savedStatus;
      notifyListeners();
    }
  }

  Future<void> toggleVisibilityWithAPI() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    final token = await AppApi.getToken();
    if (token == null) {
      print("🚨 Token is missing. Please log in again.");
      _isLoading = false;
      notifyListeners();
      return;
    }

    final bookingToken = await AppApi.getBookingToken();
    String newStatusValue = !_isVisible ? "1" : "0";

    try {
      var response = await http.post(
        Uri.parse(AppApi.vehicle_on_off),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: json.encode({
          "status": newStatusValue,
          "booking_token": bookingToken,
        }),
      );

      if (response.statusCode == 200) {
        _isVisible = !_isVisible;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool("vehicle_status", _isVisible);

        var responseData = json.decode(response.body);
        String message = responseData["message"]?[0] ?? "Success";
        print(message);
      } else {
        print("❌ Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("⚠️ Exception: $e");
    }
    _isLoading = false;
    notifyListeners();
  }
}

class CustomVehicleSwitch extends StatelessWidget {
  const CustomVehicleSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = Provider.of<VehicleVisibilityProvider>(context);
    final isVehicleVisible = vehicleProvider.isVisible;
    final isLoading = vehicleProvider.isLoading;

    return GestureDetector(
      onTap: () {
        vehicleProvider.toggleVisibilityWithAPI();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isVehicleVisible ? Colors.green : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isVehicleVisible ? "Vehicle On" : "Vehicle Off",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 35,
              width: 80,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 400),
                alignment: isVehicleVisible
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: isVehicleVisible ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          FontAwesomeIcons.circle,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

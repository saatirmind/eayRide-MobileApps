// ignore_for_file: use_build_context_synchronously, avoid_print, prefer_const_constructors
import 'dart:async';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TripProvider with ChangeNotifier {
  List<dynamic> _tripTypes = [];
  String _selectedTripType = '';
  String _selectedTripPrice = '';

  List<dynamic> get tripTypes => _tripTypes;
  String get selectedTripType => _selectedTripType;
  String get selectedTripPrice => _selectedTripPrice;

  Future<void> fetchTripTypes(BuildContext context) async {
    final token = await AppApi.getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse(AppApi.Trip_type),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _tripTypes = data["data"];
        if (_tripTypes.isNotEmpty) {
          _selectedTripType = _tripTypes.first["id"].toString();
          _selectedTripPrice = _tripTypes.first["price_label"].toString();
        }
        notifyListeners();
      }
    } on TimeoutException {
      showTimeoutDialog(context);
    } catch (e) {
      print("Something went wrong: $e");
    }
  }

  void setSelectedTripType(String tripType) {
    _selectedTripType = tripType;

    final selectedTrip = _tripTypes.firstWhere(
      (trip) => trip["id"].toString() == tripType,
      orElse: () => null,
    );

    if (selectedTrip != null) {
      _selectedTripPrice = selectedTrip["price_label"].toString();
    }

    notifyListeners();
  }

  void showTimeoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.timer_off, color: Colors.orange),
            SizedBox(width: 10),
            Text("Timeout"),
          ],
        ),
        content: const Text("Server is taking too long to respond."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();

              Future.delayed(Duration(milliseconds: 300), () {
                fetchTripTypes(context);
              });
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}

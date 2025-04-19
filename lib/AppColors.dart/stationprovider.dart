// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StationProvider with ChangeNotifier {
  List<String> _stations = [];

  List<String> get stations => _stations;

  Future<void> fetchStations(double latitude, double longitude) async {
    final url = Uri.parse(AppApi.Near_stations);
    final token = await AppApi.getToken();
    if (token == null) return;

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'token': token},
        body: jsonEncode({
          "latitude": latitude,
          "longitude": longitude,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          _stations = List<String>.from(
              data['data'].map((station) => station['name'] as String));
          notifyListeners();
        }
      }
    } catch (error) {
      print("API Error: $error");
    }
  }
}

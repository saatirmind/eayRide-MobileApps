import 'dart:convert';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DropStationProvider with ChangeNotifier {
  List<Map<String, dynamic>> _stations = [];
  int? _selectedStationId;
  String? _selectedStationName;

  List<Map<String, dynamic>> get stations => _stations;
  int? get selectedStationId => _selectedStationId;
  String? get selectedStationName => _selectedStationName;

  Future<void> fetchDropStations() async {
    final token = await AppApi.getToken();
    if (token == null) return;

    final response = await http.post(
      Uri.parse(AppApi.drop_stations),
      headers: {'Content-Type': 'application/json', 'token': token},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _stations = List<Map<String, dynamic>>.from(data['data']);
      notifyListeners();
    } else {
      throw Exception('Failed to load stations');
    }
  }

  void selectStation(int id, String name) {
    _selectedStationId = id;
    _selectedStationName = name;
    notifyListeners();
  }
}

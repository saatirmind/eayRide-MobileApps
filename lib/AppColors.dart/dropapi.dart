import 'dart:convert';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:http/http.dart' as http;

Future<List<LocationdropModel>> fetchDropLocationByPickupId(
    String pickupId) async {
  print("Step 1: Fetching token...");
  final token = await AppApi.getToken();
  print("Token: $token");

  const url = AppApi.PickupDropLocation;
  final headers = {
    'token': token!,
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
    "state": "delhi",
    "trip_type": "minute_wise",
    "pickup_locaion": pickupId
  });

  print("Step 2: Making POST request to $url");
  print("Request Headers: $headers");
  print("Request Body: $body");

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: body,
  );

  print("Step 3: Response received");
  print("Status Code: ${response.statusCode}");
  print("Response Body: ${response.body}");

  if (response.statusCode == 200) {
    try {
      final jsonData = jsonDecode(response.body);
      print("Step 4: JSON decoded");
      print(jsonData);

      final List<dynamic> locationList = jsonData['data']['pickup_locations'];
      print("Step 5: Locations fetched, count = ${locationList.length}");

      final result = locationList.map((e) {
        final model = LocationdropModel.fromJson(e);
        print("Parsed Location: $model");
        return model;
      }).toList();

      print("Step 6: Returning result list...");
      return result;
    } catch (e) {
      print("Error while decoding response: $e");
      throw Exception("Failed to parse locations");
    }
  } else {
    print(
        "Error: Failed to load locations. Status Code: ${response.statusCode}");
    throw Exception("Failed to load locations");
  }
}

class LocationdropModel {
  final int id;
  final int state;
  final String name;
  final int status;
  final double? latitude;
  final double? longitude;

  LocationdropModel({
    required this.id,
    required this.state,
    required this.name,
    required this.status,
    this.latitude,
    this.longitude,
  });

  factory LocationdropModel.fromJson(Map<String, dynamic> jsonData) {
    return LocationdropModel(
      id: jsonData['id'],
      state: int.parse(jsonData['state'].toString()),
      name: jsonData['name'],
      status: int.parse(jsonData['status'].toString()),
      latitude: jsonData['latitude'] != null
          ? double.tryParse(jsonData['latitude'].toString())
          : null,
      longitude: jsonData['longitude'] != null
          ? double.tryParse(jsonData['longitude'].toString())
          : null,
    );
  }

  @override
  String toString() {
    return 'LocationdropModel(id: $id, name: $name, state: $state, status: $status, latitude: $latitude, longitude: $longitude)';
  }
}

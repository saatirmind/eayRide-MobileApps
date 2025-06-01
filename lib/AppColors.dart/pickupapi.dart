import 'dart:convert';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:http/http.dart' as http;

class LocationModel {
  final int id;
  final int state;
  final String name;
  final int status;

  LocationModel({
    required this.id,
    required this.state,
    required this.name,
    required this.status,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'],
      state: int.parse(json['state'].toString()),
      name: json['name'],
      status: int.parse(json['status'].toString()),
    );
  }

  @override
  String toString() {
    return 'LocationModel(id: $id, name: $name, state: $state, status: $status)';
  }
}

Future<List<LocationModel>> fetchPickupDropLocation() async {
  final token = await AppApi.getToken();
  print("Token: $token");

  const url = AppApi.PickupDropLocation;
  final headers = {
    'token': token!,
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({"state": "delhi", "trip_type": "minute_wise"});
  print("Sending Request to: $url");
  print("Request Body: $body");
  print("Request Headers: $headers");

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: body,
  );

  print("Response Status Code: ${response.statusCode}");
  print("Response Body: ${response.body}");

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    final List<dynamic> locationList = jsonData['data']['pickup_locations'];

    print("Pickup Locations Length: ${locationList.length}");

    final result = locationList.map((e) => LocationModel.fromJson(e)).toList();

    for (var loc in result) {
      print(loc);
    }

    return result;
  } else {
    print("Error: Failed to load locations");
    throw Exception("Failed to load locations");
  }
}

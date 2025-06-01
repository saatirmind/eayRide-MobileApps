import 'dart:convert';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:http/http.dart' as http;

Future<List<LocationfinalModel>> fetchFinalByDropid(
    String pickupId, dropId) async {
  final token = await AppApi.getToken();

  const url = AppApi.PickupDropLocation;
  final headers = {
    'token': token!,
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({
    "state": "delhi",
    "trip_type": "minute_wise",
    "pickup_locaion": pickupId,
    "drop_location": dropId,
  });

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: body,
  );

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);
    final List<dynamic> locationList = jsonData['data'];
    ;

    return locationList.map((e) => LocationfinalModel.fromJson(e)).toList();
  } else {
    throw Exception("Failed to load locations");
  }
}

class LocationfinalModel {
  final int id;
  final int state;
  final String name;
  final int status;

  LocationfinalModel({
    required this.id,
    required this.state,
    required this.name,
    required this.status,
  });

  factory LocationfinalModel.fromJson(Map<String, dynamic> json) {
    return LocationfinalModel(
      id: json['id'],
      state: int.parse(json['state'].toString()),
      name: json['name'],
      status: int.parse(json['status'].toString()),
    );
  }
}

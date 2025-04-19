// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VehicleLocationProvider extends ChangeNotifier {
  double? latitude;
  double? longitude;

  Future<void> fetchVehicleLocation() async {
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
            print(
                "📍 Vehicle Location: Latitude: $latitude, Longitude: $longitude");

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
}

class CityLocationProvider extends ChangeNotifier {
  double? latitude;
  double? longitude;
  String? cityName;

  Future<void> fetchcityLocation() async {
    dynamic vehicleId = await AppApi.getVehicleId();

    if (vehicleId == null) {
      print("🚨 Error: Vehicle ID not found in SharedPreferences!");
      return;
    }

    final url = "${AppApi.Vehicleid}$vehicleId";
    print("🌐 API URL: $url");

    try {
      final response = await http.get(Uri.parse(url));
      print("📦 API Response Status Code: ${response.statusCode}");
      print("📦 API Raw Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData["status"] == true && responseData["data"] != null) {
          print("✅ Data Found in API Response");

          latitude = double.tryParse(responseData["data"]["lat"].toString());
          longitude = double.tryParse(responseData["data"]["lng"].toString());

          print("📍 Parsed Latitude: $latitude");
          print("📍 Parsed Longitude: $longitude");

          if (latitude != null && longitude != null) {
            print(
                "📍 Vehicle Location: Latitude: $latitude, Longitude: $longitude");

            cityName = await getCityNameFromCoordinates(latitude!, longitude!);
            if (cityName != null && cityName!.isNotEmpty) {
              print("🏙️ City Name: $cityName");
            } else {
              print("❗City name is null or empty");
            }

            notifyListeners();
          } else {
            print("⚠️ Latitude or Longitude is null");
          }
        } else {
          print("⚠️ API Response status is false or data is null");
        }
      } else {
        print("❌ Location API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("🚨 Error fetching vehicle location: $e");
    }
  }

  Future<String?> getCityNameFromCoordinates(double lat, double lng) async {
    print("📡 Starting reverse geocoding for: lat=$lat, lng=$lng");
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        print("🏢 Full Placemark:");
        print("Locality: ${place.locality}");
        print("SubLocality: ${place.subLocality}");
        print("Thoroughfare: ${place.thoroughfare}");
        print("SubThoroughfare: ${place.subThoroughfare}");
        print("AdministrativeArea: ${place.administrativeArea}");
        print("SubAdministrativeArea: ${place.subAdministrativeArea}");
        print("Country: ${place.country}");
        print("Name: ${place.name}");

        String? city;

        if (place.locality != null && place.locality!.trim().isNotEmpty) {
          city = place.locality;
        } else if (place.subLocality != null &&
            place.subLocality!.trim().isNotEmpty) {
          city = place.subLocality;
        } else if (place.thoroughfare != null &&
            place.thoroughfare!.trim().isNotEmpty) {
          city = place.thoroughfare;
        } else if (place.subThoroughfare != null &&
            place.subThoroughfare!.trim().isNotEmpty) {
          city = place.subThoroughfare;
        } else if (place.administrativeArea != null &&
            place.administrativeArea!.trim().isNotEmpty) {
          city = place.administrativeArea;
        } else if (place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.trim().isNotEmpty) {
          city = place.subAdministrativeArea;
        } else if (place.name != null && place.name!.trim().isNotEmpty) {
          city = place.name;
        } else if (place.country != null && place.country!.trim().isNotEmpty) {
          city = place.country;
        }

        print("🏙️ Final Selected City Name: $city");
        return city;
      } else {
        print("❗ No placemarks found.");
      }
    } catch (e) {
      print("⚠️ Error while reverse geocoding: $e");
    }
    return null;
  }
}

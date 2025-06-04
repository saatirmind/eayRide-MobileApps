// ignore_for_file: constant_identifier_names, file_names
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EasyrideColors {
  const EasyrideColors();

  static const Color vibrantGreen =
      Color(0xFF22B14D); // Energy & Sustainability
  static const Color deepBlack = Color(0xFF020202); // Sophistication & Strength

  // Secondary Colors
  static const Color mediumGray = Color(0xFF6B6B6A); // Neutral Tone
  static const Color pureWhite = Color(0xFFFFFFFF); // Contrast Background

  static const Color background = Color(0xFFf2f6ff);
  static const Color buttonColor = Color.fromARGB(255, 11, 155, 11);
  static const Color buttontextColor = Color.fromARGB(255, 248, 249, 250);
  static const Color successSnak = Color.fromARGB(255, 54, 127, 69);
  static const Color Alertsank = Color(0xFFE74C3C);
  static const Color Drawerbackground = Color(0xFFf2f6ff);
  static const Color Drawerheaderbackground = Color.fromARGB(255, 11, 155, 11);
  static const Color Drawerheadertext = Color(0xFFf2f6ff);
  static const Color Drawertext = Color.fromARGB(193, 1, 5, 9);
  static const Color Drawericon = Color.fromARGB(255, 34, 97, 160);
  static const Color Pramotionbannertext = Color.fromARGB(255, 248, 249, 250);
  static const Color Dropertext = Color.fromARGB(255, 248, 249, 250);
  static const Color Scannerframe = Color.fromARGB(255, 11, 155, 11);
}

class AppApi {
  static const String baseUrl = 'https://easymotorbike.asia/api/v1';
  static const String Dummyprofile =
      'https://easymotorbike.asia/public/backend/images/default/profile-default.webp';
  static const String termsurl = 'https://www.emrkl.com/';
  static const String imagebaseurl = 'https://easymotorbike.asia/';
  static const String term_condition =
      'https://easymotorbike.asia/page/term-conditions';
  static const String privacy_policy =
      'https://easymotorbike.asia/page/privacy-policy';
  static const String faq = 'https://easymotorbike.asia/faq';
  static const String customerhelp =
      'https://easymotorbike.asia/chat-with-customer';

  // All API Endpoints
  static const String getWallet = '$baseUrl/get-wallet';
  //static const String ridebooking = '$baseUrl/ride-booking';
  static const String ridetracking = '$baseUrl/ride-tracking';
  static const String sendOtp = '$baseUrl/send-otp';
  static const String login = '$baseUrl/login';
  static const String PickupDropLocation = '$baseUrl/find-pickup-drop-location';
  static const String startRide = '$baseUrl/start-ride';
  static const String walletactivity = '$baseUrl/wallet-activity';
  static const String Updateprofile = '$baseUrl/update';
  static const String Couponslist = '$baseUrl/get-coupon-list';
  static const String CouponsApply = '$baseUrl/apply-coupon';
  static const String AppliedCoupons = '$baseUrl/applied-coupon-history';
  static const String Finishride = '$baseUrl/ride-finish';
  static const String Bannerlist = '$baseUrl/get-banner';
  static const String Logout = '$baseUrl/logout';
  static const String Getprofile = '$baseUrl/get-profile';
  static const String Signup = '$baseUrl/signup';
  static const String Vehiclelocation = '$baseUrl/vehicle-location';
  static const String CorrectParking = '$baseUrl/correct-parking';
  static const String RangerTracking = '$baseUrl/ride-tracking-ranger';
  static const String BookingHistory = '$baseUrl/ride-booking-history';
  static const String Vehicleid = '$baseUrl/vehicles-location?vehicle_id=';
  static const String Near_stations = '$baseUrl/find-nearest-vehicle-stations';
  static const String Trip_type = '$baseUrl/get-trip-types';
  static const String new_ride_booking = '$baseUrl/new-ride-booking';
  static const String drop_stations = '$baseUrl/drop-stations';
  static const String new_ride_finish = '$baseUrl/new-ride-finish';
  static const String vehicle_on_off = '$baseUrl/vehicle-on-off';

  static const String googleMapsBaseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';
  static const String googleAPIKey = 'AIzaSyB2muVv0XAF5gzHWHEwEBTH5bw_qiUL7JQ';

  static String getDirectionsUrl(
    double originLat,
    double originLng,
    double destinationLat,
    double destinationLng,
  ) {
    return '$googleMapsBaseUrl?origin=$originLat,$originLng&destination=$destinationLat,$destinationLng&key=$googleAPIKey';
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveVehicleId(dynamic vehicleId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('vehicle_id', jsonEncode(vehicleId));
  }

  static Future<dynamic> getVehicleId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? vehicleIdString = prefs.getString('vehicle_id');

    if (vehicleIdString != null) {
      try {
        return jsonDecode(vehicleIdString);
      } catch (e) {
        return vehicleIdString;
      }
    }
    return null;
  }

  static Future<String?> getBookingToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('booking_token');
  }
}

// ignore_for_file: use_build_context_synchronously, file_names, avoid_print, empty_catches
import 'dart:convert';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/NewScreen/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  print('Retrieved Token: $token');

  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No token found. Please log in again.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final url = Uri.parse(AppApi.Logout);

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'token': token}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully.'),
            backgroundColor: Colors.green,
          ),
        );

        // **Clear all data except 'BannerImageBase64'**
        String? bannerImage = prefs.getString('BannerImageBase64');
        await prefs.clear();
        if (bannerImage != null) {
          await prefs.setString('BannerImageBase64', bannerImage);
        }

        print("All SharedPreferences data cleared except 'BannerImageBase64'!");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully.'),
          backgroundColor: Colors.green,
        ),
      );

      // **Same process if response is not 200**
      String? bannerImage = prefs.getString('BannerImageBase64');
      await prefs.clear();
      if (bannerImage != null) {
        await prefs.setString('BannerImageBase64', bannerImage);
      }

      print("All SharedPreferences data cleared except 'BannerImageBase64'!");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false,
      );
    }
  } catch (e) {
    print("Error: $e");
  }
}

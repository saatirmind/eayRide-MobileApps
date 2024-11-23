import 'dart:convert';
import 'package:easyride/Screen/phonescreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  print('Retrieved Token: $token');

  if (token == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No token found. Please log in again.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final url = Uri.parse('https://easyride.saatirmind.com.my/api/v1/logout');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'token': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged out successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        await prefs.clear();
        print("All SharedPreferences data cleared successfully!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PhoneNumberScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect to the server.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('An error occurred: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, avoid_print
import 'dart:convert';
import 'package:easymotorbike/NewScreen/login.dart';
import 'package:http/http.dart' as http;
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProvider with ChangeNotifier {
  String _firstName = 'Update Profile';

  String get firstName => _firstName;

  void updateFirstName(String name) {
    _firstName = name;
    notifyListeners();
  }
}

Future<void> GetProfile(BuildContext context) async {
  final token = await AppApi.getToken();
  if (token == null) return;

  try {
    final response = await http.post(
      Uri.parse(AppApi.Getprofile),
      headers: {'Content-Type': 'application/json', 'token': token},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        final userInfo = data['data']['user_info'];
        String newName = userInfo['firstname']?.isNotEmpty == true
            ? userInfo['firstname']
            : 'Update Profile';

        Provider.of<UserProvider>(context, listen: false)
            .updateFirstName(newName);
      }
    } else if (response.statusCode == 401) {
      final data = jsonDecode(response.body);
      if (data['message'][0] == "Invalid Token! Please try again.") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Session expired. Please login again.",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
        );
      }
    }
  } catch (error) {
    print('Error: $error');
  }
}

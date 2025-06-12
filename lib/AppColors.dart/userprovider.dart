// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, avoid_print
import 'dart:convert';
import 'package:easymotorbike/NewScreen/login.dart';
import 'package:http/http.dart' as http;
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProvider with ChangeNotifier {
  String _firstName = 'Update Profile';
  String _email = '';

  String get firstName => _firstName;
  String get email => _email;

  void updateFirstName(String name) {
    _firstName = name;
    notifyListeners();
  }

  void updateEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void updateUser({required String name, required String email}) {
    _firstName = name;
    _email = email;
    notifyListeners();
  }
}

Future<void> GetProfile(BuildContext context) async {
  final token = await AppApi.getToken();
  print("📦 Token: $token");

  if (token == null) {
    print("❌ Token null hai");
    return;
  }

  try {
    final response = await http.post(
      Uri.parse(AppApi.Getprofile),
      headers: {'Content-Type': 'application/json', 'token': token},
    );

    print("📡 API Called: ${AppApi.Getprofile}");
    print("🧾 Status Code: ${response.statusCode}");
    print("📥 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ Response Parsed: $data");

      if (data['data'] != null && data['data']['user_info'] != null) {
        final userInfo = data['data']['user_info'];

        String newName = userInfo['firstname']?.isNotEmpty == true
            ? userInfo['firstname']
            : 'Update Profile';
        String email = userInfo['email'] ?? '';

        print("🔄 Updating firstName: $newName");
        print("📧 Updating email: $email");

        Provider.of<UserProvider>(context, listen: false)
            .updateUser(name: newName, email: email);
      } else {
        print("⚠️ User Info missing in response");
      }
    } else if (response.statusCode == 401) {
      final data = jsonDecode(response.body);
      print("🔐 Unauthorized: $data");

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
    } else {
      print("❌ Unexpected status code: ${response.statusCode}");
    }
  } catch (error) {
    print('💥 Error: $error');
  }
}

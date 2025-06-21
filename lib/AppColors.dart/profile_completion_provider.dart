// file: profile_completion_provider.dart

import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileCompletionProvider extends ChangeNotifier {
  double? _profilePercent;

  double? get profilePercent => _profilePercent;

  Future<void> fetchProfileCompletion() async {
    final token = await AppApi.getToken();
    final response = await http.get(
      Uri.parse('https://easymotorbike.asia/api/v1/profile-completion'),
      headers: {
        'token': token!,
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      _profilePercent =
          (jsonBody['data']['profile_completion'] ?? 0.0).toDouble();
      notifyListeners(); // 🔁 सब listeners update होंगे
    } else {
      throw Exception('Failed to load profile completion');
    }
  }

  void reset() {
    _profilePercent = null;
    notifyListeners();
  }
}

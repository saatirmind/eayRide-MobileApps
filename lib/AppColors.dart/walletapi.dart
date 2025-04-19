// ignore_for_file: avoid_print, use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/AppColors.dart/tripprovide.dart';
import 'package:easymotorbike/NewScreen/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class WalletProvider extends ChangeNotifier {
  String _walletAmount = "0";
  List<dynamic> _walletHistory = [];

  String get walletAmount => _walletAmount;
  List<dynamic> get walletHistory => _walletHistory;

  Future<void> fetchWalletHistory(BuildContext context) async {
    final token = await AppApi.getToken();
    print('Hit API Wallet HISTORY for Global');

    if (token == null) {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(AppApi.getWallet),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          _walletAmount =
              data['data']['user_wallet']['credit_label'].toString();
          _walletHistory = data['data']['wallet_history'] ?? [];
          notifyListeners();
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

          await Future.delayed(const Duration(seconds: 1));

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
            (route) => false,
          );
        }
      }
    } on SocketException {
      showNoInternetDialog(context);
    } on TimeoutException {
      showTimeoutDialog(context);
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  void showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red),
            SizedBox(width: 10),
            Text("No Internet"),
          ],
        ),
        content: const Text("Please check your internet connection."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Future.delayed(const Duration(milliseconds: 300), () {
                fetchWalletHistory(context);
                Provider.of<TripProvider>(context, listen: false)
                    .fetchTripTypes(context);
              });
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  void showTimeoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.timer_off, color: Colors.orange),
            SizedBox(width: 10),
            Text("Timeout"),
          ],
        ),
        content: const Text("Server is taking too long to respond."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Future.delayed(const Duration(milliseconds: 300), () {
                fetchWalletHistory(context);
              });
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}

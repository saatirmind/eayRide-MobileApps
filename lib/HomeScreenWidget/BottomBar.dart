// ignore_for_file: file_names, use_build_context_synchronously
import 'dart:convert';

import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/AppColors.dart/walletapi.dart';
import 'package:easymotorbike/Payment/cardscreen.dart';
import 'package:easymotorbike/Payment/nextscreen.dart';
import 'package:easymotorbike/Screen/Qrscannerscreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({
    super.key,
  });

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return _buildBottomBar();
  }

  Widget _buildBottomBar() {
    //  final walletProvider = Provider.of<WalletProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        // padding: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                // _buildBottomBarItem(
                //     Icons.card_giftcard, "7 Day Streak: 0 Trip(s)"),
                // _buildBottomBarItem(
                //   Icons.attach_money,
                //   walletProvider.walletAmount,
                // ),
                //const SizedBox(height: 10),

                _buildBottomButton("Scan to ride"),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     _buildBottomButton("GROUP"),
                //     _buildBottomButton("START"),
                //   ],
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBarItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: EasyrideColors.Drawericon,
        ),
        const SizedBox(width: 5),
        Text(text),
      ],
    );
  }

  Widget _buildBottomButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (text == "Scan to ride") {
            _handleStartButton();
          } else if (text == "GROUP") {
            _handleGroupButton();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: EasyrideColors.buttonColor,
          foregroundColor: EasyrideColors.buttontextColor,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text(text),
      ),
    );
  }

  void _handleStartButton() async {
    final prefs = await SharedPreferences.getInstance();
    final pickupId = prefs.getString('pickupCityId');
    final destinationId = prefs.getString('destinationCityId');

    if (pickupId == null ||
        pickupId.isEmpty ||
        destinationId == null ||
        destinationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select Pickup and Destination Location first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 🔁 Token lena
    final token = await AppApi.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token missing. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://easymotorbike.asia/api/v1/check-wallet-amount'),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
      );
      final data = jsonDecode(response.body);
      final String message = data['message']?[0] ?? 'Something went wrong';
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bool status = data['status'] ?? false;
        final String message = data['message']?[0] ?? 'Something went wrong';

        if (status == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QRScannerScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$message'),
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

  void _handleGroupButton() {
    _showGroupRideBottomSheet();
  }

  void _showGroupRideBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.00001),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Stack(
            children: [
              Container(
                color: Colors.transparent,
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.4,
                minChildSize: 0.4,
                maxChildSize: 0.9,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Credit Card Required',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Group Rides requires a credit/debit card attached to your account, please authenticate your card to proceed.',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String? savedCardNumber =
                                    prefs.getString('cardNumber');

                                if (savedCardNumber == null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AddCardScreen(),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PaymentMethodScreen(),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: EasyrideColors.buttonColor,
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'ADD A CARD',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Image.asset(
                                    'assets/visacardlogo.webp',
                                    width: 48,
                                    height: 45,
                                  ),
                                  const SizedBox(width: 10),
                                  Image.asset(
                                    'assets/mastercardlogo.png',
                                    width: 48,
                                    height: 45,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

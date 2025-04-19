// ignore_for_file: file_names, use_build_context_synchronously
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/AppColors.dart/walletapi.dart';
import 'package:easymotorbike/Payment/cardscreen.dart';
import 'package:easymotorbike/Payment/nextscreen.dart';
import 'package:easymotorbike/Screen/Qrscannerscreen.dart';
import 'package:flutter/material.dart';
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
    final walletProvider = Provider.of<WalletProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                _buildBottomBarItem(
                    Icons.card_giftcard, "7 Day Streak: 0 Trip(s)"),
                _buildBottomBarItem(
                  Icons.attach_money,
                  walletProvider.walletAmount,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBottomButton("GROUP"),
                    _buildBottomButton("START"),
                  ],
                ),
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
    return ElevatedButton(
      onPressed: () {
        if (text == "START") {
          _handleStartButton();
        } else if (text == "GROUP") {
          _handleGroupButton();
        }
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: EasyrideColors.buttonColor,
          foregroundColor: EasyrideColors.buttontextColor),
      child: Text(text),
    );
  }

  void _handleStartButton() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerScreen(),
      ),
    );
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

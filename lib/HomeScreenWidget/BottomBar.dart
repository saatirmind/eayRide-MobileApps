import 'package:easyride/AppColors.dart/EasyrideAppColors.dart';
import 'package:easyride/Payment/cardscreen.dart';
import 'package:easyride/Payment/nextscreen.dart';
import 'package:easyride/Screen/Qrscannerscreen.dart';
import 'package:easyride/Screen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomBar extends StatefulWidget {
  final String? pickupCity;
  final String? destinationCity;
  final String? Walletamount;
  final String? finalPrice;

  const BottomBar(
      {Key? key,
      this.pickupCity,
      this.destinationCity,
      this.Walletamount,
      this.finalPrice})
      : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return _buildBottomBar();
  }

  Widget _buildBottomBar() {
    return Padding(
      key: HomeScreen.homeScreenKey,
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
                _buildBottomBarItem(Icons.attach_money,
                    "RM ${widget.Walletamount?.isNotEmpty == true ? widget.Walletamount : '0.00'}"),
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
      child: Text(text),
      style: ElevatedButton.styleFrom(
          backgroundColor: EasyrideColors.buttonColor,
          foregroundColor: EasyrideColors.buttontextColor),
    );
  }

  void _handleStartButton() {
    if (widget.pickupCity == null || widget.destinationCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select both Pickup and Destination Location!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: EasyrideColors.Alertsank,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (widget.finalPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please wait, fetching data...!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: EasyrideColors.Alertsank,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRScannerScreen(finalPrice: widget.finalPrice),
        ),
      );
    }
  }

  void _handleGroupButton() {
    if (widget.pickupCity == null || widget.destinationCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select both Pickup and Destination Location!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (widget.finalPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please wait, fetching data...!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: EasyrideColors.Alertsank,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      _showGroupRideBottomSheet();
    }
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
                                      builder: (context) => AddCardScreen(),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PaymentMethodScreen(),
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

import 'package:easyride/Payment.dart/cardscreen.dart';
import 'package:easyride/Screen/Qrscannerscreen.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

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
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 25),
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
                _buildBottomBarItem(Icons.attach_money, "RM0.00"),
                _buildBottomBarItem(Icons.local_offer, "Promotions"),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBottomButton("GROUP"),
                _buildBottomButton("START"),
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
        Icon(icon, color: Colors.yellow),
        SizedBox(width: 5),
        Text(text),
      ],
    );
  }

  Widget _buildBottomButton(String text) {
    return ElevatedButton(
      onPressed: () {
        if (text == "START") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QRScannerScreen()),
          );
        } else if (text == "GROUP") {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => buildBottomSheet(context),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow,
      ),
      child: Text(text, style: TextStyle(color: Colors.black)),
    );
  }

  Widget buildBottomSheet(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.4,
      maxChildSize: 0.8,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.yellow,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Credit Card Required',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Group Rides requires a credit/debit card attached to your account, please authenticate your card to proceed.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddCardScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      textStyle:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ADD A CARD',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        SizedBox(width: 10),
                        Image.asset(
                          'assets/visacardlogo.webp',
                          width: 48,
                          height: 45,
                        ),
                        SizedBox(width: 10),
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
    );
  }
}

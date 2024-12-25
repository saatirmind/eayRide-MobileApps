import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:easyride/AppColors.dart/EasyrideAppColors.dart';
import 'package:easyride/Payment/Easyridecredits.dart';
import 'package:easyride/Payment/cardscreen.dart';
import 'package:easyride/Payment/nextscreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool isTrykeCreditsFocused = true;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          title: const Text('WALLET'),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    color: EasyrideColors.Drawerbackground,
                    child: Column(
                      children: const [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'RIDE MORE WITH\n',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              TextSpan(
                                text: 'EASYRIDE PASS',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap to find out more',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.green,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: const Text(
                    'Start riding from as low as RM0.25 per minute!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Learn More'),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: const Text(
                  'Choose Payment Method:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isTrykeCreditsFocused = true;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isTrykeCreditsFocused
                                ? Colors.green
                                : Colors.grey,
                            width: isTrykeCreditsFocused ? 2.0 : 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('EASYRIDE Credits'),
                            InkWell(
                              onTap: () async {
                                bool? isUpdated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreditsReloadScreen(),
                                  ),
                                );

                                if (isUpdated == true) {
                                  _fetchWalletHistory();
                                }
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'RM ${walletHistory.isEmpty ? '0.00' : walletHistory}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.add,
                                    color: isTrykeCreditsFocused
                                        ? Colors.green
                                        : Colors.yellow,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isTrykeCreditsFocused = false;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: !isTrykeCreditsFocused
                                ? Colors.green
                                : Colors.grey,
                            width: !isTrykeCreditsFocused ? 2.0 : 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Pay-as-you-go'),
                            InkWell(
                              onTap: () async {
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
                              child: Row(
                                children: [
                                  const Text('Add Card'),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.add,
                                    color: !isTrykeCreditsFocused
                                        ? Colors.green
                                        : Colors.yellow,
                                  ), //
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Text(
                  '- Any remaining EASYRIDE Credit will be deducted first before charging your Credit/Debit card\n\n'
                  '- Transaction refunds will take up to five working days.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String walletHistory = '';

  @override
  void initState() {
    super.initState();
    _fetchWalletHistory();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchWalletHistory() async {
    final token = await getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token is missing. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String apiUrl = AppApi.getWallet;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
      );

      print('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          final Map<String, dynamic> responseData = data;
          setState(() {
            walletHistory =
                responseData['data']['user_wallet']['credit'].toString();
          });
        } else {
          print('Error: ${data['message']}');
        }
      } else {
        print('Server Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }
}

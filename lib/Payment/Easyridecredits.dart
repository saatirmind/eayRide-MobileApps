import 'dart:convert';

import 'package:easyride/AppColors.dart/EasyrideAppColors.dart';
import 'package:easyride/Payment/wallethistory.dart';
import 'package:easyride/Screen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreditsReloadScreen extends StatefulWidget {
  const CreditsReloadScreen({Key? key}) : super(key: key);

  @override
  State<CreditsReloadScreen> createState() => _CreditsReloadScreenState();
}

class _CreditsReloadScreenState extends State<CreditsReloadScreen> {
  String _reloadAmount = '';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          title: const Text(
            'Credits Reload',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Current Balance:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                'RM ${walletHistory.isEmpty ? '0.00' : walletHistory}',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Reload Amount:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(hintText: 'Min.RM10'),
                        textAlign: TextAlign.center,
                        controller: TextEditingController(text: _reloadAmount),
                        readOnly: false,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildReloadButton('30'),
                  _buildReloadButton('50'),
                  _buildReloadButton('100'),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WalletHistoryScreen()));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.history, size: 25),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'History:',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Tap Here',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Payment Method:',
                        style: TextStyle(fontSize: 16),
                      ),
                      Row(
                        children: [
                          Text(
                            'Select Here',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  _AddWallettmoney();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  decoration: BoxDecoration(
                    color: EasyrideColors.buttonColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isLoading
                          ? const CircularProgressIndicator(
                              color: EasyrideColors.buttontextColor,
                            )
                          : Row(
                              children: [
                                Icon(Icons.wallet,
                                    size: 24, color: EasyrideColors.Drawericon),
                                SizedBox(width: 8),
                                Text(
                                  'ADD',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: EasyrideColors.buttontextColor),
                                ),
                              ],
                            )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Contact Support',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  bool _isLoading = false;

  void _onReloadAmountSelected(String amount) {
    setState(() {
      _reloadAmount = '$amount';
    });
  }

  Widget _buildReloadButton(String amount) {
    return GestureDetector(
      onTap: () => _onReloadAmountSelected(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          'RM $amount',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Future<void> _AddWallettmoney() async {
    setState(() {
      _isLoading = true;
    });

    final token = await getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token is missing. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (_reloadAmount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a reload amount.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final String apiUrl = AppApi.walletactivity;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: jsonEncode({
          'is_credit': 'credit',
          'amount': _reloadAmount,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          await Future.delayed((Duration(seconds: 2)));
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Amount Added Successfully'),
              backgroundColor: Colors.green,
            ),
          );
          await Future.delayed((Duration(microseconds: 500)));
          _fetchWalletHistory();
          HomeScreen.homeScreenKey.currentState?.Wallethistoryapi();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${data['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server Error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
    await Future.delayed((Duration(seconds: 2)));
  }
}

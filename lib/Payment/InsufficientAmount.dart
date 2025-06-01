// ignore_for_file: deprecated_member_use, file_names, unused_element, use_build_context_synchronously, avoid_print, non_constant_identifier_names
import 'dart:convert';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/AppColors.dart/walletapi.dart';
import 'package:easymotorbike/AppColors.dart/webview.dart';
import 'package:easymotorbike/Payment/wallethistory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InsufficientAmount extends StatefulWidget {
  final double amount;
  const InsufficientAmount({super.key, required this.amount});

  @override
  State<InsufficientAmount> createState() => _InsufficientAmountState();
}

class _InsufficientAmountState extends State<InsufficientAmount> {
  final TextEditingController _reloadController = TextEditingController();
  bool _showAmountError = false;
  @override
  void initState() {
    super.initState();
    _reloadController.text = widget.amount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
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
              walletProvider.walletAmount,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reload Amount:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Min. ${widget.amount.toStringAsFixed(2)}',
                        errorText: _showAmountError
                            ? 'Please enter at least ₹${widget.amount}'
                            : null,
                      ),
                      textAlign: TextAlign.center,
                      controller: _reloadController,
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
            const Spacer(),
            Lottie.asset(
              'assets/lang/walletfound.json',
              width: MediaQuery.of(context).size.width * 1,
              height: MediaQuery.of(context).size.width * 0.7,
              fit: BoxFit.contain,
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WalletHistoryScreen()));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
            const SizedBox(height: 5),
            // GestureDetector(
            //   onTap: () {},
            //   child: Container(
            //     padding: const EdgeInsets.symmetric(
            //         horizontal: 16.0, vertical: 12.0),
            //     decoration: BoxDecoration(
            //       border: Border.all(color: Colors.grey),
            //       borderRadius: BorderRadius.circular(8.0),
            //     ),
            //     child: const Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Text(
            //           'Other Payment Methods:',
            //           style: TextStyle(fontSize: 16),
            //         ),
            //         Row(
            //           children: [
            //             Text(
            //               'Select Here',
            //               style: TextStyle(
            //                   fontSize: 16, fontWeight: FontWeight.bold),
            //             ),
            //             Icon(Icons.arrow_forward_ios, size: 16),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 32),
            GestureDetector(
              onTap: _isLoading
                  ? null
                  : () async {
                      final amount = _reloadController.text.trim();

                      if (amount.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Please enter amount first")),
                        );
                        return;
                      }

                      final enteredAmount = double.tryParse(amount);

                      if (enteredAmount == null ||
                          enteredAmount < widget.amount) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "❗ Minimum ₹${widget.amount.toStringAsFixed(2)} required for processing.",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.all(16),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String? userId = prefs.getString('user_id');

                        if (userId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("User ID not found")),
                          );
                          setState(() {
                            _isLoading = false;
                          });
                          return;
                        }

                        String url =
                            'https://easymotorbike.asia/payment/create-payment?request_id=$userId&amount=$amount';

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WebViewPage3(url: url),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
              child: IgnorePointer(
                ignoring: _isLoading,
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
                          : const Row(
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
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  bool _isLoading = false;

  void _onReloadAmountSelected(String amount) {
    setState(() {});
  }

  Widget _buildReloadButton(String amount) {
    return GestureDetector(
      onTap: () => _reloadController.text = amount,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          amount,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _AddWallettmoney() async {
    final reloadAmount = _reloadController.text.trim();
    final parsedAmount = double.tryParse(reloadAmount) ?? 0.0;

    if (reloadAmount.isEmpty || parsedAmount < widget.amount) {
      setState(() {
        _showAmountError = true;
        _isLoading = false;
      });
      return;
    } else {
      setState(() {
        _showAmountError = false;
      });
    }

    setState(() {
      _isLoading = true;
    });

    final token = await AppApi.getToken();

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

    if (reloadAmount.isEmpty) {
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

    try {
      final response = await http.post(
        Uri.parse(AppApi.walletactivity),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: jsonEncode({
          'is_credit': 'credit',
          'amount': reloadAmount,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          await Future.delayed((const Duration(seconds: 2)));
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Amount Added Successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _reloadController.clear();
          await Future.delayed((const Duration(microseconds: 500)));
          Provider.of<WalletProvider>(context, listen: false)
              .fetchWalletHistory(context);
          Navigator.pop(context);
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
  }
}

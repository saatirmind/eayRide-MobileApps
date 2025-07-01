// ignore_for_file: avoid_print, non_constant_identifier_names, unnecessary_string_interpolations, use_build_context_synchronously
import 'dart:convert';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/AppColors.dart/walletapi.dart';
import 'package:easymotorbike/AppColors.dart/webview.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'Easyridecredits.dart';

class CreditPackScreen extends StatefulWidget {
  const CreditPackScreen({super.key});

  @override
  State<CreditPackScreen> createState() => _CreditPackScreenState();
}

class _CreditPackScreenState extends State<CreditPackScreen> {
  final TextEditingController _reloadController = TextEditingController();
  Future<List<Coupon>> _loadCoupons() async {
    final api = ApiService();
    return await api.fetchplanlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Buy a credit pack'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Coupon>>(
        future: _loadCoupons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final couponList = snapshot.data ?? [];

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Credit pack',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ...couponList.map((pack) => GestureDetector(
                    onTap: () async {
                      try {
                        String cleanAmount = pack.discountedAmount
                            .replaceAll(RegExp(r'[^\d.]'), '');

                        final requestId = await getPaymentToken(cleanAmount);

                        String url =
                            'https://easymotorbike.asia/payment/create-payment?request_id=$requestId';

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WebViewPage2(url: url),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 6),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 💰 Price Info
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pack.amount,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Pay only ${pack.discountedAmount}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: EasyrideColors.Drawerheaderbackground,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${pack.discountPercentage} off',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: EasyrideColors.Drawerheadertext,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
              const Spacer(),
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
                      decoration: const InputDecoration(hintText: 'Min.RM1'),
                      textAlign: TextAlign.center,
                      controller: _reloadController,
                      readOnly: false,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    const Text(
                      'All paid credits expire after 3 years of purchase',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () async {
                              final amount = _reloadController.text.trim();

                              if (amount.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Please enter amount first")),
                                );
                                return;
                              }

                              setState(() {
                                _isLoading = true;
                              });

                              try {
                                final requestId = await getPaymentToken(amount);

                                final paymentUrl =
                                    'https://easymotorbike.asia/payment/create-payment?request_id=$requestId';

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        WebViewPage2(url: paymentUrl),
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
                                            size: 24,
                                            color: EasyrideColors.Drawericon),
                                        SizedBox(width: 8),
                                        Text(
                                          'Proceed to Payment',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: EasyrideColors
                                                  .buttontextColor),
                                        ),
                                      ],
                                    )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _isLoading = false;
  Future<String> getPaymentToken(String amount) async {
    print("🚀 Step 1: Getting app token...");
    final token = await AppApi.getToken();

    if (token == null || token.isEmpty) {
      print("❌ Error: Token is null or empty!");
      throw Exception("Auth token missing");
    }

    print("✅ App Token: $token");

    const url = 'https://easymotorbike.asia/api/v1/get-payment-token';

    final headers = {
      'token': token,
    };

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(headers);

    request.fields['amount'] = amount;

    print("📡 Step 2: Sending payment token request...");
    print("➡️ URL: $url");
    print("➡️ Headers: $headers");
    print("➡️ Fields: ${request.fields}");

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("📥 Step 3: Response received");
    print("📄 Status Code: ${response.statusCode}");
    print("📄 Body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);

        print("✅ JSON Decoded: $jsonData");

        if (jsonData['data'] == null || jsonData['data']['token'] == null) {
          print("❌ Error: Token not found in response data");
          throw Exception("Invalid response structure");
        }

        final paymentToken = jsonData['data']['token'];
        print("🎯 Step 4: Received Payment Token: $paymentToken");

        return paymentToken;
      } catch (e) {
        print("❌ Error parsing response: $e");
        throw Exception("Error decoding payment token");
      }
    } else {
      print("❌ Step 5: Failed to get payment token");
      throw Exception(
          "Failed to get payment token - Status Code: ${response.statusCode}");
    }
  }
}

class ApiService {
  static const String apiUrl = AppApi.planelist;

  Future<List<Coupon>> fetchplanlist() async {
    final token = await AppApi.getToken();
    print(token);

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'token': token ?? '',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => Coupon.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load coupons');
    }
  }

  Future<bool> applyCoupon(String coupon_code, BuildContext context) async {
    final token = await AppApi.getToken();

    final response = await http.post(
      Uri.parse('${AppApi.CouponsApply}'),
      headers: {
        'Content-Type': 'application/json',
        'token': token ?? '',
      },
      body: jsonEncode({
        'coupon_code': coupon_code,
      }),
    );

    print('Status Code: ${response.statusCode}');
    print('Response body: ${response.body}');

    try {
      final data = jsonDecode(response.body);
      String message = '';

      if (data['message'] is List) {
        message = (data['message'] as List).join('\n');
      } else if (data['message'] is String) {
        message = data['message'];
      }

      if (response.statusCode == 200) {
        Provider.of<WalletProvider>(context, listen: false)
            .fetchWalletHistory(context);
        final snackBar = SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CreditsReloadScreen()),
          );
        });
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message.isNotEmpty ? message : 'Failed to apply coupon',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );

        return false;
      }
    } catch (e) {
      print('Error decoding response: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}

class Coupon {
  final String amount;
  final String discountedAmount;
  final String discountPercentage;

  Coupon({
    required this.amount,
    required this.discountedAmount,
    required this.discountPercentage,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      amount: 'RM${json['amount']}',
      discountedAmount: 'RM${json['discounted_amount']}',
      discountPercentage: json['discount_percentage'],
    );
  }
}

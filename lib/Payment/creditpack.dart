// ignore_for_file: avoid_print, non_constant_identifier_names, unnecessary_string_interpolations, use_build_context_synchronously
import 'dart:convert';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/AppColors.dart/walletapi.dart';
import 'package:easymotorbike/AppColors.dart/webview.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Easyridecredits.dart';

class CreditPackScreen extends StatelessWidget {
  const CreditPackScreen({super.key});

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
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String? userId = prefs.getString('user_id');

                        if (userId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("User ID not found")),
                          );
                          return;
                        }

                        // 🔄 Clean RM from amount
                        String cleanAmount = pack.discountedAmount
                            .replaceAll(RegExp(r'[^\d.]'), '');

                        String url =
                            'https://easymotorbike.asia/payment/create-payment?request_id=$userId&amount=$cleanAmount';

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

              // const SizedBox(height: 10),
              // const Divider(thickness: 1, color: Colors.grey),
              // const SizedBox(height: 10),
              // const Text(
              //   'Credits are valid for 3 years from the date of purchase',
              //   style: TextStyle(fontSize: 14, color: Colors.grey),
              // ),
              // Spacer(),
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              EasyrideColors.Drawerheaderbackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreditsReloadScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Proceed to payment',
                          style: TextStyle(color: Colors.white, fontSize: 16),
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

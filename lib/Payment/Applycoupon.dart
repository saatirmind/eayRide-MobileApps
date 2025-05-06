// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, non_constant_identifier_names, avoid_print, unnecessary_string_interpolations
import 'dart:convert';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/AppColors.dart/walletapi.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ApiService {
  static const String apiUrl = AppApi.Couponslist;

  Future<List<Coupon>> fetchCoupons() async {
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
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        );
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

class CouponListScreen extends StatefulWidget {
  const CouponListScreen({super.key});

  @override
  _CouponListScreenState createState() => _CouponListScreenState();
}

class _CouponListScreenState extends State<CouponListScreen> {
  late Future<List<Coupon>> futureCoupons;

  @override
  void initState() {
    super.initState();
    futureCoupons = ApiService().fetchCoupons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.black,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        centerTitle: true,
        title: const Text('Coupons List'),
      ),
      body: FutureBuilder<List<Coupon>>(
        future: futureCoupons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load coupons'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No coupons available'));
          }

          final coupons = snapshot.data!;
          return ListView.builder(
            itemCount: coupons.length,
            itemBuilder: (context, index) {
              final coupon = coupons[index];
              return Card(
                margin: const EdgeInsets.all(10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: EasyrideColors.Drawerheaderbackground,
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          textColor: EasyrideColors.Drawerheadertext,
                          title: Text(
                            coupon.promotionName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${coupon.description}\nValid: ${coupon.fromDate} to ${coupon.toDate}',
                          ),
                          trailing: Text(
                            'RM ${coupon.amount}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          isThreeLine: true,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: 15.0, bottom: 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: coupon.isApplied
                                    ? Colors.grey
                                    : Colors.white,
                              ),
                              onPressed: coupon.isApplied
                                  ? null
                                  : () async {
                                      bool success = await ApiService()
                                          .applyCoupon(
                                              coupon.coupon_code, context);
                                      if (success) {
                                        Navigator.pop(
                                            context, coupon.coupon_code);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Failed to apply coupon',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                              child:
                                  Text(coupon.isApplied ? 'Applied' : 'Apply'),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Coupon {
  final int id;
  final String promotionName;
  final String coupon_code;
  final String description;
  final String fromDate;
  final String toDate;
  final String amount;
  final String countryCode;
  bool isApplied;

  Coupon({
    required this.id,
    required this.promotionName,
    required this.coupon_code,
    required this.description,
    required this.fromDate,
    required this.toDate,
    required this.amount,
    required this.countryCode,
    this.isApplied = false,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      promotionName: json['promotion_name'],
      coupon_code: json['coupon_code'],
      description: json['description'],
      fromDate: json['from_date'],
      toDate: json['to_date'],
      amount: json['amount'],
      countryCode: json['country_code'],
    );
  }
}

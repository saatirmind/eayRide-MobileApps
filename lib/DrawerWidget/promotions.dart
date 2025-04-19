// ignore_for_file: library_private_types_in_public_api
import 'dart:convert';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static const String apiUrl = AppApi.Couponslist;

  Future<List<Coupon>> fetchCoupons() async {
    final token = await getToken();

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
                    child: ListTile(
                      textColor: EasyrideColors.Drawerheadertext,
                      title: Text(
                        coupon.promotionName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${coupon.description}\nValid: ${coupon.fromDate} to ${coupon.toDate}',
                      ),
                      trailing: Text(
                        '₹${coupon.amount}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      isThreeLine: true,
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
  final String description;
  final String fromDate;
  final String toDate;
  final String amount;
  final String countryCode;

  Coupon({
    required this.id,
    required this.promotionName,
    required this.description,
    required this.fromDate,
    required this.toDate,
    required this.amount,
    required this.countryCode,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      promotionName: json['promotion_name'],
      description: json['description'],
      fromDate: json['from_date'],
      toDate: json['to_date'],
      amount: json['amount'],
      countryCode: json['country_code'],
    );
  }
}

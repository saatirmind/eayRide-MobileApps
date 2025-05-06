// ignore_for_file: library_private_types_in_public_api
import 'dart:convert';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AppliedCoupon {
  final int id;
  final int userId;
  final int couponId;
  final String couponCode;
  final String discountAmount;
  final String discountAmountLabel;
  final String createdAt;
  final CouponDetail coupon;

  AppliedCoupon({
    required this.id,
    required this.userId,
    required this.couponId,
    required this.couponCode,
    required this.discountAmount,
    required this.discountAmountLabel,
    required this.createdAt,
    required this.coupon,
  });

  factory AppliedCoupon.fromJson(Map<String, dynamic> json) {
    return AppliedCoupon(
      id: json['id'],
      userId: json['user_id'],
      couponId: json['coupon_id'],
      couponCode: json['coupon_code'],
      discountAmount: json['discount_amount'],
      discountAmountLabel: json['discount_amount_label'],
      createdAt: json['created_at'],
      coupon: CouponDetail.fromJson(json['coupon']),
    );
  }
}

class CouponDetail {
  final int id;
  final String promotionName;
  final String description;

  CouponDetail({
    required this.id,
    required this.promotionName,
    required this.description,
  });

  factory CouponDetail.fromJson(Map<String, dynamic> json) {
    return CouponDetail(
      id: json['id'],
      promotionName: json['promotion_name'],
      description: json['description'],
    );
  }
}

class ApiService {
  Future<List<AppliedCoupon>> fetchAppliedCoupons() async {
    final token = await AppApi.getToken();
    final response = await http.get(
      Uri.parse(AppApi.AppliedCoupons),
      headers: {
        'Content-Type': 'application/json',
        'token': token ?? '',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data']['data'];
      return data.map((json) => AppliedCoupon.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load applied coupons');
    }
  }
}

class AppliedCouponListScreen extends StatefulWidget {
  const AppliedCouponListScreen({super.key});

  @override
  _AppliedCouponListScreenState createState() =>
      _AppliedCouponListScreenState();
}

class _AppliedCouponListScreenState extends State<AppliedCouponListScreen> {
  late Future<List<AppliedCoupon>> futureCoupons;

  @override
  void initState() {
    super.initState();
    futureCoupons = ApiService().fetchAppliedCoupons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Applied Coupons"),
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
      ),
      body: FutureBuilder<List<AppliedCoupon>>(
        future: futureCoupons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Failed to load applied coupons"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No coupons applied yet"));
          }

          final coupons = snapshot.data!;
          return ListView.builder(
            itemCount: coupons.length,
            itemBuilder: (context, index) {
              final coupon = coupons[index];
              return Card(
                color: Colors.green,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coupon.coupon.promotionName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(coupon.coupon.description),
                      const SizedBox(height: 8),
                      Text("Code: ${coupon.couponCode}",
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 4),
                      Text("Discount: ${coupon.discountAmountLabel}"),
                      const SizedBox(height: 4),
                      Text("Applied On: ${coupon.createdAt.split('T').first}"),
                    ],
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

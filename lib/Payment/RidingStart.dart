// ignore_for_file: non_constant_identifier_names, file_names, deprecated_member_use, use_build_context_synchronously, avoid_print
import 'dart:convert';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/AppColors.dart/currentlocationprovide.dart';
import 'package:easymotorbike/AppColors.dart/tripprovide.dart';
import 'package:easymotorbike/AppColors.dart/walletapi.dart';
import 'package:easymotorbike/Payment/Applycoupon.dart';
import 'package:easymotorbike/Payment/Easyridecredits.dart';
import 'package:easymotorbike/Payment/InsufficientAmount.dart';
import 'package:easymotorbike/Payment/wallethistory.dart';
import 'package:easymotorbike/Screen/sucess.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Ridingstart extends StatefulWidget {
  final String Vehicle_no;
  final String car_number;
  final String latitude;
  final String longitude;

  const Ridingstart(
      {super.key,
      required this.latitude,
      required this.Vehicle_no,
      required this.longitude,
      required this.car_number});

  @override
  State<Ridingstart> createState() => _RidingstartState();
}

class _RidingstartState extends State<Ridingstart> {
  @override
  void initState() {
    super.initState();
    _fetchFinalAmount();
  }

  String? amount;
  String? perKmPrice;
  String? distance;
  String? from;
  String? to;
  Future<void> _fetchFinalAmount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await AppApi.getToken();
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final pickupId = prefs.getString('pickupCityId') ?? '';
    final dropId = prefs.getString('destinationCityId') ?? '';

    if (token == null || pickupId.isEmpty || dropId.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('https://easymotorbike.asia/api/v1/check-final-amount'),
        headers: {
          'token': token,
        },
        body: {
          'trip_type': tripProvider.selectedTripType,
          'pickup_id': pickupId,
          'drop_id': dropId,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          amount = data['amount'];
          perKmPrice = data['per_km_price'];
          distance = data['destination'];
          from = data['from'];
          to = data['to'];
        });
      }
    } catch (e) {
      print('Fetch amount error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);

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
            onPressed: () => Navigator.pop(context, true),
          ),
          title: const Text(
            'Payment Summary',
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
              Text(
                walletProvider.walletAmount,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              if (from != null && to != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'From: $from',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.flag, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'To: $to',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Distance:",
                              style: TextStyle(fontSize: 16)),
                          Text(distance ?? '',
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Per KM Price:",
                              style: TextStyle(fontSize: 16)),
                          Text(perKmPrice ?? '',
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Fare:",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(amount ?? '',
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),

              const Divider(height: 20),
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Text(
                      'Vehicle No. : ',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Text(
                      widget.Vehicle_no,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),
              // Lottie.asset(
              //   'assets/lang/walletfound.json',
              //   width: MediaQuery.of(context).size.width * 0.8,
              //   height: MediaQuery.of(context).size.width * 0.550,
              //   fit: BoxFit.contain,
              // ),

              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreditsReloadScreen(),
                    ),
                  );
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
                          Icon(Icons.wallet, size: 25),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Add Amount:',
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
              const SizedBox(height: 8),
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
              //const SizedBox(height: 16),
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
              //           'Other Payment Method:',
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
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _couponController.text.isEmpty
                    ? () async {
                        final selectedCouponCode = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CouponListScreen(),
                          ),
                        );

                        if (selectedCouponCode != null) {
                          setState(() {
                            _showCouponField = true;
                            _couponController.text = selectedCouponCode;
                          });
                        }
                      }
                    : null,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _couponController.text.isEmpty
                        ? Colors.orange.shade100
                        : Colors.green.shade100,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _couponController.text.isEmpty
                            ? 'Apply Coupon – Tap Here'
                            : 'Coupon Applied',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.local_offer_outlined,
                        color: _couponController.text.isEmpty
                            ? Colors.deepOrange
                            : Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
              //const SizedBox(height: 8),
              if (_showCouponField)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _couponController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Coupon Code',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  _PaymentWallettmoney();
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
                          : const Row(
                              children: [
                                SizedBox(width: 8),
                                Text(
                                  'Pay to Ride',
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
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  bool _isLoading = false;
  String Messasge = '';

  Future<void> _PaymentWallettmoney() async {
    setState(() {
      _isLoading = true;
    });
    print("🔵 Function Called!");
    final provider = Provider.of<TripProvider>(context, listen: false);
    final providecity =
        Provider.of<CityLocationProvider>(context, listen: false);
    await providecity.fetchcityLocation();

    final token = await AppApi.getToken();
    final prefs = await SharedPreferences.getInstance();
    final pickupId = prefs.getString('pickupCityId');
    final destinationId = prefs.getString('destinationCityId');

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

    try {
      final response = await http.post(
        Uri.parse(AppApi.new_ride_booking),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: jsonEncode({
          'vehicle_no': widget.Vehicle_no,
          'current_lat': widget.latitude,
          'current_long': widget.longitude,
          'trip_type': provider.selectedTripType,
          'city': providecity.cityName,
          'pickup_id': pickupId,
          'drop_id': destinationId
        }),
      );
      print("Response Data: ${response.body}");
      print("Response Data: ${response.statusCode}");
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          final Map<String, dynamic> responseData = data;
          setState(() {
            Bookingtoken = responseData['data']['booking_token'].toString();
            Messasge = responseData['message'][0].toString();
          });
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('booking_token', Bookingtoken);
          await prefs.setString('Messasge', Messasge);
          await prefs.setString('VehicleNo', widget.Vehicle_no);

          setState(() {
            _isLoading = false;
          });

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const SuccessScreen(),
            ),
            (Route<dynamic> route) => false,
          );
        } else if (data['status'] == false) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InsufficientAmount(amount: data),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${data['message']}'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${data['message']}'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      } else if (response.statusCode == 402) {
        final data = jsonDecode(response.body);

        final dynamic amountValue = data['data']['amount'];
        double? amount;
        if (amountValue != null && amountValue is num) {
          amount = amountValue.toDouble();
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InsufficientAmount(amount: amount ?? 0.0),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${data['message'] ?? 'Unknown error'}'),
            backgroundColor: Colors.red,
          ),
        );

        setState(() {
          _isLoading = false;
        });
      } else {
        final data = jsonDecode(response.body);
        final Map<String, dynamic> responseData = data;
        Messasge = responseData['message'][0].toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            content: Text(Messasge),
            backgroundColor: Colors.red,
          ),
        );

        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred: $error'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _showCouponField = false;
  final TextEditingController _couponController = TextEditingController();

  String Bookingtoken = '';
}

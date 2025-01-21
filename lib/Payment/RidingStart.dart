import 'dart:convert';
import 'package:easyride/AppColors.dart/EasyrideAppColors.dart';
import 'package:easyride/Payment/Easyridecredits.dart';
import 'package:easyride/Payment/wallethistory.dart';
import 'package:easyride/Placelist/placelist.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Ridingstart extends StatefulWidget {
  final String finalPrice;
  final String Vehicle_no;
  final String car_number;

  const Ridingstart(
      {Key? key,
      required this.finalPrice,
      required this.Vehicle_no,
      required this.car_number})
      : super(key: key);

  @override
  State<Ridingstart> createState() => _RidingstartState();
}

class _RidingstartState extends State<Ridingstart> {
  String? totalAmountLabel;
  Future<void> _getTotalAmountLabel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      totalAmountLabel = prefs.getString('totalAmountLabel') ?? 'N/A';
    });
  }

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
            'Payment Screen',
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
              Text(
                'You need to pay ${totalAmountLabel} to Start your ride.',
                style: TextStyle(fontSize: 19, color: Colors.red),
              ),
              // const SizedBox(height: 32),
              // Text(
              //   'Car No. : ${widget.car_number}',
              //   style: TextStyle(fontSize: 19, color: Colors.black),
              // ),
              const SizedBox(height: 16),
              Text(
                'Vehicle No. : ${widget.Vehicle_no}',
                style: TextStyle(fontSize: 19, color: Colors.black),
              ),
              const Spacer(),
              GestureDetector(
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
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
                        'Payment Other Method:',
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
              const SizedBox(height: 16),
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
                          : Row(
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
            ],
          ),
        ),
      ),
    );
  }

  bool _isLoading = false;
  String walletHistory = '';

  String dropLocation = '';
  String pickupLocation = '';
  String Messasge = '';

  @override
  void initState() {
    super.initState();
    _fetchWalletHistory();
    _loadSelectedCity();
    getSavedLocation();
    _getTotalAmountLabel();
  }

  Future<void> _loadSelectedCity() async {
    final locations = await getSelectedCity();

    setState(() {
      dropLocation = locations['dropLocation']!;
      pickupLocation = locations['pickupLocation']!;
    });
  }

  Future<Map<String, String>> getSelectedCity() async {
    final prefs = await SharedPreferences.getInstance();

    String? selectedLocationD = prefs.getString('selectedlocationd');
    String? selectedLocationP = prefs.getString('selectedlocationp');

    selectedLocationD = selectedLocationD ?? 'No drop location found';
    selectedLocationP = selectedLocationP ?? 'No pickup location found';

    return {
      'dropLocation': selectedLocationD,
      'pickupLocation': selectedLocationP,
    };
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

  Future<LatLng?> getSavedLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? latitude = prefs.getDouble('latitude');
    double? longitude = prefs.getDouble('longitude');

    if (latitude != null && longitude != null) {
      return LatLng(latitude, longitude);
    } else {
      return null;
    }
  }

  Future<String?> getSavedTripWiseValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('tripWiseValue');
  }

  Future<void> _PaymentWallettmoney() async {
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

    if (widget.finalPrice.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please Try Again'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });

      return;
    }
    final String? tripWiseValue = await getSavedTripWiseValue();

    if (tripWiseValue == null) {
      print('TripWiseValue is missing. Please set it first.');
      return;
    }

    print('Retrieved tripWiseValue: $tripWiseValue');
    LatLng? savedLocation = await getSavedLocation();
    if (savedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to fetch location. Please try again.'),
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
        Uri.parse(AppApi.ridebooking),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: jsonEncode({
          'vehicle_no': widget.Vehicle_no,
          'current_lat': savedLocation.latitude,
          'current_long': savedLocation.longitude,
          'trip_type': tripWiseValue,
          'pickup_id': dropLocation,
          'drop_id': pickupLocation,
        }),
      );

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

          await Future.delayed((Duration(seconds: 2)));
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment successfully!... Start Ride'),
              backgroundColor: Colors.green,
            ),
          );
          await Future.delayed((Duration(seconds: 2)));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PlaceList(),
            ),
          );
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 5),
            content: Text(
                'Add funds to your wallet and start your ride! Upload now and enjoy your journey!'),
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

  String Bookingtoken = '';
}

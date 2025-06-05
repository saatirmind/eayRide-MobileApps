// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api, avoid_print, use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/Dummyscreen/dummyhome.dart';
import 'package:easymotorbike/Placelist/new_place.dart';
import 'package:easymotorbike/notification/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:easymotorbike/Screen/homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String userId;
  final String mobile;
  final String mobile_code;
  final String Verification_code;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.userId,
    required this.mobile,
    required this.mobile_code,
    required this.Verification_code,
  });

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _start = 60;
  bool _canResend = false;
  bool _isLoading = false;
  String _resendOtp = '';
  bool _isSubmitEnabled = false;
  String? token;
  String? userid;
  String? bookingtoken;
  String? vehicleno;
  String? vehicle_id;
  String? registered_date;
  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    startTimer();
    print("User ID: ${widget.userId}");
    print("Verification Code: ${widget.Verification_code}");
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _start = 60;
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_start > 0) {
        setState(() {
          _start--;
        });
      } else {
        setState(() {
          _canResend = true;
          _timer?.cancel();
        });
      }
    });
  }

  void _onFieldChanged(String value, int index) {
    _updateSubmitButtonState();

    if (value.isEmpty && index > 0) {
      _focusNodes[index].unfocus();
      _focusNodes[index - 1].requestFocus();
    } else if (value.isNotEmpty && index < 5) {
      _focusNodes[index].unfocus();
      _focusNodes[index + 1].requestFocus();
    } else if (index == 5 && value.isNotEmpty) {
      _focusNodes[index].unfocus();
    } else if (value.isEmpty && index < 5) {
      _focusNodes[index].unfocus();
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  void _updateSubmitButtonState() {
    bool allFieldsFilled =
        _otpControllers.every((controller) => controller.text.isNotEmpty);
    setState(() {
      _isSubmitEnabled = allFieldsFilled;
    });
  }

  Future<void> _verifyOtp() async {
    String otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 6-digit OTP.'.tr())),
      );
      return;
    }

    try {
      String? deviceToken;

      if (Platform.isAndroid) {
        deviceToken = await notificationService.getDeviceToken();
      } else {
        deviceToken = null;
      }

      final url = Uri.parse(AppApi.login);
      final response = await http.post(
        url,
        body: {
          'user_id': widget.userId,
          'otp': otp,
          if (deviceToken != null) 'device_token': deviceToken,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);

        if (responseData['status'] == true) {
          setState(() {
            userid = responseData['data']['id'].toString();
            token = responseData['data']['token'];
            bookingtoken = responseData['data']['booking_token'];
            vehicleno = responseData['data']['vehicle_no'];
            vehicle_id = responseData['data']['bike_id'].toString();
            registered_date = responseData['data']['registered_date'];
          });

          print('Booking Token: $bookingtoken');
          print('Vehicle No.: $vehicleno');
          print('Vehicle_id: $vehicle_id');

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token!);
          await prefs.setString('user_id', userid!);
          await prefs.setString('registered_date', registered_date!);
          await prefs.setString('mobile', widget.phoneNumber);

          if (bookingtoken != null && bookingtoken!.isNotEmpty) {
            await prefs.setString('booking_token', bookingtoken!);
            await prefs.setString('VehicleNo', vehicleno!);
            await AppApi.saveVehicleId(vehicle_id);

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MapScreen()),
              (Route<dynamic> route) => false,
            );
          } else {
            navigateToHomeScreen();
          }
        } else {
          String errorMessage = "Something went wrong.";
          if (responseData['message'] != null) {
            errorMessage = responseData['message'].toString();
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> navigateToHomeScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    if (token != null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User Successfully Logged In'.tr()),
          backgroundColor: EasyrideColors.successSnak,
          duration: (const Duration(seconds: 2)),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder:
                (context) => /*HomeScreen(
            Mobile: widget.phoneNumber,
            Token: token!,
            registered_date: registered_date!,
          ),*/
                    HomeScreen9()),
        (Route<dynamic> route) => false,
      );
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> resendOtp() async {
    final url = Uri.parse(AppApi.sendOtp);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobile': widget.mobile,
          'mobile_code': widget.mobile_code,
        }),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final verCode = responseData['data']['ver_code'];
        setState(() {
          _resendOtp = verCode.toString();
        });
        startTimer();
        print("Resend OTP: $verCode");
      } else {
        setState(() {
          _isLoading = false;
        });

        String errorMessage = "An unknown error occurred.";
        if (responseData.containsKey('message') &&
            responseData['message'] is List) {
          errorMessage = responseData['message'][0];
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: EasyrideColors.Alertsank,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: EasyrideColors.Alertsank,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EasyrideColors.background,
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_resendOtp.isEmpty)
              Center(
                child: Text(
                  'OTP: ${widget.Verification_code}',
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else
              Center(
                child: Text(
                  'Resend OTP: $_resendOtp',
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'enter_code'.tr(namedArgs: {'phoneNumber': widget.phoneNumber}),
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 40,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      _onFieldChanged(value, index);
                      if (value.isNotEmpty && index < 5) {
                        FocusScope.of(context)
                            .requestFocus(_focusNodes[index + 1]);
                      } else if (value.isEmpty && index > 0) {
                        FocusScope.of(context)
                            .requestFocus(_focusNodes[index - 1]);
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Text(
              'Resend OTP in: $_start seconds',
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 10),
            if (_canResend)
              TextButton(
                onPressed: resendOtp,
                child: Text('Resend OTP'.tr()),
              ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EasyrideColors.buttonColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 30.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (!_isSubmitEnabled || _isLoading) return;

                    setState(() {
                      _isLoading = true;
                    });
                    await _verifyOtp();
                  },
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3.0,
                          ),
                        )
                      : Text(
                          'Submit'.tr(),
                          style: const TextStyle(
                            color: EasyrideColors.buttontextColor,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

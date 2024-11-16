import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:easyride/Screen/homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String userId;
  final String mobile;
  final String mobile_code;
  final String Verification_code;

  const OtpScreen({
    Key? key,
    required this.phoneNumber,
    required this.userId,
    required this.mobile,
    required this.mobile_code,
    required this.Verification_code,
  }) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _start = 15;
  bool _canResend = false;
  String _resendOtp = '';
  bool _isSubmitEnabled = false;
  String? token;

  @override
  void initState() {
    super.initState();
    startTimer();
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
    _start = 20;
    _canResend = false;
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
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

  Future<void> _verifyOtp(SharedPreferences prefs) async {
    String otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 6-digit OTP.')),
      );
      return;
    }

    final url = Uri.parse('https://easyride.saatirmind.com.my/api/v1/login');
    try {
      final response = await http.post(
        url,
        body: {
          'user_id': widget.userId,
          'otp': otp,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          setState(() {
            token = responseData['data']['token'];
          });
          print('Login Successful! Token: $token');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User Successfully Logged In'),
              backgroundColor: Colors.green,
            ),
          );

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token!);
          await prefs.setString('mobile', widget.mobile);

          navigateToHomeScreen();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP verification failed.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid OTP. Please type valid OTP.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void navigateToHomeScreen() {
    if (token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            Mobile: widget.phoneNumber,
            Token: token!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Token is null. Unable to navigate.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> resendOtp() async {
    final url = Uri.parse('https://easyride.saatirmind.com.my/api/v1/send-otp');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobile': widget.mobile,
          'mobile_code': widget.mobile_code,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final verCode = responseData['data']['ver_code'];
        setState(() {
          _resendOtp = verCode.toString();
        });
        startTimer();
        print("Resend OTP: $verCode");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend OTP. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Theme.of(context).primaryColor,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_resendOtp.isEmpty)
                Center(
                  child: Text(
                    'OTP: ${widget.Verification_code}',
                    style: TextStyle(color: Colors.red),
                  ),
                )
              else
                Center(
                  child: Text(
                    'Resend OTP: $_resendOtp',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'Enter the 6 digit code sent to ${widget.phoneNumber}',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
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
                      decoration: InputDecoration(counterText: ''),
                      onChanged: (value) => _onFieldChanged(value, index),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Text(
                'Resend OTP in: $_start seconds',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 10),
              if (_canResend)
                TextButton(
                  onPressed: resendOtp,
                  child: Text('Resend OTP'),
                ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        padding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 30.0),
                      ),
                      onPressed: _isSubmitEnabled
                          ? () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              _verifyOtp(prefs);
                            }
                          : null,
                      child: Text('Submit'),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}

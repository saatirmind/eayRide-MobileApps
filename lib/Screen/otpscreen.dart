import 'dart:async';
import 'dart:convert';
import 'package:easyride/Screen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String userId;
  final String mobile;
  final String mobile_code;
  final String Verification_code;

  const OtpScreen(
      {Key? key,
      required this.phoneNumber,
      required this.userId,
      required this.mobile,
      required this.mobile_code,
      required this.Verification_code})
      : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  Timer? _timer;
  int _start = 60;
  bool _canResend = false;
  String _resendOtp = '';

  void _onFieldSubmitted(int index) {
    if (index < 5) {
      FocusScope.of(context).nextFocus();
    } else {
      String otp = _otpControllers.map((controller) => controller.text).join();
      if (otp.length == 6) {
        verifyOtp(otp, widget.userId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid 6-digit OTP.')),
        );
      }
    }
  }

  void startTimer() {
    _start = 25;
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

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> verifyOtp(String otp, String userId) async {
    final url = Uri.parse('https://easyride.saatirmind.com.my/api/v1/login');
    try {
      final response = await http.post(
        url,
        body: {
          'user_id': userId,
          'otp': otp,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          final token = responseData['data']['token'];
          print('Login Successful! Token: $token');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('User Successfully Logged In'),
                backgroundColor: Colors.green),
          );
          navigateToHomeScreen();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('OTP verification failed.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void navigateToHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => HomeScreen(Mobile: widget.phoneNumber)),
    );
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
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(counterText: ''),
                      onChanged: (value) {
                        if (value.length == 1) {
                          _onFieldSubmitted(index);
                        }
                      },
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
              //const SizedBox(height: 200),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 35),
              //   child: ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       foregroundColor: Colors.black,
              //       backgroundColor: Colors.yellow,
              //       padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              //       minimumSize: Size(250, 40),
              //     ),
              //     onPressed: () {
              //       String otp = _otpControllers
              //           .map((controller) => controller.text)
              //           .join();
              //       if (otp.length == 6) {
              //         verifyOtp(otp, widget.userId);
              //       } else {
              //         ScaffoldMessenger.of(context).showSnackBar(
              //           SnackBar(
              //               content: Text('Please enter a valid 6-digit OTP.')),
              //         );
              //       }
              //     },
              //     child: const Text('Submit'),
              //   ),
              // ),
              // const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> resendOtp() async {
    final url = Uri.parse('https://easyride.saatirmind.com.my/api/v1/send-otp');
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
            backgroundColor: Colors.red),
      );
    }
  }
}

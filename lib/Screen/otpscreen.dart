import 'dart:async';
import 'package:easyride/Screen/homescreen.dart';
import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());

  Timer? _timer;
  int _start = 60;
  bool _canResend = false;

  void _onFieldSubmitted(int index) {
    if (index < 5) {
      FocusScope.of(context).nextFocus();
    } else {
      String otp = _otpControllers.map((controller) => controller.text).join();
      print('Entered OTP: $otp');
    }
  }

  void startTimer() {
    _start = 60;
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

  void resendOtp() {
    print('Resending OTP to ${widget.phoneNumber}');
    startTimer();
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
                      decoration: InputDecoration(
                        counterText: '',
                      ),
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
              const SizedBox(height: 200),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.yellow,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    minimumSize: Size(250, 40),
                  ),
                  onPressed: () {
                    String otp = _otpControllers
                        .map((controller) => controller.text)
                        .join();

                    if (otp.length == 6) {
                      print('Entered OTP: $otp');
                      navigateToHomeScreen();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter a valid 6-digit OTP.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void navigateToHomeScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }
}

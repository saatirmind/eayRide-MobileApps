import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:easyride/AppColors.dart/EasyrideAppColors.dart';
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
  int _start = 60;
  bool _canResend = false;
  bool _isLoading = false;
  String _resendOtp = '';
  bool _isSubmitEnabled = false;
  String? token;
  String? registered_date;

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
        SnackBar(content: Text('Please enter a valid 6-digit OTP.'.tr())),
      );
      return;
    }

    final url = Uri.parse(AppApi.login);
    try {
      final response = await http.post(
        url,
        body: {
          'user_id': widget.userId,
          'otp': otp,
        },
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          setState(() {
            token = responseData['data']['token'];

            registered_date = responseData['data']['registered_date'];
          });
          print('Login Successful! Token: $token');

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token!);

          await prefs.setString('registered_date', registered_date!);

          await prefs.setString('mobile', widget.phoneNumber);

          navigateToHomeScreen();
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

  Future<void> navigateToHomeScreen() async {
    await Future.delayed(Duration(seconds: 2));
    if (token != null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User Successfully Logged In'.tr()),
          backgroundColor: EasyrideColors.successSnak,
          duration: (Duration(seconds: 2)),
        ),
      );

      await Future.delayed(Duration(seconds: 2));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            Mobile: widget.phoneNumber,
            Token: token!,
            registered_date: registered_date!,
          ),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Token is null. Unable to navigate.'),
          backgroundColor: EasyrideColors.Alertsank,
        ),
      );
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
                'enter_code'.tr(namedArgs: {'phoneNumber': widget.phoneNumber}),
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
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
              style: TextStyle(fontSize: 14, color: Colors.black),
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
                    padding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isSubmitEnabled && !_isLoading
                      ? () async {
                          setState(() {
                            _isLoading = true;
                          });

                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await _verifyOtp(prefs);
                        }
                      : null,
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 3.0,
                          ),
                        )
                      : Text(
                          'Submit'.tr(),
                          style: TextStyle(
                            color: EasyrideColors.buttontextColor,
                          ),
                        ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

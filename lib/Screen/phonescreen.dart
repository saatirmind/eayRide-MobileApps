import 'dart:convert';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easyride/AppColors.dart/EasyrideAppColors.dart';
import 'package:easyride/Screen/otpscreen.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class PhoneNumberScreen extends StatefulWidget {
  @override
  _PhoneNumberScreenState createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  String appVersion = 'Loading...';
  final FocusNode phoneFocusNode = FocusNode();
  bool _isLoading = false;
  final Uri _url = Uri.parse('https://www.emrkl.com/');
  String countryCode = '+60';
  final _formKey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController();
  TextEditingController fullnameController = TextEditingController();
  TextEditingController passportController = TextEditingController();

  @override
  void initState() {
    super.initState();
    phoneController.addListener(() {
      if (phoneController.text.length == 15) {
        FocusScope.of(context).unfocus();
      }
    });
    fetchAppVersion();
  }

  Future<void> fetchAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = 'Version: ${packageInfo.version}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EasyrideColors.background,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/splash.png',
                width: MediaQuery.of(context).size.width * 1,
                height: MediaQuery.of(context).size.height * 0.3,
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Icon(Icons.person),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 58),
                      child: TextFormField(
                        controller: fullnameController,
                        decoration: InputDecoration(
                          hintText: 'Full Name (Passport or ID Card)'.tr(),
                          border: UnderlineInputBorder(),
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Full Name is required'.tr();
                          } else if (value.length < 3) {
                            return 'Full Name must be at least 3 characters'
                                .tr();
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Icon(Icons.description),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 58),
                      child: TextFormField(
                        controller: passportController,
                        decoration: InputDecoration(
                          hintText: 'Passport/NRIC Number'.tr(),
                          border: UnderlineInputBorder(),
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Passport/NRIC Number is required'.tr();
                          } else if (value.length < 5) {
                            return 'Passport/NRIC Number must be at least 5 characters'
                                .tr();
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  CountryCodePicker(
                    onChanged: (code) {
                      setState(() {
                        countryCode = code.dialCode!;
                      });
                    },
                    initialSelection: 'MY',
                    showFlag: true,
                    favorite: ['+60', 'MY'],
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 15,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(15),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Enter your mobile number'.tr(),
                        border: UnderlineInputBorder(),
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required'.tr();
                        } else if (value.length < 2) {
                          return 'Phone number must be at least 2 digits'.tr();
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  "Enter your phone number without '0'. By continuing, you agree to our Terms of Service."
                      .tr(),
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? Container(
                          decoration: BoxDecoration(
                            color: EasyrideColors.buttonColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          height: 50,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 4.0,
                          ),
                        )
                      : InkWell(
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              await sendOtp();
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: EasyrideColors.buttonColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            height: 50,
                            alignment: Alignment.center,
                            child: Text(
                              'NEXT'.tr(),
                              style: TextStyle(
                                color: EasyrideColors.buttontextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                '6 digit code will be sent to your phone in a few seconds.'
                    .tr(),
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              TextButton(
                onPressed: () async {
                  if (!await launchUrl(_url)) {
                    throw 'Could not launch $_url';
                  }
                },
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'TERMS OF SERVICE\n',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                    children: [
                      TextSpan(
                        text: 'FAQ',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Version: 1.0.9',
                //appVersion,
                style: TextStyle(fontSize: 15, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendOtp() async {
    String phoneNumber = phoneController.text;
    FocusScope.of(context).unfocus();

    if (phoneNumber.isEmpty || phoneNumber.length < 2) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please enter a valid mobile number.'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'.tr()),
            ),
          ],
        ),
      );
      return;
    }

    final url = Uri.parse(AppApi.sendOtp);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile': phoneNumber,
        'mobile_code': countryCode,
        'fullname': fullnameController.text,
        'passport_or_nric_no': passportController.text,
      }),
    );
    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final verCode = responseData['data']['ver_code'];
      final userId = responseData['data']['id'];
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseData['message'][0]),
          backgroundColor: EasyrideColors.successSnak,
        ),
      );

      print("Verification code: $verCode");
      await Future.delayed(Duration(seconds: 2));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(
            phoneNumber: '$countryCode-$phoneNumber',
            userId: userId.toString(),
            Verification_code: verCode.toString(),
            mobile: '$phoneNumber',
            mobile_code: '$countryCode',
          ),
        ),
      );
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
  }
}

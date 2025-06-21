// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print
import 'dart:convert';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/AppColors.dart/webview.dart';
import 'package:easymotorbike/NewScreen/login.dart';
import 'package:easymotorbike/Screen/otpscreen.dart';
import 'package:easymotorbike/main.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  _PhoneNumberScreenState createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  String appVersion = 'Loading...';
  final FocusNode phoneFocusNode = FocusNode();
  bool _isLoading = false;
  String countryCode = '+60';
  final _formKey1 = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController();
  TextEditingController fullnameController = TextEditingController();
  TextEditingController passportController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBannerImage();
    phoneController.addListener(() {
      if (phoneController.text.length == 15) {
        FocusScope.of(context).unfocus();
      }
    });
    fetchAppVersion();
  }

  Uint8List? imageBytes;
  Future<void> _loadBannerImage() async {
    Uint8List? image = await Bannersave.getSavedBannerImage();
    setState(() {
      imageBytes = image;
    });
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
      appBar: AppBar(
        backgroundColor: EasyrideColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(right: 16, left: 16, bottom: 0),
          child: Form(
            key: _formKey1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                imageBytes != null
                    ? Image.memory(
                        imageBytes!,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.3,
                        fit: BoxFit.contain,
                      )
                    : const CircularProgressIndicator(),
                const SizedBox(height: 10),
                TextFormField(
                  controller: fullnameController,
                  decoration: InputDecoration(
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 30, right: 58),
                      child: Icon(Icons.person),
                    ),
                    hintText: 'Full Name (Passport or ID Card)'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2.0,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2.0,
                      ),
                    ),
                    counterText: '',
                    counter: const Text(
                      '',
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Full Name is required';
                    } else if (value.length < 3) {
                      return 'Full Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: passportController,
                  decoration: InputDecoration(
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 30, right: 58),
                      child: Icon(Icons.email),
                    ),
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2.0,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2.0,
                      ),
                    ),
                    counterText: '',
                    counter: const Text(''),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                        .hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),

                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 15,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                  ],
                  decoration: InputDecoration(
                    prefixIcon: CountryCodePicker(
                      onChanged: (code) {
                        setState(() {
                          countryCode = code.dialCode!;
                        });
                      },
                      initialSelection: 'MY',
                      showFlag: true,
                    ),
                    hintText: 'Enter your mobile number'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2.0,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2.0,
                      ),
                    ),
                    counterText: '',
                    counter: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '${phoneController.text.length}/15',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required'.tr();
                    } else if (value.length < 2) {
                      return 'Phone number must be at least 2 digits'.tr();
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      phoneController.text.length;
                    });
                  },
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    "Enter your phone number without '0'. By continuing, you agree to our Terms of Service.",
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: (value) {
                        setState(() {
                          _isChecked = value!;
                        });
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WebViewPage(
                                url: AppApi.term_condition,
                              ),
                            ),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "I agree to ",
                                style: TextStyle(color: Colors.black),
                              ),
                              TextSpan(
                                text: "Terms and Conditions",
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                            child: const CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 4.0,
                            ),
                          )
                        : InkWell(
                            onTap: () async {
                              if (_formKey1.currentState!.validate()) {
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
                              child: const Text(
                                'SignUp',
                                style: TextStyle(
                                  color: EasyrideColors.buttontextColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '6 digit code will be sent to your phone in a few seconds.',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Login(),
                    ),
                  ),
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Already have an account?",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: " Login",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // RichText(
                //   textAlign: TextAlign.center,
                //   text: TextSpan(
                //     text: 'TERMS OF SERVICE\nFAQ',
                //     style: const TextStyle(
                //       color: Colors.blue,
                //       fontSize: 16,
                //     ),
                //     recognizer: TapGestureRecognizer()
                //       ..onTap = () {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => const WebViewPage(
                //               url: AppApi.term_condition,
                //             ),
                //           ),
                //         );
                //       },
                //   ),
                // ),
                const SizedBox(height: 16),
                // const Text(
                //   'Version: 1.0.9',
                //   //appVersion,
                //   style: TextStyle(fontSize: 15, color: Colors.grey),
                //   textAlign: TextAlign.center,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> sendOtp() async {
    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Please read Terms and Conditions and tick the checkbox."),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    String phoneNumber = phoneController.text;
    FocusScope.of(context).unfocus();

    if (phoneNumber.isEmpty || phoneNumber.length < 2) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please enter a valid mobile number.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final url = Uri.parse(AppApi.Signup);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile': phoneNumber,
        'mobile_code': countryCode,
        'fullname': fullnameController.text,
        'email': passportController.text,
      }),
    );
    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final verCode = responseData['data']['ver_code'];
      final userId = responseData['data']['id'];
      await Future.delayed(const Duration(seconds: 2));
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
      await Future.delayed(const Duration(seconds: 2));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(
            phoneNumber: '$countryCode-$phoneNumber',
            userId: userId.toString(),
            Verification_code: verCode.toString(),
            mobile: phoneNumber,
            mobile_code: countryCode,
          ),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
      });

      String errorMessage = "An unknown error occurred.";
      print("Error message from API: $errorMessage");
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

  bool _isChecked = false;
}

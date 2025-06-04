// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously, deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
// import 'package:easymotorbike/AppColors.dart/webview.dart';
import 'package:easymotorbike/NewScreen/otp.dart';
import 'package:easymotorbike/Screen/otpscreen.dart';
import 'package:easymotorbike/Screen/phonescreen.dart';
import 'package:easymotorbike/main.dart';
// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String appVersion = 'Loading...';
  final FocusNode phoneFocusNode = FocusNode();
  bool _isLoading = false;
  String countryCode = '+60';
  final _formKey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController();

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

  Future<void> fetchAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = 'Version: ${packageInfo.version}';
    });
  }

  Uint8List? imageBytes;
  Future<void> _loadBannerImage() async {
    Uint8List? image = await Bannersave.getSavedBannerImage();
    setState(() {
      imageBytes = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EasyrideColors.background,
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.arrow_back),
              const SizedBox(height: 40),
              const Text(
                "Hi there 👋",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "What's your phone number?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "We'll send you an SMS with a verification code to secure your account.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              // imageBytes != null
              //     ? Image.memory(
              //         imageBytes!,
              //         width: MediaQuery.of(context).size.width,
              //         height: MediaQuery.of(context).size.height * 0.3,
              //         fit: BoxFit.contain,
              //       )
              //     : const CircularProgressIndicator(),
              /*Image.network(
                imageUrl ?? '',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.3,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/splash.png',
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.3,
                    fit: BoxFit.contain,
                  );
                },
              ),*/

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
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
              Text(
                "Enter your phone number without '0'. By continuing, you agree to our Terms of Service."
                    .tr(),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              Spacer(flex: 1),
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? Container(
                        decoration: BoxDecoration(
                          color: EasyrideColors.buttonColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        height: 50,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
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
                        child: Container(
                          decoration: BoxDecoration(
                            color: EasyrideColors.buttonColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          height: 50,
                          alignment: Alignment.center,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.login,
                                  color: EasyrideColors.buttontextColor),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Login',
                                style: TextStyle(
                                    color: EasyrideColors.buttontextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              Text(
                '6 digit code will be sent to your phone in a few seconds.'
                    .tr(),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PhoneNumberScreen(),
                      ),
                    ),
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: "Don't have an Account? ",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: "Signup",
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
                ],
              ),
              // const SizedBox(height: 80),
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
              // const SizedBox(height: 16),
              // const Text(
              //   'Version: 1.0.18',
              //   style: TextStyle(fontSize: 15, color: Colors.grey),
              //   textAlign: TextAlign.center,
              // ),
              const SizedBox(height: 30),
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
          title: const Text('Error'),
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

    try {
      final url = Uri.parse(AppApi.sendOtp);
      final response = await http
          .post(url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'mobile': phoneNumber,
                'mobile_code': countryCode,
              }))
          .timeout(const Duration(seconds: 8));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final verCode = responseData['data']['ver_code'];
        final userId = responseData['data']['id'];
        final userType = responseData['data']['user_type'];

        print("Verification code: $verCode");
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          _isLoading = false;
        });

        if (userType == "user") {
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
        } else if (userType == "ranger") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'][0]),
              backgroundColor: EasyrideColors.successSnak,
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Otp2Screen(
                phoneNumber: '$countryCode-$phoneNumber',
                userId: userId.toString(),
                Verification_code: verCode.toString(),
                mobile: phoneNumber,
                mobile_code: countryCode,
              ),
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });

        String errorMessage =
            responseData['message'] ?? "An unknown error occurred.";
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
    } on SocketException {
      setState(() {
        _isLoading = false;
      });
      showNoInternetDialog(context);
    } on TimeoutException {
      setState(() {
        _isLoading = false;
      });
      showTimeoutDialog(context);
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
      print("Unhandled error: $error");
    }
  }

  void showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text(
              "No Internet",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "Please check your internet connection and try again.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              sendOtp();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void showTimeoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.hourglass_bottom, color: Colors.orange, size: 30),
            SizedBox(width: 10),
            Text(
              "Request Timeout",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "The server is taking too long to respond.\nPlease try again later.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              sendOtp();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

/*class LocationService {
  static Future<void> getAndSaveLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      while (!serviceEnabled) {
        await showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text("Location Service is Off"),
                content: const Text(
                    "Please turn on your location service to proceed."),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await Geolocator.openLocationSettings();

                      serviceEnabled =
                          await Geolocator.isLocationServiceEnabled();

                      if (serviceEnabled) {
                        Navigator.pop(context);
                      } else {
                        print("Location service is still off.");
                      }
                    },
                    child: const Card(
                        color: EasyrideColors.buttonColor,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Turn On",
                            style: TextStyle(
                                color: EasyrideColors.buttontextColor),
                          ),
                        )),
                  ),
                ],
              );
            },
          ),
        );
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          SystemNavigator.pop();
          print('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print(
            'Location permissions are permanently denied, we cannot request permissions.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String? state = placemark.administrativeArea;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('StartState', state ?? '');

        print('State: $state');
      } else {
        print('No placemarks found for the given coordinates.');
      }
    } catch (e) {
      print('Error occurred while fetching location: $e');
    }
  }
}*/

/* class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.arrow_back),
              const SizedBox(height: 40),
              const Text(
                "Hi there 👋",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "What's your phone number?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "We'll send you an SMS with a verification code to secure your account.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),

              // Phone input
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      height: 55,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("+65", style: TextStyle(fontSize: 16)),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      height: 55,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const TextField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Phone Number",
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // NEXT button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[200],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Help text
              Center(
                child: RichText(
                  text: const TextSpan(
                    text: "Having trouble? ",
                    style: TextStyle(color: Colors.black87),
                    children: [
                      TextSpan(
                        text: "Let us help",
                        style: TextStyle(color: Colors.purple),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}*/

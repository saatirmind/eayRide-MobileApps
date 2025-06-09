// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/NewScreen/login.dart';
import 'package:easymotorbike/main.dart';
import 'package:easymotorbike/notification/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Placelist/new_place.dart';
import '../bottombaar/bottodummy.dart';

class BeamLoginScreen extends StatefulWidget {
  const BeamLoginScreen({super.key});

  @override
  State<BeamLoginScreen> createState() => _BeamLoginScreenState();
}

class _BeamLoginScreenState extends State<BeamLoginScreen>
    with WidgetsBindingObserver {
  Uint8List? imageBytes;
  NotificationService notificationService = NotificationService();

  Future<void> _loadBannerImage() async {
    Uint8List? image = await Bannersave.getSavedBannerImage();
    setState(() {
      imageBytes = image;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBannerImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(
                flex: 1,
              ),
              imageBytes != null
                  ? Image.memory(
                      imageBytes!,
                      fit: BoxFit.contain,
                      height: MediaQuery.of(context).size.height * 0.2,
                    )
                  : const CircularProgressIndicator(),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.grey.shade200,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  signInWithGoogle();
                },
                icon: Image.asset('assets/google_icon.png', height: 24),
                label: const Text("Continue with Google"),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.grey.shade200,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  signInWithFacebook();
                },
                icon: Image.asset('assets/facebook.jpg', height: 24),
                label: const Text("Continue with Facebook"),
              ),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("or"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 8),
              const Text("Already signed up with phone number?"),
              const SizedBox(height: 16),
              TextButton.icon(
                style: TextButton.styleFrom(
                    foregroundColor: EasyrideColors.vibrantGreen,
                    backgroundColor: const Color(0xFFF5EDFF),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    )),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
                icon: const Icon(Icons.phone),
                label: const Text("Log in with phone number"),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text.rich(
                  const TextSpan(
                    text: "By continuing, you agree to our ",
                    children: [
                      TextSpan(
                        text: "Terms of Service",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                      TextSpan(text: " and confirm that you have read our "),
                      TextSpan(
                        text: "Privacy Policy",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                      TextSpan(text: ", including our "),
                      TextSpan(
                        text: "Cookie Policy.",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    try {
      String? deviceToken;

      if (Platform.isAndroid) {
        deviceToken = await notificationService.getDeviceToken();
      } else {
        deviceToken = null;
      }
      print("🔁 Step 1: Google SignIn() shuru kiya...");
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        print("⚠️ User ne Google account choose nahi kiya (cancelled)");
        return;
      }

      print("✅ Step 2: User ne account choose kiya: ${googleUser.email}");
      print("ℹ️  Display Name: ${googleUser.displayName}");
      print("🔐 Getting Google Auth tokens...");

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print("✅ Step 3: Access Token: ${googleAuth.accessToken}");
      print("✅ Step 4: ID Token: ${googleAuth.idToken}");

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("🛠️ Step 5: Firebase Auth se login kar rahe hain...");
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      print("🎉 ✅ Step 6: Firebase login successful");
      print("👤 UID: ${user?.uid}");
      print("📧 Email: ${user?.email}");
      print("👨‍🦰 Name: ${user?.displayName}");
      print("Phone: ${user?.phoneNumber}");
      print("🖼️ Photo URL: ${user?.photoURL}");

      // 🔗 Step 7: Call backend API
      print("🌐 Step 7: Calling backend API...");

      final response = await http.post(
        Uri.parse('https://easymotorbike.asia/api/v1/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'type': 'google',
          'user_data': jsonEncode({
            'email': user?.email,
            'name': user?.displayName,
            'firebase_uid': user?.uid,
            'photo_url': user?.photoURL,
            'id_token': googleAuth.idToken,
          }),
          if (deviceToken != null) 'device_token': deviceToken,
        }),
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
            registereddate = responseData['data']['registered_date'];
          });

          print('Booking Token: $bookingtoken');
          print('Vehicle No.: $vehicleno');
          print('Vehicle_id: $vehicle_id');
          print('Registered Date: $registereddate');
          print('User ID: $userid');
          print('Token: $token');

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token!);
          await prefs.setString('user_id', userid!);
          await prefs.setString('registereddate', registereddate!);
          //await prefs.setString('mobileno', phoneNumber);

          print("✅ Stored mobile no: ${prefs.getString('mobileno')}");
          print(
              "✅ Stored registered date: ${prefs.getString('registereddate')}");

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
    setState(() {});
  }

  Future<void> signInWithFacebook() async {
    try {
      print("🔁 Facebook login shuru ho gaya...");
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        print("✅ Facebook login success: ${result.accessToken}");
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(result.accessToken!.tokenString);

        final userCredential = await FirebaseAuth.instance
            .signInWithCredential(facebookAuthCredential);

        final user = userCredential.user;

        print("🎉 ✅ Firebase login with Facebook success");
        print("👤 UID: ${user?.uid}");
        print("📧 Email: ${user?.email}");
        print("👨‍🦰 Name: ${user?.displayName}");
        print("🖼️ Photo URL: ${user?.photoURL}");

        // 🔗 Step: Call your backend API
        final response = await http.post(
          Uri.parse('https://easymotorbike.asia/api/v1/login'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'type': 'facebook',
            'user_data': jsonEncode({
              'email': user?.email,
              'name': user?.displayName,
              'firebase_uid': user?.uid,
              'photo_url': user?.photoURL,
            }),
          }),
        );

        if (response.statusCode == 200) {
          print("✅ Backend response: ${response.body}");
        } else {
          print("❌ API error: ${response.statusCode} - ${response.body}");
        }
      } else {
        print("❌ Facebook login failed: ${result.status}");
      }
    } catch (e) {
      print("❌ Facebook login error: $e");
    }
  }

  String? token;
  String? userid;
  String? bookingtoken;
  String? vehicleno;
  String? vehicle_id;
  String? registereddate;

  Future<void> navigateToHomeScreen() async {
    if (token != null) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User Successfully Logged In'.tr()),
          backgroundColor: EasyrideColors.successSnak,
          duration: (const Duration(seconds: 2)),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder:
                (context) => /*HomeScreen(
            Mobile: widget.phoneNumber,
            Token: token!,
            registered_date: registered_date!,
          ),*/
                    MainScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      setState(() {});
    }
  }
}

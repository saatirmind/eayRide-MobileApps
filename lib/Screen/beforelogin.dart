import 'dart:typed_data';

import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/NewScreen/login.dart';
import 'package:easymotorbike/main.dart';
import 'package:flutter/material.dart';

class BeamLoginScreen extends StatefulWidget {
  const BeamLoginScreen({super.key});

  @override
  State<BeamLoginScreen> createState() => _BeamLoginScreenState();
}

class _BeamLoginScreenState extends State<BeamLoginScreen>
    with WidgetsBindingObserver {
  Uint8List? imageBytes;

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
                onPressed: () {},
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
                onPressed: () {},
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
}

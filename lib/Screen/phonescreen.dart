import 'package:country_code_picker/country_code_picker.dart';
import 'package:easyride/Screen/otpscreen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneNumberScreen extends StatefulWidget {
  @override
  _PhoneNumberScreenState createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final Uri _url = Uri.parse('https://www.emrkl.com/');
  String countryCode = '+60';
  TextEditingController phoneController = TextEditingController();

  void sendOtp() {
    String phoneNumber = phoneController.text;
    if (phoneNumber.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please enter your phone number.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      print('OTP sent to: $countryCode $phoneNumber');

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                OtpScreen(phoneNumber: '$countryCode $phoneNumber')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/splash.png',
                width: 250,
                height: 300,
              ),
              SizedBox(height: 20),

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
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Enter your phone number',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                "Enter your phone number without '0'. By continuing, you agree to our Terms of Service.",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.yellow,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  minimumSize: Size(200, 50),
                ),
                onPressed: sendOtp,
                child: Text(
                  'NEXT',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Text(
                '6 digit code will be sent to your phone in a few seconds.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              // Terms and FAQ
              TextButton(
                onPressed: () async {
                  if (!await launchUrl(_url)) {
                    throw 'Could not launch $_url';
                  }
                },
                child: Text(
                  'TERMS OF SERVICE',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (!await launchUrl(_url)) {
                    throw 'Could not launch $_url';
                  }
                },
                child: Text(
                  'FAQ',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:easyride/DrawerWidget/DateInputFormatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  final String Mobile;

  final String Token;

  const ProfileScreen({super.key, required this.Mobile, required this.Token});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool promotionalEmails = false;
  final _dobController = TextEditingController();
  final _givenNameController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _emergencyController = TextEditingController();
  final _emergencyrelationController = TextEditingController();
  String _registered_date = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _dobController.dispose();
    _givenNameController.dispose();
    _familyNameController.dispose();
    _nationalityController.dispose();
    _emergencyController.dispose();
    _emergencyrelationController.dispose();

    _emailController.dispose();
    super.dispose();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PROFILE'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to EASYRIDE',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Please make sure to fill up all of the information below to start riding our motorbikes. The information is necessary for insurance purposes.',
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Phone Number',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Registered Date',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(widget.Mobile),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          _registered_date,
                          style: TextStyle(
                              color: Colors.green, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Enter Email',
                    prefixIcon: Icon(Icons.email),
                    suffix: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        '*',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    String pattern = r'^[a-zA-Z0-9._%+-]+@gmail\.com$';
                    RegExp regExp = RegExp(pattern);

                    if (!regExp.hasMatch(value)) {
                      return 'Please enter a valid Gmail address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _givenNameController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    suffix: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        '*',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    labelText: 'Given Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Given name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _familyNameController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.edit),
                    suffix: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        '*',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    labelText: 'Family Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Family name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _dobController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today),
                    suffix: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        '*',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    labelText: 'Date of Birth',
                    hintText: 'DD-MM-YYYY',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    DateInputFormatter(),
                  ],
                  validator: _validateDate,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _nationalityController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.public),
                    suffix: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        '*',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    labelText: 'Nationality',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your nationality';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _emergencyController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone),
                    labelText: 'Emergency Number',
                    suffix: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        '(Optional)',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emergencyrelationController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.group),
                    suffix: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        '(Optional)',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    labelText: 'Emergency Relation',
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.verified_user),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Account Verification Process\nTap to Start',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('Please prepare the following documents:'),
                      Row(
                        children: [
                          Icon(Icons.check, color: Colors.green),
                          SizedBox(width: 4),
                          Text('National Identification/Passport'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.check, color: Colors.green),
                          SizedBox(width: 4),
                          Text('Drivers License'),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Switch(
                      value: promotionalEmails,
                      onChanged: (bool value) {
                        setState(() {
                          promotionalEmails = value;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        'I do not want to receive promotions, newsletters, updates, and any other marketing communications via email, WhatsApp, or SMS.',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'By submitting my information, I acknowledge to have read and agreed to the Terms & Conditions and Privacy Policy documents.',
                ),
                SizedBox(height: 16),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitData,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.yellow,
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                        ),
                        child: Text('SUBMIT'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Date of Birth';
    }

    final dateParts = value.split('-');
    if (dateParts.length != 3) {
      return 'Please enter in DD-MM-YYYY format';
    }

    final day = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final year = int.tryParse(dateParts[2]);

    if (day == null || month == null || year == null) {
      return 'Invalid date format';
    }

    if (day < 1 || day > 31) {
      return 'Day should be between 1 and 31';
    }
    if (month < 1 || month > 12) {
      return 'Month should be between 1 and 12';
    }
    if (year < 1900 || year > DateTime.now().year) {
      return 'Enter a valid year';
    }

    return null;
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "All required fields must be filled with valid information, including name, dob, and other details. Please correct any errors to proceed."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    String dob;
    try {
      final parsedDate = DateFormat('dd-MM-yyyy').parse(_dobController.text);
      dob = DateFormat('yyyy-MM-dd').format(parsedDate);
      print('Formatted DOB: $dob');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid date format. Please check your input.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final token = await getToken();
    print('Token retrieved: $token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Token is missing. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String apiUrl = 'https://easyride.saatirmind.com.my/api/v1/update';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': _emailController.text,
          'given_name': _givenNameController.text,
          'dob': dob,
          'nationality': _nationalityController.text,
          'family_name': _familyNameController.text,
          'emergency_contact': _emergencyController.text,
          'emergency_relation': _emergencyrelationController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          await saveUserDataToPreferences();

          Future.delayed(Duration(seconds: 3), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DataScreen(
                  data: data,
                  Token: widget.Token,
                  Mobile: widget.Mobile,
                ),
              ),
            );
          });
          print('Profile Update Successful: ${data['message']}');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${data['message']}'),
              backgroundColor: Colors.red,
            ),
          );
          print('Error: ${data['message']}');
        }
      } else {
        print('Server Error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'This User name or email is already in use. Please choose a different name.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  Future<void> saveUserDataToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('email', _emailController.text);

    await prefs.setString('family_name', _familyNameController.text);

    await prefs.setString('nationality', _nationalityController.text);
    await prefs.setString('emergency_contact', _emergencyController.text);
    await prefs.setString(
        'emergency_relation', _emergencyrelationController.text);

    print("User data saved to SharedPreferences successfully!");
  }

  Future<void> loadUserDataFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _emailController.text = prefs.getString('email') ?? '';
    _givenNameController.text = prefs.getString('fullname') ?? '';
    _familyNameController.text = prefs.getString('family_name') ?? '';
    _dobController.text = prefs.getString('dateofbirth') ?? '';
    _nationalityController.text = prefs.getString('nationality') ?? '';
    _emergencyController.text = prefs.getString('emergency_contact') ?? '';
    _emergencyrelationController.text =
        prefs.getString('emergency_relation') ?? '';

    print("User data loaded from SharedPreferences!");
  }

  @override
  void initState() {
    super.initState();
    loadUserDataFromPreferences();
  }
}

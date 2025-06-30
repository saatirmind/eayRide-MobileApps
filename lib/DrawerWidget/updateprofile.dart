// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api, avoid_print, use_build_context_synchronously
import 'dart:convert';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/AppColors.dart/userprovider.dart';
import 'package:easymotorbike/AppColors.dart/webview.dart';
import 'package:http/http.dart' as http;
import 'package:easymotorbike/DrawerWidget/DateInputFormatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../AppColors.dart/profile_completion_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String mobile = '';
  String token = '';
  String registeredDate = '';
  String? profileImage;
  String passportNo = '';

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      mobile = prefs.getString('mobileno') ?? 'Unavilable Mobile no.';
      token = prefs.getString('token') ?? '';
      registeredDate = prefs.getString('registereddate') ?? '';
    });
  }

  bool promotionalEmails = false;
  final _dobController = TextEditingController();
  final _givenNameController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _emergencyController = TextEditingController();
  final _passportNumber = TextEditingController();

  final _emergencyrelationController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _dobController.dispose();
    _givenNameController.dispose();
    _familyNameController.dispose();
    _nationalityController.dispose();
    _emergencyController.dispose();
    _passportNumber.dispose();
    _emergencyrelationController.dispose();

    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
      setState(() {
        _dobController.text = formattedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PROFILE'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
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
                const Text(
                  'Welcome to EasyMotorbike',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please make sure to fill up all of the information below to start riding our motorbikes. The information is necessary for insurance purposes.',
                ),
                const SizedBox(height: 16),
                const Row(
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
                        child: Text(mobile),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          registeredDate,
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        profileImage != null && profileImage!.isNotEmpty
                            ? NetworkImage(profileImage!)
                            : const NetworkImage(
                                AppApi.Dummyprofile,
                              ),
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Enter Email',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '*',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.email),
                        counter: const Text(
                          '',
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
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Full Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '*',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    TextFormField(
                      controller: _givenNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.edit),
                        counter: const Text(
                          '',
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Given name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     const Row(
                //       children: [
                //         Text(
                //           'Family Name',
                //           style: TextStyle(
                //             fontSize: 16,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //         SizedBox(width: 4),
                //         Text(
                //           '*',
                //           style: TextStyle(
                //             color: Colors.red,
                //             fontSize: 16,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //       ],
                //     ),
                //     const SizedBox(height: 1),
                //     TextFormField(
                //       controller: _familyNameController,
                //       decoration: InputDecoration(
                //         border: OutlineInputBorder(
                //           borderRadius: BorderRadius.circular(10),
                //         ),
                //         prefixIcon: const Icon(Icons.edit),
                //         counter: const Text(
                //           '',
                //         ),
                //       ),
                //       validator: (value) {
                //         if (value == null || value.isEmpty) {
                //           return 'Please enter your Family name';
                //         }
                //         return null;
                //       },
                //     ),
                //   ],
                // ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Date of Birth',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '*',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    TextFormField(
                      controller: _dobController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: GestureDetector(
                          onTap: () => _selectDate(context),
                          child: const Icon(Icons.calendar_today),
                        ),
                        hintText: 'DD-MM-YYYY',
                        counter: const Text(
                          '',
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        DateInputFormatter(),
                      ],
                      validator: _validateDate,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Nationality',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '*',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    TextFormField(
                      controller: _nationalityController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.public),
                        counter: const Text(
                          '',
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your nationality';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Passport/NRIC Number',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '*',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    TextFormField(
                      controller: _passportNumber,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.badge),
                        counter: const Text(
                          '',
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Passport/NRIC Number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Emergency Number',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '(Optional)',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _emergencyController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.phone),
                        counter: const Text(
                          '',
                        ),
                      ),
                    ),
                  ],
                ),
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     const Row(
                //       children: [
                //         Text(
                //           'Emergency Relation',
                //           style: TextStyle(
                //             fontSize: 16,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //         SizedBox(width: 4),
                //         Text(
                //           '(Optional)',
                //           style: TextStyle(
                //             color: Colors.grey,
                //             fontSize: 14,
                //             fontWeight: FontWeight.w500,
                //           ),
                //         ),
                //       ],
                //     ),
                //     const SizedBox(height: 1),
                //     TextFormField(
                //       controller: _emergencyrelationController,
                //       decoration: InputDecoration(
                //         border: OutlineInputBorder(
                //           borderRadius: BorderRadius.circular(10),
                //         ),
                //         prefixIcon: const Icon(Icons.group),
                //         counter: const Text(
                //           '',
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
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
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: [
                      const TextSpan(
                        text:
                            'By submitting my information, I acknowledge to have read and agreed to the ',
                      ),
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WebViewPage(
                                  url: AppApi.term_condition,
                                ),
                              ),
                            );
                          },
                      ),
                      const TextSpan(
                        text: ' and ',
                      ),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WebViewPage(
                                  url: AppApi.privacy_policy,
                                ),
                              ),
                            );
                          },
                      ),
                      const TextSpan(
                        text: ' documents.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitData,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: EasyrideColors.buttontextColor,
                          backgroundColor: EasyrideColors.buttonColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isloading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('SUBMIT'),
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

  bool _isloading = false;
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
    if (_isloading) return;
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
        const SnackBar(
          content: Text('Invalid date format. Please check your input.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final token = await AppApi.getToken();
    print('Token retrieved: $token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token is missing. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    const String apiUrl = AppApi.Updateprofile;

    try {
      setState(() {
        _isloading = true;
      });
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: jsonEncode({
          'email': _emailController.text,
          'given_name': _givenNameController.text,
          'dob': dob,
          'nationality': _nationalityController.text,
          'family_name': _familyNameController.text,
          'emergency_contact': _emergencyController.text,
          'passport_or_nric_no': _passportNumber.text,
          'emergency_relation': _emergencyrelationController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          GetProfile(context);
          Provider.of<ProfileCompletionProvider>(context, listen: false)
              .fetchProfileCompletion();
          Navigator.pop(context);
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
          const SnackBar(
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
    setState(() {
      _isloading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
    loadUserData();
  }

  Future<void> fetchProfile() async {
    final token = await AppApi.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token is missing. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(AppApi.Getprofile),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        if (data['status'] == true) {
          final userInfo = data['data']['user_info'];
          final latestDoc = data['data']['latest_document'];
          final docsList = userInfo?['documents'] as List?;

          _dobController.text = userInfo['dateofbirth']?.toString() ?? '';
          _givenNameController.text = userInfo['firstname']?.toString() ?? '';
          _familyNameController.text =
              userInfo['family_name']?.toString() ?? '';
          _emailController.text = userInfo['email']?.toString() ?? '';
          _nationalityController.text =
              userInfo['nationality']?.toString() ?? '';
          _emergencyController.text =
              userInfo['emergency_contact']?.toString() ?? '';
          _emergencyrelationController.text =
              userInfo['emergency_relation']?.toString() ?? '';
          if (latestDoc != null && latestDoc['passport_or_nric_no'] != null) {
            passportNo = latestDoc['passport_or_nric_no'] as String;
          }
          if (passportNo.isEmpty && docsList != null && docsList.isNotEmpty) {
            for (var doc in docsList) {
              if (doc['passport_or_nric_no'] != null) {
                passportNo = doc['passport_or_nric_no'] as String;
                break;
              }
            }
          }

          _passportNumber.text = passportNo;
          setState(() {
            profileImage = userInfo['userImage'];
          });
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to fetch profile. Status Code: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('Error occurred: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unexpected error occurred.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

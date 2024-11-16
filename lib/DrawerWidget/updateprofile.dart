import 'package:easyride/DrawerWidget/DateInputFormatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatefulWidget {
  final String Mobile;

  const ProfileScreen({super.key, required this.Mobile});

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
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _dobController.dispose();
    _givenNameController.dispose();
    _familyNameController.dispose();
    _nationalityController.dispose();
    super.dispose();
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
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Enter Email',
                    prefixIcon: Icon(Icons.email),
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
                Text('Phone Number'),
                SizedBox(height: 1),
                Text(widget.Mobile),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _givenNameController,
                        decoration: InputDecoration(
                          labelText: 'Given Name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your given name';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _familyNameController,
                        decoration: InputDecoration(
                          labelText: 'Family Name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your family name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _dobController,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'DD/MM/YYYY',
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
                  child: ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.yellow,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: Text('SUBMIT'),
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

    final dateParts = value.split('/');
    if (dateParts.length != 3) {
      return 'Please enter in DD/MM/YYYY format';
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

  void _submitData() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final data = {
      'mobile': widget.Mobile,
      'dob': _dobController.text,
      'email': _emailController.text,
      'givenName': _givenNameController.text,
      'familyName': _familyNameController.text,
      'nationality': _nationalityController.text,
      'promotionalEmails': promotionalEmails,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Datascreen(data: data),
      ),
    );
  }
}

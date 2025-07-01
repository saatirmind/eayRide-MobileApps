// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/AppColors.dart/Ozopay.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentFormPage extends StatefulWidget {
  const PaymentFormPage({super.key});

  @override
  State<PaymentFormPage> createState() => _PaymentFormPageState();
}

class _PaymentFormPageState extends State<PaymentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _country = TextEditingController();
  final TextEditingController _state = TextEditingController();
  final TextEditingController _zip = TextEditingController();
  final TextEditingController _amount = TextEditingController();

  String _response = "";

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
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

      final url =
          Uri.parse('https://easymotorbike.asia/api/v1/payment/create-payment');
      final body = {
        "address": _address.text,
        "city": _city.text,
        "email": _email.text,
        "first_name": _firstName.text,
        "last_name": _lastName.text,
        "country": _country.text,
        "state": _state.text,
        "zip": _zip.text,
        "currencytext": 'MYR',
        "amount": _amount.text,
      };

      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'token': token,
          },
          body: json.encode(body),
        );

        print("Response Status Code: ${response.statusCode}");
        print("Raw Response Body: ${response.body}");
        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          if (result['status'] == true) {
            final data = result['data'];
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentWebView(data: data),
              ),
            );
          } else {
            setState(() {
              _response = "Error: ${result['message']}";
            });
          }
        } else {
          setState(() {
            _response = "Error: ${response.body}";
          });
        }
      } catch (e) {
        print("Exception: $e");
        setState(() {
          _response = "Error: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration inputDecoration(String label) => InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Form')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _address,
                      decoration: inputDecoration('Address'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _city,
                      decoration: inputDecoration('City'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _email,
                      decoration: inputDecoration('Email'),
                      validator: (value) =>
                          value!.isEmpty || !value.contains('@')
                              ? 'Enter valid email'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _firstName,
                      decoration: inputDecoration('First Name'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _lastName,
                      decoration: inputDecoration('Last Name'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _country,
                      decoration: inputDecoration('Country'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _state,
                      decoration: inputDecoration('State'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _zip,
                      decoration: inputDecoration('ZIP Code'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amount,
                      decoration: inputDecoration('Amount'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Submit Payment'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Response:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_response),
            ],
          ),
        ),
      ),
    );
  }
}

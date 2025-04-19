// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/Payment/nextscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Adding Credit/Debit Card"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Card Number:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _cardNumberController,
                decoration:
                    const InputDecoration(hintText: "16 digit card number"),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(19),
                  FilteringTextInputFormatter.digitsOnly,
                  CardNumberInputFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.replaceAll(" ", "").length != 16) {
                    return "Invalid card number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text("Expiration Date:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _expiryDateController,
                decoration: const InputDecoration(hintText: "MM/YY"),
                keyboardType: TextInputType.number,
                maxLength: 5,
                onChanged: (value) {
                  if (value.length == 2 &&
                      !_expiryDateController.text.contains('/')) {
                    _expiryDateController.text = '$value/';
                    _expiryDateController.selection =
                        TextSelection.fromPosition(
                      TextPosition(offset: _expiryDateController.text.length),
                    );
                  }
                },
                validator: (value) {
                  if (value == null ||
                      !RegExp(r"^(0[1-9]|1[0-2])\/\d{2}$").hasMatch(value)) {
                    return "Invalid expiration date";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text("CCV/CVV:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _cvvController,
                decoration: const InputDecoration(hintText: "CVC"),
                keyboardType: TextInputType.number,
                maxLength: 3,
                validator: (value) {
                  if (value == null || value.length != 3) {
                    return "Invalid CVV";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text("Name on Card:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _nameController,
                decoration:
                    const InputDecoration(hintText: "Full Name on Card"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Name is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "You may be charged RM10.00 as a test charge to ensure your payment method has sufficient balance. This charge is reversed immediately upon successful verification.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: EasyrideColors.buttonColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 4.0,
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              await Future.delayed(const Duration(seconds: 2));

                              setState(() {
                                _isLoading = false;
                              });

                              await saveCardToSharedPreferences();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Add card successfully!'),
                                    backgroundColor:
                                        EasyrideColors.successSnak),
                              );

                              await Future.delayed(const Duration(seconds: 3));

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const PaymentMethodScreen()),
                              );

                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: EasyrideColors.buttonColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.credit_card, color: Colors.black),
                                SizedBox(width: 5),
                                Text(
                                  "ADD",
                                  style: TextStyle(
                                      color: EasyrideColors.buttontextColor,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Need Help?"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveCardToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cardNumber = _cardNumberController.text.replaceAll(" ", "");
    String expiryDate = _expiryDateController.text;
    String cvv = _cvvController.text;
    String nameOnCard = _nameController.text;
    await prefs.setString('cardNumber', cardNumber);
    await prefs.setString('expiryDate', expiryDate);
    await prefs.setString('cvv', cvv);
    await prefs.setString('nameOnCard', nameOnCard);
    if (cardNumber.length >= 4) {
      String lastFourDigits = cardNumber.substring(cardNumber.length - 4);
      await prefs.setString('lastFourDigits', lastFourDigits);
    } else {
      print("Invalid card number");
    }
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text.replaceAll(" ", "");
    final buffer = StringBuffer();

    for (int i = 0; i < newText.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(" ");
      buffer.write(newText[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

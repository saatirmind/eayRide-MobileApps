import 'package:easyride/Payment/nextscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddCardScreen extends StatefulWidget {
  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Adding Credit/Debit Card"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Card Number:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(hintText: "16 digit card number"),
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
              SizedBox(height: 16),
              Text("Expiration Date:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _expiryDateController,
                decoration: InputDecoration(hintText: "MM/YY"),
                keyboardType: TextInputType.number,
                maxLength: 5,
                onChanged: (value) {
                  if (value.length == 2 &&
                      !_expiryDateController.text.contains('/')) {
                    _expiryDateController.text = value + '/';
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
              SizedBox(height: 16),
              Text("CCV/CVV:", style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _cvvController,
                decoration: InputDecoration(hintText: "CVC"),
                keyboardType: TextInputType.number,
                maxLength: 3,
                validator: (value) {
                  if (value == null || value.length != 3) {
                    return "Invalid CVV";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text("Name on Card:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(hintText: "Full Name on Card"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Name is required";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                "You may be charged RM10.00 as a test charge to ensure your payment method has sufficient balance. This charge is reversed immediately upon successful verification.",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 4.0,
                            ),
                          ),
                        )
                      : InkWell(
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });

                              await Future.delayed(Duration(seconds: 2));

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NextScreen(
                                    cardNumber: _cardNumberController.text,
                                    expiryDate: _expiryDateController.text,
                                    cvv: _cvvController.text,
                                    fullName: _nameController.text,
                                  ),
                                ),
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
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.credit_card, color: Colors.black),
                                SizedBox(width: 5),
                                Text(
                                  "ADD",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text("Need Help?"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

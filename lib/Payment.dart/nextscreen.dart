import 'package:flutter/material.dart';

class NextScreen extends StatelessWidget {
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String fullName;

  const NextScreen({
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required this.fullName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Card Details"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Card Number: $cardNumber"),
            Text("Expiration Date: $expiryDate"),
            Text("CVV: $cvv"),
            Text("Full Name: $fullName"),
          ],
        ),
      ),
    );
  }
}

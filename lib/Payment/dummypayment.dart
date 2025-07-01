import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/Payment/creditpack.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../AppColors.dart/walletapi.dart';

class PaymentsScreen4 extends StatelessWidget {
  const PaymentsScreen4({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _beamCreditsCard(context, walletProvider),
            const SizedBox(height: 24),
            const Text(
              "Payment method",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
                // children: [
                //   Image.asset('assets/visacardlogo.webp', height: 24),
                //   const SizedBox(width: 8),
                //   Image.asset('assets/mastercardlogo.png', height: 24),
                //   const SizedBox(width: 8),
                //   Image.asset('assets/touchngo_logo.png', height: 24),
                // ],
                ),
            const SizedBox(height: 8),
            const Text(
              "You can also add a payment method to pay for every ride.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.deepPurple),
              title: const Text("Add payment method"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            const SizedBox(height: 24),
            const Text(
              "Promotion",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const Icon(Icons.percent, color: Colors.deepPurple),
              title: const Text("Add credit code / gift card"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  _beamCreditsCard(BuildContext context, WalletProvider walletProvider) {
    return Container(
      decoration: BoxDecoration(
        color: EasyrideColors.vibrantGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "AVAILABLE EASYMOTORBIKE CREDITS",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            walletProvider.walletAmount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Image.asset('assets/visacardlogo.webp', height: 24),
              // const SizedBox(width: 8),
              // Image.asset('assets/mastercardlogo.png', height: 24),
              // const SizedBox(width: 8),
              // Image.asset('assets/touchngo_logo.png', height: 24),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreditPackScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: EasyrideColors.vibrantGreen,
              ),
              child: const Text("+ Top up credits"),
            ),
          ),
        ],
      ),
    );
  }
}

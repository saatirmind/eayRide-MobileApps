import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Passes & subscriptions"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            subscriptionCard(
              title: "Bukit Bintang - Weekly Ride Beam Pass",
              type: "Weekly subscription",
              price: "RM24.99/week",
              subtitle: "No more unlock or per minute fees!",
              tag: "Up to 15 mins daily",
            ),
            const SizedBox(height: 20),
            subscriptionCard(
              title: "Zero Unlock Fees - Subscription",
              type: "Monthly free unlock subscription",
              price: "RM10.00/month",
              subtitle: "Unlock a Beam for free any time you need",
              tag: "Unlimited unlock",
            ),
          ],
        ),
      ),
    );
  }

  Widget subscriptionCard({
    required String title,
    required String type,
    required String price,
    required String subtitle,
    required String tag,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.deepPurple.shade100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: EasyrideColors.Drawerheaderbackground,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            type,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(price, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          Text(subtitle),
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              tag,
              style: const TextStyle(color: Colors.deepPurple),
            ),
          ),
        ],
      ),
    );
  }
}

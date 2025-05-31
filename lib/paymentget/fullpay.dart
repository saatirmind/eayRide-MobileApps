import 'package:easymotorbike/paymentget/inquerypending.dart';
import 'package:easymotorbike/paymentget/inqueryrequest.dart';
import 'package:easymotorbike/paymentget/requestfunction.dart';
import 'package:flutter/material.dart';

Future<void> completePurchase(BuildContext context) async {
  // 1. Create order in your system
  final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';

  try {
    // 2. Initiate payment
    await initiateOzopayPayment(context);

    // 3. Check payment status (if not already handled in webview return)
    final status = await checkPaymentStatus(
      orderId: orderId,
      orderReference: orderId,
      amount: 1.00,
    );

    if (status['responseCode'] == '003') {
      // Pending - implement retry logic
      await handlePendingPayment(orderId, orderId, 100.00);
    }

    // 4. Handle successful payment
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment successful!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${e.toString()}')),
    );
  }
}

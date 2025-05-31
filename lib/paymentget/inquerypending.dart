import 'package:easymotorbike/paymentget/inqueryrequest.dart';

Future<void> handlePendingPayment(
    String orderId, String orderReference, double amount) async {
  int attempts = 0;
  const maxAttempts = 3;
  const retryInterval = Duration(minutes: 10);

  while (attempts < maxAttempts) {
    await Future.delayed(retryInterval);
    attempts++;

    try {
      final status = await checkPaymentStatus(
        orderId: orderId,
        orderReference: orderReference,
        amount: amount,
      );

      if (status['responseCode'] == '000') {
        // Payment successful
        return;
      } else if (status['responseCode'] != '003') {
        // Payment failed or cancelled
        throw Exception(
            'Payment failed with status: ${status['responseCode']}');
      }
    } catch (e) {
      if (attempts == maxAttempts) {
        // Final attempt failed
        throw e;
      }
    }
  }

  throw Exception('Payment still pending after $maxAttempts attempts');
}

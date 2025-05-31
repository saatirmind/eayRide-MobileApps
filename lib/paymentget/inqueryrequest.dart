import 'dart:convert';
import 'package:easymotorbike/paymentget/inquerysign.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> checkPaymentStatus({
  required String orderId,
  required String orderReference,
  required double amount,
}) async {
  const secretKey = '1940386255ad15c92f2';
  const endpoint = 'https://uatpayment.ozopay.com/api/Merchant/GetOrderStatus';

  final inquiryParams = {
    'currencyText': 'MYR',
    'customerPaymentPageText': 'TID0000001010',
    'orderId': orderId,
    'orderReference': orderReference,
    'purchaseAmount': amount,
  };

  // Generate signature
  inquiryParams['signature'] =
      generateInquirySignature(inquiryParams, secretKey);

  try {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: inquiryParams,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to check payment status');
    }
  } catch (e) {
    throw Exception('Error checking payment status: $e');
  }
}

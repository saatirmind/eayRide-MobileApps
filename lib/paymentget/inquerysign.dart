import 'dart:convert';
import 'package:crypto/crypto.dart';

String generateInquirySignature(Map<String, dynamic> params, String secretKey) {
  final concatenatedString = params['currencyText'] +
      params['customerPaymentPageText'] +
      (params['orderId'] ?? '') +
      (params['orderReference'] ?? '') +
      params['purchaseAmount'].toString() +
      secretKey;

  return sha256.convert(utf8.encode(concatenatedString)).toString();
}

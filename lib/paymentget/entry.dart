import 'dart:convert';
import 'package:crypto/crypto.dart';

String generatePaymentSignature(Map<String, dynamic> params, String secretKey) {
  final concatenatedString = params['address'] +
      params['city'] +
      params['country'] +
      params['currencyText'] +
      params['customerPaymentPageText'] +
      params['email'] +
      params['firstName'] +
      params['issameasbilling'] +
      params['lastName'] +
      params['orderDescription'] +
      params['orderDetail'] +
      params['phone'] +
      params['purchaseAmount'].toString() +
      params['shipAddress'] +
      params['shipCity'] +
      params['shipCountry'] +
      params['shipFirstName'] +
      params['shipLastName'] +
      params['shipState'] +
      params['shipZip'] +
      params['state'] +
      params['transactionOriginatedURL'] +
      params['zip'] +
      secretKey;

  return sha256.convert(utf8.encode(concatenatedString)).toString();
}

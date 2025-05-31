void handlePaymentResponse(String returnUrl) {
  final uri = Uri.parse(returnUrl);
  final params = uri.queryParameters;

  // Check payment status
  if (params['responseCode'] == '000') {
    // Success
    print('Payment successful! Order ID: ${params['orderReference']}');
  } else {
    // Failed
    print('Payment failed. Error: ${params['errorMessage']}');
  }

  // You should also verify the signature in the response
  if (!_verifyResponseSignature(params)) {
    print('Warning: Response signature verification failed!');
  }
}

bool _verifyResponseSignature(Map<String, String> params) {
  // Implement signature verification similar to generation
  // Compare with the signature received in params
  return true;
}

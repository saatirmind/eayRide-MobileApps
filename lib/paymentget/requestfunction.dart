import 'package:easymotorbike/paymentget/entry.dart';
import 'package:easymotorbike/paymentget/handler.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> initiateOzopayPayment(BuildContext context) async {
  const secretKey = '1940386255ad15c92f2';
  const endpoint = 'https://uatpayment.ozopay.com/PaymentEntry/PaymentOption';

  final paymentParams = {
    'address': 'NO. 1 JALAN KUALA LUMPUR',
    'city': 'KUALA LUMPUR',
    'country': 'MY',
    'currencyText': 'MYR',
    'customerPaymentPageText': 'TID0000001010',
    'email': 'customer@example.com',
    'firstName': 'John',
    'lastName': 'Doe',
    'orderDescription': 'ORDER10548',
    'orderDetail': 'Product 1 x 2',
    'phone': '60123456789',
    'purchaseAmount': 1.00,
    'issameasbilling': '0',
    'shipAddress': 'NO. 5 JALAN KETARI',
    'shipCity': 'BENTONG',
    'shipCountry': 'MY',
    'shipFirstName': 'John',
    'shipLastName': 'Doe',
    'shipState': 'PAHANG',
    'shipZip': '28700',
    'state': 'SELANGOR',
    'transactionOriginatedURL':
        'https://easymotorbike.asia/api/v1/payment/callback',
    'zip': '58000',
  };

  // Signature generate karo
  paymentParams['signature'] =
      generatePaymentSignature(paymentParams, secretKey);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PaymentWebViewScreen(
        endpoint: endpoint,
        params: paymentParams,
      ),
    ),
  );
}

class PaymentWebViewScreen extends StatefulWidget {
  final String endpoint;
  final Map<String, dynamic> params;

  const PaymentWebViewScreen({
    super.key,
    required this.endpoint,
    required this.params,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            // Agar redirect hua toh loading dikhayein
            setState(() {
              _isLoading = true;
            });

            // Agar payment response wali URL ho toh handle karo
            if (request.url.startsWith(
                widget.params['transactionOriginatedURL'] as String)) {
              handlePaymentResponse(request.url);
              Navigator.pop(context);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onPageFinished: (url) {
            // Page jab fully load ho gaya
            Future.delayed(const Duration(seconds: 1), () {
              setState(() {
                _isLoading = false;
              });
            });
          },
        ),
      )
      ..loadHtmlString(_buildPaymentForm());
  }

  String _buildPaymentForm() {
    final fields = widget.params.entries.map((e) {
      return '<input type="hidden" name="${e.key}" value="${e.value}">';
    }).join();
    return '''
      <html>
        <body onload="document.forms[0].submit()">
          <form id="payform" action="${widget.endpoint}" method="POST">
            $fields
          </form>
        </body>
      </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Gateway'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.7,
              child: WebViewWidget(controller: _controller),
            ),
          ),
          if (_isLoading)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

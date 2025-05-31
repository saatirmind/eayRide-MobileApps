// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:webview_flutter/webview_flutter.dart';

// class PaymentPage extends StatefulWidget {
//   @override
//   _PaymentPageState createState() => _PaymentPageState();
// }

// class _PaymentPageState extends State<PaymentPage> {
//   late final WebViewController _controller;
//   String? paymentUrl;
//   bool isLoading = true;
//   String orderId = "";
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     print("📲 initState called");
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onNavigationRequest: (request) {
//             print("🔁 Navigation Request URL: ${request.url}");
//             if (request.url.contains("callback")) {
//               print("✅ Callback URL detected: ${request.url}");
//               checkPaymentStatus();
//               return NavigationDecision.prevent;
//             }
//             return NavigationDecision.navigate;
//           },
//         ),
//       );
//     createPayment();
//   }

//   Future<void> createPayment() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });

//     orderId = DateTime.now().millisecondsSinceEpoch.toString();
//     print("📦 Creating payment with Order ID: $orderId");

//     final queryParameters = {
//       "amount": "1.00",
//       "currency": "MYR",
//       "merchantCode": "CUS0000155",
//       "terminalId": "TID0000001010",
//       "secretKey": "1940386255ad15c92f2",
//       "orderId": orderId,
//       "productDescription": "Test Product",
//       "customerName": "John Doe",
//       "customerEmail": "john@example.com",
//       "returnUrl": "https://uatpayment.ozopay.com/PaymentEntry/PaymentOption",
//     };

//     final uri = Uri.https(
//       'easymotorbike.asia',
//       '/api/v1/payment/create-payment',
//       queryParameters,
//     );

//     try {
//       final response = await http.get(uri);
//       print("📨 Response Body: ${response.body}");

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print("📊 Parsed Response JSON: $data");

//         if (data['status'] == true && data['data'] == true) {
//           final message = data['message']?[0] ?? 'Payment successful!';
//           showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//               title: Text("✅ Payment Success"),
//               content: Text(message),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     Navigator.pop(context);
//                   },
//                   child: Text("OK"),
//                 ),
//               ],
//             ),
//           );
//           setState(() {
//             isLoading = false;
//           });
//         } else if (data.containsKey('paymentUrl') &&
//             data['paymentUrl'] != null) {
//           paymentUrl = data['paymentUrl'];
//           print("✅ Payment URL received: $paymentUrl");
//           _controller.loadRequest(Uri.parse(paymentUrl!));
//           setState(() {
//             isLoading = false;
//           });
//         } else {
//           print("❌ paymentUrl is null or missing in response JSON");
//           setState(() {
//             errorMessage = "Payment URL not received from server.";
//             isLoading = false;
//           });
//         }
//       } else {
//         print("❌ Payment API failed with status code: ${response.statusCode}");
//         setState(() {
//           errorMessage = "Payment API failed: ${response.statusCode}";
//           isLoading = false;
//         });
//       }
//     } catch (e, stacktrace) {
//       print("❌ Exception in createPayment:");
//       print("Error: $e");
//       print("Stacktrace: $stacktrace");
//       setState(() {
//         errorMessage = "Error occurred: $e";
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> checkPaymentStatus() async {
//     final url =
//         Uri.parse('https://uatpayment.ozopay.com/api/Merchant/GetOrderStatus');

//     print("🔍 Checking payment status for Order ID: $orderId");

//     final postBody = {
//       'merchantCode': 'CUS0000155',
//       'orderId': orderId,
//     };

//     try {
//       final response = await http.post(url, body: postBody);
//       print("📨 Status API Response Body: ${response.body}");

//       if (response.statusCode == 200) {
//         final result = jsonDecode(response.body);
//         final status = result['status'] ?? "Unknown";

//         if (!mounted) return;

//         showDialog(
//           context: context,
//           builder: (_) => AlertDialog(
//             title: Text("Payment Status"),
//             content: Text("Status: $status"),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   Navigator.pop(context);
//                 },
//                 child: Text("OK"),
//               )
//             ],
//           ),
//         );
//       } else {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to check payment status.")),
//         );
//       }
//     } catch (e) {
//       print("❌ Exception in checkPaymentStatus:");
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error checking payment status.")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Ozopay Payment"),
//         centerTitle: true,
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : paymentUrl != null
//               ? WebViewWidget(controller: _controller)
//               : Center(
//                   child: Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.error, color: Colors.red, size: 60),
//                         SizedBox(height: 10),
//                         Text(
//                           errorMessage ?? "Unable to load payment page.",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(fontSize: 16, color: Colors.red),
//                         ),
//                         SizedBox(height: 20),
//                         ElevatedButton(
//                           onPressed: () {
//                             createPayment();
//                           },
//                           child: Text("Try Again"),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  final Map<String, dynamic> data;

  const PaymentWebView({super.key, required this.data});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    final html = '''
    <html>
    <body onload="document.forms[0].submit()">
      <form method="post" action="https://uatpayment.ozopay.com/PaymentEntry/PaymentOption">
        <input name="address" value="${widget.data['address']}" />
        <input name="city" value="${widget.data['city']}" />
        <input name="country" value="${widget.data['country']}" />
        <input name="currencytext" value="${widget.data['currencytext']}" />
        <input name="customerPaymentPageText" value="${widget.data['customerPaymentPageText']}" />
        <input name="email" value="${widget.data['email']}" />
        <input name="firstname" value="${widget.data['firstName']}" />
        <input name="isSameAsBilling" value="${widget.data['isSameAsBilling']}" />
        <input name="lastname" value="${widget.data['lastName']}" />
        <input name="orderDescription" value="${widget.data['orderDescription']}" />
        <input name="orderDetail" value="${widget.data['orderDetail']}" />
        <input name="phone" value="${widget.data['phone']}" />
        <input name="purchaseamount" value="${widget.data['purchaseAmount']}" />
        <input name="state" value="${widget.data['state']}" />
        <input name="transactionOriginatedURL" value="https://easymotorbike.asia/api/v1/payment/callback">
        <input name="zip" value="${widget.data['zip']}" />
        <input name="signature" value="${widget.data['signature']}" />
      </form>
    </body>
    </html>
    ''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Redirecting to Payment")),
      body: Center(
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.7,
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }
}

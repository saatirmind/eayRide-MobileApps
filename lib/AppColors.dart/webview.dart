// ignore_for_file: deprecated_member_use
import 'package:easymotorbike/AppColors.dart/walletapi.dart';
//import 'package:easymotorbike/Payment/Easyridecredits.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../bottombaar/bottodummy.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  bool isLoading = true;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (finish) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      );
  }

  Future<bool> _handleBackNavigation() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackNavigation,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: WebViewWidget(controller: _controller),
              ),
              if (isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}

class WebViewPage2 extends StatefulWidget {
  final String url;

  const WebViewPage2({super.key, required this.url});

  @override
  State<WebViewPage2> createState() => _WebViewPage2State();
}

class _WebViewPage2State extends State<WebViewPage2> {
  bool isLoading = true;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print("🌐 Page Started: $url");
          },
          onPageFinished: (String url) {
            print("✅ Page Finished: $url");
            setState(() {
              isLoading = false;
            });

            if (url == 'https://easymotorbike.asia/api/v1/payment/callback') {
              print(
                  "✅ Callback URL detected, closing WebView and resetting stack...");

              Provider.of<WalletProvider>(context, listen: false)
                  .fetchWalletHistory(context);

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainScreen2()),
                (Route<dynamic> route) => false,
              );
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            print("➡️ Navigation Request: ${request.url}");
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<bool> _handleBackNavigation() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackNavigation,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: WebViewWidget(controller: _controller),
              ),
              if (isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}

class WebViewPage3 extends StatefulWidget {
  final String url;

  const WebViewPage3({super.key, required this.url});

  @override
  State<WebViewPage3> createState() => _WebViewPage3State();
}

class _WebViewPage3State extends State<WebViewPage3> {
  bool isLoading = true;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print("🌐 Page Started: $url");
          },
          onPageFinished: (String url) {
            print("✅ Page Finished: $url");
            setState(() {
              isLoading = false;
            });

            if (url == 'https://easymotorbike.asia/api/v1/payment/callback') {
              print("✅ Callback URL detected, closing WebView...");
              Navigator.pop(context);
              Provider.of<WalletProvider>(context, listen: false)
                  .fetchWalletHistory(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    '🎉 Your amount added in your wallet.\nUse this amount to book a ride.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  duration: const Duration(seconds: 5),
                  backgroundColor: Colors.deepPurpleAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            print("➡️ Navigation Request: ${request.url}");
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<bool> _handleBackNavigation() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackNavigation,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: WebViewWidget(controller: _controller),
              ),
              if (isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}

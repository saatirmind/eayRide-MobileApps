import 'dart:convert';
import 'package:easyride/AppColors.dart/EasyrideAppColors.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class WalletHistoryScreen extends StatefulWidget {
  const WalletHistoryScreen({Key? key}) : super(key: key);

  @override
  State<WalletHistoryScreen> createState() => _WalletHistoryScreenState();
}

class _WalletHistoryScreenState extends State<WalletHistoryScreen> {
  List<dynamic> walletHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _initializeData() async {
    await _fetchWalletHistory();
  }

  Future<void> _fetchWalletHistory() async {
    final token = await getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token is missing. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String apiUrl = AppApi.getWallet;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
      );

      print('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          setState(() {
            walletHistory = data['data']['wallet_history'] ?? [];
          });
        } else {
          print('Error: ${data['message']}');
        }
      } else {
        print('Server Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return "N/A";
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd-MM-yyyy').format(dateTime);
    } catch (e) {
      return "Invalid Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet History"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: walletHistory.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: ListView.builder(
                itemCount: walletHistory.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = walletHistory[index];
                  return Card(
                    elevation: 2,
                    child: ListTile(
                      title: Row(
                        children: [
                          Text(
                            'Total Amount: \n  ${item['total_amount']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Updated at:\n${_formatDate(item['created_at'])}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: Text(
                        '${item['amount']} RM\n${item['is_credit']?.toUpperCase() ?? "N/A"}',
                        style: TextStyle(
                          fontSize: 16,
                          color: (item['is_credit'] == 'credit')
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

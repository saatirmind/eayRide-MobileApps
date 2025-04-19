import 'package:easymotorbike/AppColors.dart/walletapi.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WalletHistoryScreen extends StatelessWidget {
  const WalletHistoryScreen({super.key});

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
    final provider = Provider.of<WalletProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet History"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: provider.walletHistory.isEmpty
          ? const Center(child: Text("No history found."))
          : ListView.builder(
              itemCount: provider.walletHistory.length,
              itemBuilder: (context, index) {
                final item = provider.walletHistory[index];
                return Card(
                  elevation: 2,
                  child: ListTile(
                    title: Row(
                      children: [
                        Text(
                          'Total Amount: \n ${item['total_amount_label']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Updated at:\n${_formatDate(item['created_at'])}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Text(
                      '${item['amount_label']} \n${item['is_credit']?.toUpperCase() ?? "N/A"}',
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
    );
  }
}

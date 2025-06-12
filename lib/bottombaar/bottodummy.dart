import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/AppColors.dart/userprovider.dart';
import '../AppColors.dart/walletapi.dart';
import '../Drawer/drawer.dart';
import '../DrawerWidget/healp.dart';
import '../Payment/dummypayment.dart';
import '../Screen/Qrscannerscreen.dart';
import '../Dummyscreen/dummyhome.dart';
import '../Screen/homescreen.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen9(),
    const PaymentsScreen4(),
    const HomeScreen(
      Mobile: '',
      Token: '',
      registered_date: '',
    ),
    const HelpScreen(),
    const Drawerscreen(),
  ];

  @override
  void initState() {
    super.initState();
    GetProfile(context);
    Provider.of<WalletProvider>(context, listen: false)
        .fetchWalletHistory(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAndShowMonthlyPass();
    });
  }

  Future<void> _fetchAndShowMonthlyPass() async {
    final token = await AppApi.getToken();
    final uri =
        Uri.parse('https://easymotorbike.asia/api/v1/popup-monthly-pass');

    try {
      final response = await http.get(
        uri,
        headers: {
          'token': token!,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final dataList = jsonData['data'];

        if (dataList != null && dataList.isNotEmpty) {
          final model = MonthlyPassModel.fromJson(dataList[0]);

          if (model.show) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => _MonthlyPassDialog(data: model),
            );
          }
        }
      } else {
        print("⚠️ Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception in popup API: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.fixedCircle,
        backgroundColor: Colors.white,
        activeColor: EasyrideColors.vibrantGreen,
        color: Colors.grey,
        initialActiveIndex: 0,
        items: const [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.account_balance_wallet, title: 'Payments'),
          TabItem(icon: Icons.qr_code_scanner),
          TabItem(icon: Icons.support, title: 'Support'),
          TabItem(icon: Icons.menu, title: 'Menu'),
        ],
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

// =======================
// Pop-up with only image
// =======================
class _MonthlyPassDialog extends StatelessWidget {
  final MonthlyPassModel data;
  const _MonthlyPassDialog({required this.data});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: EasyrideColors.pureWhite,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                data.imageUrl,
                fit: BoxFit.fill,
                height: MediaQuery.sizeOf(context).height * 0.45,
                width: MediaQuery.sizeOf(context).width * 0.7,
              ),
            ),

            // ❌ Close Button (top-left)
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),

            // ✅ Buy Pass Button (bottom center)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  // Navigation to purchase screen if needed
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: const BoxDecoration(
                    color: EasyrideColors.Drawerheaderbackground,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Buy Pass',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================
// MonthlyPassModel (Only image)
// ============================
class MonthlyPassModel {
  final String imageUrl;
  final bool show;

  MonthlyPassModel({required this.imageUrl, required this.show});

  factory MonthlyPassModel.fromJson(Map<String, dynamic> json) {
    return MonthlyPassModel(
      imageUrl: json['image'] ?? '',
      show: json['show']?.toString().toLowerCase() == 'true',
    );
  }
}

import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/Dummyscreen/dummyhome.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen9(),
    Center(child: Text('💰 Payments Screen')),
    Center(child: Text('📷 Scan QR Screen')),
    Center(child: Text('📞 Support Screen')),
    Center(child: Text('📋 Menu Screen')),
  ];

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

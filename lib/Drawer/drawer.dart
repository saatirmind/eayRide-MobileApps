// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously
import 'package:easy_localization/easy_localization.dart';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/AppColors.dart/webview.dart';
//import 'package:easymotorbike/AppColors.dart/webview.dart';
import 'package:easymotorbike/DrawerWidget/Logoutfunction.dart';
import 'package:easymotorbike/DrawerWidget/Tourist_attraction.dart';
import 'package:easymotorbike/DrawerWidget/healp.dart';
import 'package:easymotorbike/DrawerWidget/history.dart';
import 'package:easymotorbike/DrawerWidget/promotions.dart';
import 'package:easymotorbike/DrawerWidget/redeemcoupon.dart';
import 'package:easymotorbike/DrawerWidget/updateprofile.dart';
//import 'package:easymotorbike/DrawerWidget/walletpage.dart';
import 'package:easymotorbike/Payment/Easyridecredits.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Drawerscreen extends StatefulWidget {
  final String Firstname;
  final String Mobile;
  final String Token;
  final String registered_date;

  const Drawerscreen({
    super.key,
    required this.Mobile,
    required this.Token,
    required this.Firstname,
    required this.registered_date,
  });

  @override
  State<Drawerscreen> createState() => _DrawerscreenState();
}

class _DrawerscreenState extends State<Drawerscreen> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: EasyrideColors.Drawerbackground,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 150,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: EasyrideColors.Drawerheaderbackground,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                              Mobile: widget.Mobile,
                              Token: widget.Token,
                              registered_date: widget.registered_date)),
                    );
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.account_circle,
                        color: EasyrideColors.Drawerheadertext,
                        size: 40,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          Text(
                            widget.Firstname,
                            style: const TextStyle(
                              color: EasyrideColors.Drawerheadertext,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.Mobile,
                            style: const TextStyle(
                                color: EasyrideColors.Drawerheadertext,
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.map_outlined,
                color: EasyrideColors.Drawericon,
              ),
              title: Text('Main'.tr(),
                  style: const TextStyle(
                    color: EasyrideColors.Drawertext,
                  )),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.wallet,
                color: EasyrideColors.Drawericon,
              ),
              title: Text('Wallet'.tr(),
                  style: const TextStyle(
                    color: EasyrideColors.Drawertext,
                  )),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreditsReloadScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.local_offer_outlined,
                color: EasyrideColors.Drawericon,
              ),
              title: Text('Promotions'.tr(),
                  style: const TextStyle(
                    color: EasyrideColors.Drawertext,
                  )),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CouponListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.redeem,
                color: EasyrideColors.Drawericon,
              ),
              title: Text('Redeem'.tr(),
                  style: const TextStyle(
                    color: EasyrideColors.Drawertext,
                  )),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AppliedCouponListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.location_on,
                color: EasyrideColors.Drawericon,
              ),
              title: Text('Tourist Attraction',
                  style: const TextStyle(
                    color: EasyrideColors.Drawertext,
                  )),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TouristScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.history,
                color: EasyrideColors.Drawericon,
              ),
              title: Text('History'.tr(),
                  style: const TextStyle(
                    color: EasyrideColors.Drawertext,
                  )),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BookingHistoryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.help_outline,
                color: EasyrideColors.Drawericon,
              ),
              title: Text('Help'.tr(),
                  style: const TextStyle(
                    color: EasyrideColors.Drawertext,
                  )),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpScreen()),
                );
              },
            ),
            Card(
              color: EasyrideColors.Drawerheaderbackground,
              elevation: 3,
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.power_settings_new,
                      color: EasyrideColors.Drawerheadertext,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Logout'.tr(),
                      style: const TextStyle(
                          color: EasyrideColors.Drawerheadertext),
                    ),
                  ],
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: EasyrideColors.Drawerheaderbackground,
                        title: const Center(
                          child: Icon(
                            Icons.logout,
                            size: 64,
                            color: Colors.red,
                          ),
                        ),
                        content: const Text(
                          'Are you sure you want to log out?',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        actionsAlignment: MainAxisAlignment.spaceEvenly,
                        actions: <Widget>[
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'No',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: () {
                                logout(context);
                              },
                              child: const Text(
                                'Yes',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            const SpacerWidget(),
            ListTile(
              title: Center(
                child: Text(
                  'Follow Us'.tr(),
                  style: const TextStyle(
                      color: EasyrideColors.Drawertext, fontSize: 18),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.facebook,
                    color: EasyrideColors.Drawericon,
                  ),
                  onPressed: () async {
                    final url = Uri.parse(
                        'https://www.facebook.com/easymotorbikerentalkl');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Could not launch Facebook page')),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.instagram,
                    color: EasyrideColors.Drawericon,
                  ),
                  onPressed: () async {
                    final url =
                        Uri.parse('https://www.instagram.com/easymotorbikekl/');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Could not launch Facebook page')),
                      );
                    }
                  },
                  // onPressed: () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => const WebViewPage(
                  //         url: 'https://www.tiktok.com/@easymotorbikerentalkl',
                  //       ),
                  //     ),
                  //   );
                  // },
                ),
                IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.tiktok,
                    color: EasyrideColors.Drawericon,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WebViewPage(
                          url: 'https://www.tiktok.com/@easymotorbikerentalkl',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class SpacerWidget extends StatelessWidget {
  const SpacerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 10);
  }
}

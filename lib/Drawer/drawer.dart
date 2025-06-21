// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously
import 'package:easy_localization/easy_localization.dart';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/AppColors.dart/profile_completion_provider.dart';
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
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../AppColors.dart/userprovider.dart';

/* class Drawerscreen extends StatefulWidget {
  const Drawerscreen({
    super.key,
  });

  @override
  State<Drawerscreen> createState() => _DrawerscreenState();
}

class _DrawerscreenState extends State<Drawerscreen> {
  String? mobile;
  String? token;
  String? registeredDate;
  String? firstname;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      mobile = prefs.getString('mobileno');
      token = prefs.getString('token');
      registeredDate = prefs.getString('registereddate');
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: EasyrideColors.Drawerbackground,
      body: ListView(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    Mobile: mobile ?? '',
                    Token: token ?? '',
                    registered_date: registeredDate ?? '',
                  ),
                ),
              );
            },
            child: Container(
              height: MediaQuery.of(context).size.height * 0.2,
              width: double.infinity,
              color: EasyrideColors.Drawerheaderbackground,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_circle,
                    color: EasyrideColors.Drawerheadertext,
                    size: 40,
                  ),
                  const SizedBox(width: 10),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userProvider.firstName,
                          style: const TextStyle(
                            color: EasyrideColors.Drawerheadertext,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          (mobile != null && mobile!.isNotEmpty)
                              ? mobile!
                              : (userProvider.email.isNotEmpty
                                  ? userProvider.email
                                  : "Not available"),
                          style: const TextStyle(
                            color: EasyrideColors.Drawerheadertext,
                            fontSize: 16,
                          ),
                        ),
                      ]),
                  const Spacer(),
                  const Icon(
                    Icons.edit,
                    color: EasyrideColors.Drawerheadertext,
                  ),
                  const SizedBox(
                    width: 10,
                  )
                ],
              ),
            ),
          ),
          // ListTile(
          //   leading: const Icon(
          //     Icons.map_outlined,
          //     color: EasyrideColors.Drawericon,
          //   ),
          //   title: Text('Main'.tr(),
          //       style: const TextStyle(
          //         color: EasyrideColors.Drawertext,
          //       )),
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          // ),
          ListTile(
            leading: const Icon(
              Icons.wallet,
              color: EasyrideColors.Drawericon,
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
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
            trailing: const Icon(
              Icons.arrow_forward_ios,
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
            trailing: const Icon(
              Icons.arrow_forward_ios,
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
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: EasyrideColors.Drawericon,
            ),
            title: const Text('Tourist Attraction',
                style: TextStyle(
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
            trailing: const Icon(
              Icons.arrow_forward_ios,
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
            trailing: const Icon(
              Icons.arrow_forward_ios,
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
          Spacer(),
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
                    style:
                        const TextStyle(color: EasyrideColors.Drawerheadertext),
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
          //     ListTile(
          //       title: Center(
          //         child: Text(
          //           'Follow Us'.tr(),
          //           style: const TextStyle(
          //               color: EasyrideColors.Drawertext, fontSize: 18),
          //         ),
          //       ),
          //     ),
          //     Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //       children: [
          //         IconButton(
          //           icon: const Icon(
          //             FontAwesomeIcons.facebook,
          //             color: EasyrideColors.Drawericon,
          //           ),
          //           onPressed: () async {
          //             final url = Uri.parse(
          //                 'https://www.facebook.com/easymotorbikerentalkl');
          //             if (await canLaunchUrl(url)) {
          //               await launchUrl(
          //                 url,
          //                 mode: LaunchMode.externalApplication,
          //               );
          //             } else {
          //               ScaffoldMessenger.of(context).showSnackBar(
          //                 const SnackBar(
          //                     content: Text('Could not launch Facebook page')),
          //               );
          //             }
          //           },
          //         ),
          //         IconButton(
          //           icon: const Icon(
          //             FontAwesomeIcons.instagram,
          //             color: EasyrideColors.Drawericon,
          //           ),
          //           onPressed: () async {
          //             final url =
          //                 Uri.parse('https://www.instagram.com/easymotorbikekl/');
          //             if (await canLaunchUrl(url)) {
          //               await launchUrl(
          //                 url,
          //                 mode: LaunchMode.externalApplication,
          //               );
          //             } else {
          //               ScaffoldMessenger.of(context).showSnackBar(
          //                 const SnackBar(
          //                     content: Text('Could not launch Facebook page')),
          //               );
          //             }
          //           },
          //           // onPressed: () {
          //           //   Navigator.push(
          //           //     context,
          //           //     MaterialPageRoute(
          //           //       builder: (context) => const WebViewPage(
          //           //         url: 'https://www.tiktok.com/@easymotorbikerentalkl',
          //           //       ),
          //           //     ),
          //           //   );
          //           // },
          //         ),
          //         IconButton(
          //           icon: const Icon(
          //             FontAwesomeIcons.tiktok,
          //             color: EasyrideColors.Drawericon,
          //           ),
          //           onPressed: () {
          //             Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                 builder: (context) => const WebViewPage(
          //                   url: 'https://www.tiktok.com/@easymotorbikerentalkl',
          //                 ),
          //               ),
          //             );
          //           },
          //         ),
          //       ],
          //     ),
          //     const SizedBox(height: 20),
          //   ],
        ],
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
}   */

class Drawerscreen extends StatefulWidget {
  const Drawerscreen({super.key});

  @override
  State<Drawerscreen> createState() => _DrawerscreenState();
}

class _DrawerscreenState extends State<Drawerscreen> {
  String? mobile;
  String? token;
  String? registeredDate;
  String? appVersion;

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadAppVersion();
  }

  // double? profilePercent;
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      mobile = prefs.getString('mobileno');
      token = prefs.getString('token');
      registeredDate = prefs.getString('registereddate');
    });
  }

  Future<void> loadAppVersion() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      appVersion = prefs.getString('appVersion');
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final profileProvider = Provider.of<ProfileCompletionProvider>(context);

    return Scaffold(
      backgroundColor: EasyrideColors.Drawerbackground,
      body: Column(
        children: [
          // 🔼 Scrollable content
          Expanded(
            child: ListView(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: double.infinity,
                    color: EasyrideColors.Drawerheaderbackground,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        profileProvider.profilePercent != null
                            ? CircularPercentIndicator(
                                radius: 30.0,
                                lineWidth: 5.0,
                                animation: true,
                                percent:
                                    (profileProvider.profilePercent! / 100),
                                center: Text(
                                  "${profileProvider.profilePercent!.toInt()}%",
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: EasyrideColors.Drawerheadertext,
                                  ),
                                ),
                                progressColor: Colors.blue,
                                backgroundColor: Colors.grey.shade300,
                                circularStrokeCap: CircularStrokeCap.round,
                              )
                            : const CircularProgressIndicator(),
                        const SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProvider.firstName,
                              style: const TextStyle(
                                color: EasyrideColors.Drawerheadertext,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              (mobile != null && mobile!.isNotEmpty)
                                  ? mobile!
                                  : (userProvider.email.isNotEmpty
                                      ? userProvider.email
                                      : "Not available"),
                              style: const TextStyle(
                                color: EasyrideColors.Drawerheadertext,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.edit,
                          color: EasyrideColors.Drawerheadertext,
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.wallet,
                      color: EasyrideColors.Drawericon),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: EasyrideColors.Drawericon),
                  title: Text('Wallet'.tr(),
                      style: const TextStyle(color: EasyrideColors.Drawertext)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreditsReloadScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.local_offer_outlined,
                      color: EasyrideColors.Drawericon),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: EasyrideColors.Drawericon),
                  title: Text('Promotions'.tr(),
                      style: const TextStyle(color: EasyrideColors.Drawertext)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CouponListScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.redeem,
                      color: EasyrideColors.Drawericon),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: EasyrideColors.Drawericon),
                  title: Text('Redeem'.tr(),
                      style: const TextStyle(color: EasyrideColors.Drawertext)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const AppliedCouponListScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.location_on,
                      color: EasyrideColors.Drawericon),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: EasyrideColors.Drawericon),
                  title: const Text('Tourist Attraction',
                      style: TextStyle(color: EasyrideColors.Drawertext)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TouristScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history,
                      color: EasyrideColors.Drawericon),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: EasyrideColors.Drawericon),
                  title: Text('History'.tr(),
                      style: const TextStyle(color: EasyrideColors.Drawertext)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BookingHistoryScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline,
                      color: EasyrideColors.Drawericon),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: EasyrideColors.Drawericon),
                  title: Text('Help'.tr(),
                      style: const TextStyle(color: EasyrideColors.Drawertext)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HelpScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // 🔽 Fixed Logout Button
          Card(
            color: EasyrideColors.Drawerheaderbackground,
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.power_settings_new,
                      color: EasyrideColors.Drawerheadertext),
                  const SizedBox(width: 5),
                  Text(
                    'Logout'.tr(),
                    style:
                        const TextStyle(color: EasyrideColors.Drawerheadertext),
                  ),
                ],
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: EasyrideColors.pureWhite,
                      title: const Center(
                        child:
                            Icon(Icons.logout, size: 64, color: Colors.black),
                      ),
                      content: const Text(
                        'Are you sure you want to log out?',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                      actions: <Widget>[
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.greenAccent),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('No',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    EasyrideColors.Drawerheaderbackground),
                            onPressed: () {
                              logout(context);
                            },
                            child: const Text('Yes',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          const Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text(
                  'Aap Version : 1.0.19',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

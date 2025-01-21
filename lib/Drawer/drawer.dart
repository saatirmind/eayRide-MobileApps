import 'package:easy_localization/easy_localization.dart';
import 'package:easyride/AppColors.dart/EasyrideAppColors.dart';
import 'package:easyride/DrawerWidget/Logoutfunction.dart';
import 'package:easyride/DrawerWidget/promotions.dart';
import 'package:easyride/DrawerWidget/updateprofile.dart';
import 'package:easyride/DrawerWidget/walletpage.dart';
import 'package:easyride/Screen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Drawerscreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Drawer(
        child: Container(
          color: EasyrideColors.Drawerbackground,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 150,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: EasyrideColors.Drawerheaderbackground,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                                Mobile: Mobile,
                                Token: Token,
                                registered_date: registered_date)),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.account_circle,
                          color: EasyrideColors.Drawerheadertext,
                          size: 40,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          children: [
                            Text(
                              Firstname,
                              style: TextStyle(
                                color: EasyrideColors.Drawerheadertext,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              Mobile,
                              style: TextStyle(
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
                leading: Icon(
                  Icons.map_outlined,
                  color: EasyrideColors.Drawericon,
                ),
                title: Text('Main'.tr(),
                    style: TextStyle(
                      color: EasyrideColors.Drawertext,
                    )),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.wallet,
                  color: EasyrideColors.Drawericon,
                ),
                title: Text('Wallet'.tr(),
                    style: TextStyle(
                      color: EasyrideColors.Drawertext,
                    )),
                onTap: () async {
                  bool? isUpdated = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WalletPage()),
                  );
                  if (isUpdated == true) {
                    HomeScreen.homeScreenKey.currentState?.Wallethistoryapi();
                  }
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.local_offer_outlined,
                  color: EasyrideColors.Drawericon,
                ),
                title: Text('Promotions'.tr(),
                    style: TextStyle(
                      color: EasyrideColors.Drawertext,
                    )),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CouponListScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.redeem,
                  color: EasyrideColors.Drawericon,
                ),
                title: Text('Redeem'.tr(),
                    style: TextStyle(
                      color: EasyrideColors.Drawertext,
                    )),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(
                  Icons.history,
                  color: EasyrideColors.Drawericon,
                ),
                title: Text('History'.tr(),
                    style: TextStyle(
                      color: EasyrideColors.Drawertext,
                    )),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(
                  Icons.help_outline,
                  color: EasyrideColors.Drawericon,
                ),
                title: Text('Help'.tr(),
                    style: TextStyle(
                      color: EasyrideColors.Drawertext,
                    )),
                onTap: () {},
              ),
              Card(
                color: EasyrideColors.Drawerheaderbackground,
                elevation: 3,
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.power_settings_new,
                        color: EasyrideColors.Drawerheadertext,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Logout'.tr(),
                        style:
                            TextStyle(color: EasyrideColors.Drawerheadertext),
                      ),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor:
                              EasyrideColors.Drawerheaderbackground,
                          title: Center(
                            child: Icon(
                              Icons.logout,
                              size: 64,
                              color: Colors.red,
                            ),
                          ),
                          content: Text(
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
                                child: Text(
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
                                child: Text(
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
              SpacerWidget(),
              ListTile(
                title: Center(
                  child: Text(
                    'Follow Us'.tr(),
                    style: TextStyle(
                        color: EasyrideColors.Drawertext, fontSize: 18),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      FontAwesomeIcons.facebook,
                      color: EasyrideColors.Drawericon,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      FontAwesomeIcons.instagram,
                      color: EasyrideColors.Drawericon,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      FontAwesomeIcons.globe,
                      color: EasyrideColors.Drawericon,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class SpacerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 10);
  }
}

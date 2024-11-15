import 'package:easy_localization/easy_localization.dart';
import 'package:easyride/DrawerWidget/updateprofile.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Drawerscreen extends StatelessWidget {
  final String Mobile;
  const Drawerscreen({
    super.key,
    required this.Mobile,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.yellow,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 150,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.yellow,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfileScreen(Mobile: Mobile)),
                    );
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.black,
                        size: 30,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          Text(
                            'Update Profile',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            Mobile,
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.map_outlined, color: Colors.black),
              title: Text('Main'.tr(), style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.wallet, color: Colors.black),
              title: Text('Wallet'.tr(), style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.local_offer_outlined, color: Colors.black),
              title: Text('Promotions'.tr(),
                  style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.redeem, color: Colors.black),
              title: Text('Redeem'.tr(), style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.history, color: Colors.black),
              title:
                  Text('History'.tr(), style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.help_outline, color: Colors.black),
              title: Text('Help'.tr(), style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.black),
              title:
                  Text('Log Out'.tr(), style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
            SpacerWidget(),
            ListTile(
              title: Center(
                child: Text(
                  'Follow Us'.tr(),
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(FontAwesomeIcons.facebook, color: Colors.black),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(FontAwesomeIcons.instagram, color: Colors.black),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(FontAwesomeIcons.globe, color: Colors.black),
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
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

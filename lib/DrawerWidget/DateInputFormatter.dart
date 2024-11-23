import 'package:easyride/Screen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    if (text.length == 2 && oldValue.text.length < text.length) {
      text = '$text-';
    } else if (text.length == 5 && oldValue.text.length < text.length) {
      text = '$text-';
    }

    if (text.length > 10) {
      text = text.substring(0, 10);
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class DataScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String Mobile;
  final String Token;

  DataScreen({required this.data, required this.Mobile, required this.Token});

  Future<void> saveData(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final message = data['message'][0];
    final userInfo = data['data']['user_info'];

    saveData('firstname', userInfo['firstname'] ?? "");
    saveData('dateofbirth', userInfo['dateofbirth'] ?? "");
    saveData('fullname', userInfo['fullname'] ?? "");

    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    title: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Center(
                        child: Text("Profile Image",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    subtitle: userInfo['userImage'] != null
                        ? Image.network(userInfo['userImage'],
                            height: 100, width: 100)
                        : Text("No Image"),
                  ),
                  ListTile(
                      title: Text("Message",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        message,
                        style: TextStyle(color: Colors.green),
                      )),
                  Divider(),
                  ListTile(
                    title: Text("ID",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(userInfo['id'].toString()),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("First Name",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(userInfo['firstname'] ?? "N/A"),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Family Name",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(userInfo['family_name'] ?? "N/A"),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Email",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(userInfo['email'] ?? "N/A"),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Mobile Number",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${userInfo['mobile_code'] ?? ""}-${userInfo['mobile'] ?? "N/A"}'),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Date of Birth",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(userInfo['dateofbirth'] ?? "N/A"),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Status",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(userInfo['stringStatus']['value'] ?? "N/A"),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Last Login",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(userInfo['lastLogin'] ?? "N/A"),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Nationality",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(userInfo['nationality'].toString()),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Emergency Contact",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(userInfo['emergency_contact'].toString()),
                  ),
                  Divider(),
                  ListTile(
                    title: Text("Emergency Relation",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(userInfo['emergency_relation'].toString()),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 16, bottom: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: GestureDetector(
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String? firstname = prefs.getString('firstname');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(
                        Mobile: Mobile,
                        Token: Token,
                        Firstname: firstname ?? "N/A",
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.account_circle, size: 24, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      'Update Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

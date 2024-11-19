import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    if (text.length == 2 && oldValue.text.length < text.length) {
      text = '$text/';
    } else if (text.length == 5 && oldValue.text.length < text.length) {
      text = '$text/';
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

  DataScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    final message = data['message'][0];
    final userInfo = data['data']['user_info'];

    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
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
              title: Text("ID", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(userInfo['id'].toString()),
            ),
            Divider(),

            // First Name
            ListTile(
              title: Text("First Name",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(userInfo['firstname'] ?? "N/A"),
            ),
            Divider(),

            ListTile(
              title: Text("Last Name",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(userInfo['family_name'] ?? "N/A"),
            ),
            Divider(),

            ListTile(
              title: Text("Username",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(userInfo['username'] ?? "N/A"),
            ),
            Divider(),

            ListTile(
              title:
                  Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
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
              subtitle: Text(userInfo['dob'] ?? "N/A"),
            ),
            Divider(),

            // Status
            ListTile(
              title:
                  Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(userInfo['stringStatus']['value'] ?? "N/A"),
            ),
            Divider(),

            // Last Login
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
            Divider(),

            // Profile Image
          ],
        ),
      ),
    );
  }
}

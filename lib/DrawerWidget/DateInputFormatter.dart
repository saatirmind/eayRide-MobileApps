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

class Datascreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const Datascreen({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mobile: ${data['mobile']}'),
            Text('Date of Birth: ${data['dob']}'),
            Text('Given Name: ${data['givenName']}'),
            Text('Family Name: ${data['familyName']}'),
            Text('Nationality: ${data['nationality']}'),
            Text(
                'Promotional Emails: ${data['promotionalEmails'] ? "No" : "Yes"}'),
          ],
        ),
      ),
    );
  }
}

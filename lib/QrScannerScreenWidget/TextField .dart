import 'package:flutter/material.dart';

class MyCardTextField extends StatefulWidget {
  final String qrText;

  MyCardTextField({required this.qrText});

  @override
  State<MyCardTextField> createState() => _MyCardTextFieldState();
}

class _MyCardTextFieldState extends State<MyCardTextField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 125,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: TextEditingController(text: widget.qrText),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
              textAlign: TextAlign.start,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: 'Enter Code Here',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: Icon(Icons.text_fields),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              readOnly: false,
              scrollPadding: EdgeInsets.all(0),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field cannot be empty';
                }
                return null;
              },
            ),
          ),
        ),
      ),
    );
  }
}

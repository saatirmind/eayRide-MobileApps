import 'package:easyride/QrScannerScreenWidget/TextField%20.dart';
import 'package:flutter/material.dart';

class BuildBottomContainer extends StatelessWidget {
  final String qrText;

  BuildBottomContainer({required this.qrText});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double containerPadding = screenWidth * 0.04;
    double imageHeight = screenHeight * 0.1;
    double buttonPadding = screenWidth * 0.1;
    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40), topRight: Radius.circular(40)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Please Scan QR Code',
            style: TextStyle(
              color: Colors.black,
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Image.asset(
            'assets/scooter.jpeg',
            height: imageHeight,
          ),
          MyCardTextField(qrText: qrText),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow,
              foregroundColor: Colors.black,
              padding:
                  EdgeInsets.symmetric(horizontal: buttonPadding, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'SUBMIT',
              style: TextStyle(
                  fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

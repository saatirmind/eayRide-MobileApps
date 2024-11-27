import 'package:easyride/Payment/cardscreen.dart';
import 'package:easyride/QrScannerScreenWidget/TextField%20.dart';
import 'package:flutter/material.dart';

class BuildBottomContainer extends StatefulWidget {
  final String qrText;

  BuildBottomContainer({required this.qrText});

  @override
  State<BuildBottomContainer> createState() => _BuildBottomContainerState();
}

class _BuildBottomContainerState extends State<BuildBottomContainer> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double containerPadding = screenWidth * 0.04;
    double imageHeight = screenHeight * 0.1;

    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40), topRight: Radius.circular(40)),
      ),
      child: Form(
        key: _formKey,
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
            MyCardTextField(
              qrText: widget.qrText,
            ),
            _isLoading
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 4.0,
                        ),
                      ),
                    ),
                  )
                : InkWell(
                    onTap: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        setState(() {
                          _isLoading = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('vehicle details fatched successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        await Future.delayed(Duration(seconds: 2));

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddCardScreen(),
                          ),
                        );

                        setState(() {
                          _isLoading = false;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter a valid QR Code!'),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'SUBMIT',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

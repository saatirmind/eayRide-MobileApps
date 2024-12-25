import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:easyride/AppColors.dart/EasyrideAppColors.dart';
import 'package:easyride/Payment/RidingStart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuildBottomContainer extends StatefulWidget {
  final String initialQRText;
  final String finalPrice;

  const BuildBottomContainer(
      {Key? key, required this.initialQRText, required this.finalPrice})
      : super(key: key);

  @override
  State<BuildBottomContainer> createState() => _BuildBottomContainerState();
}

class _BuildBottomContainerState extends State<BuildBottomContainer> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textEditingController = TextEditingController();

  bool isLoading = false;

  @override
  void didUpdateWidget(covariant BuildBottomContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialQRText != oldWidget.initialQRText) {
      setState(() {
        _textEditingController.text = widget.initialQRText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please Scan QR Code',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Image.asset(
              'assets/scooter.jpeg',
              height: 100,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter Code Here',
                      prefixIcon: const Icon(Icons.qr_code),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Input Vehicle no.';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: isLoading
                    ? Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: EasyrideColors.buttonColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                            child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 4.0,
                        )))
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _Vehiclefatched,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: EasyrideColors.buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Text(
                              'SUBMIT',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: EasyrideColors.buttontextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ))
          ],
        ),
      ),
    );
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  late String Vehicle_no;
  late String car_number;

  Future<void> _Vehiclefatched() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      final token = await getToken();

      if (token == null) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Token is missing. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final String apiUrl = AppApi.startRide;

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'token': token,
          },
          body: jsonEncode({
            'vehicle_no': _textEditingController.text,
          }),
        );

        setState(() {
          isLoading = false;
        });

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == true) {
            Vehicle_no = data['data']['vehicle_info']['vehicle_no'].toString();
            car_number = data['data']['vehicle_info']['car_number'];
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Vehicle details fetched successfully'),
                backgroundColor: Colors.green,
              ),
            );

            await Future.delayed(Duration(seconds: 2));
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Ridingstart(
                      finalPrice: widget.finalPrice,
                      Vehicle_no: Vehicle_no,
                      car_number: car_number)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message'][0]),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          final errorData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorData['message'][0]),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (error) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

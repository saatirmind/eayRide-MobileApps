import 'dart:io';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:easyride/AppColors.dart/EasyrideAppColors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompleteRideScreen extends StatefulWidget {
  @override
  _CompleteRideScreenState createState() => _CompleteRideScreenState();
}

class _CompleteRideScreenState extends State<CompleteRideScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedPhoto;
  bool _isSubmitted = false;
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _animation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0.5, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _openCamera(BuildContext context) async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _selectedPhoto = photo;
        });
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to open camera: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
    } catch (e) {
      print("Error getting location: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Location fetching failed: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  double? latitude;
  double? longitude;
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getBookingToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('booking_token');
  }

  void _submitPhoto() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _animationController.stop();
      final token = await getToken();
      final bookingToken = await getBookingToken();

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token is missing. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (bookingToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking Token null!'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (_selectedPhoto == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No image selected!'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      const String apiUrl = AppApi.Finishride;

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'token': token,
      });

      request.fields['booking_token'] = bookingToken;
      request.fields['current_lat'] = latitude.toString();
      request.fields['current_long'] = longitude.toString();

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _selectedPhoto!.path,
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        await Future.delayed(Duration(seconds: 2));
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('booking_token');

        setState(() {
          setState(() {
            _isLoading = false;
          });
          _isSubmitted = true;
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Success'),
            content: Text('Photo has been submitted successfully!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );

        print('Location and image sent successfully');
      } else {
        print('Failed to send location: ${response.statusCode}');
        print(
            'Response: ${await response.stream.bytesToString()}'); // डिबगिंग के लिए।
      }
    } catch (e) {
      print('Error sending location or image: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to submit photo and location: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your ride has been completed!',
                style: TextStyle(fontSize: 24, color: Colors.green),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              if (_selectedPhoto == null)
                GestureDetector(
                  onTap: () {
                    _animationController.stop();
                    _openCamera(context);
                    if (_selectedPhoto == null) {
                      _animationController.repeat(reverse: true);
                    }
                  },
                  child: Column(
                    children: [
                      Text(
                        'Tap here',
                        style: TextStyle(color: Colors.red),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SlideTransition(
                            position: _animation,
                            child: Icon(
                              Icons.arrow_forward,
                              size: 32,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Colors.blue,
                          ),
                          SlideTransition(
                            position: _animation,
                            child: Icon(
                              Icons.arrow_back,
                              size: 32,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'You must upload the station picture to complete the ride.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Image.file(
                        File(_selectedPhoto!.path),
                        height: MediaQuery.of(context).size.height * 0.350,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed:
                          _isLoading || _isSubmitted ? null : _submitPhoto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: EasyrideColors.buttonColor,
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 50,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.green),
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              _isSubmitted ? 'Submitted' : 'Submit',
                              style: TextStyle(
                                fontSize: 18,
                                color: _isSubmitted ? Colors.red : Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              SizedBox(height: 20),
              if (_isSubmitted)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: ElevatedButton(
                    onPressed: () async {
                      SystemNavigator.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: EasyrideColors.buttonColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Finish',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

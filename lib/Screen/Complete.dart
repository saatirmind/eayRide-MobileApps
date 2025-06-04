// ignore_for_file: library_private_types_in_public_api, file_names, use_build_context_synchronously, deprecated_member_use, avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:easymotorbike/AppColors.dart/VehicleLocationProvider.dart';
import 'package:easymotorbike/AppColors.dart/currentlocationprovide.dart';
import 'package:easymotorbike/AppColors.dart/drop_station_provider.dart';
import 'package:easymotorbike/AppColors.dart/walletapi.dart';
import 'package:easymotorbike/Payment/InsufficientAmount.dart';
import 'package:easymotorbike/Screen/asplashscreen.dart';
import 'package:easymotorbike/appfinish/animation.dart';
import 'package:http/http.dart' as http;
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompleteRideScreen extends StatefulWidget {
  const CompleteRideScreen({super.key});

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationTrackingProvider>(context, listen: false)
          .fetchAndTrackVehicleLocation();
    });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0.5, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
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
          title: const Text('Error'),
          content: Text('Failed to open camera: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _submitPhoto() async {
    setState(() {
      _isLoading = true;
      _animationController.stop();
    });

    try {
      final token = await AppApi.getToken();
      final bookingToken = await AppApi.getBookingToken();

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
      var request =
          http.MultipartRequest('POST', Uri.parse(AppApi.new_ride_finish));
      request.headers.addAll({'token': token});

      final vehicleProvider =
          Provider.of<VehicleLocationProvider>(context, listen: false);
      await vehicleProvider.fetchVehicleLocation();
      final dropprovider =
          Provider.of<DropStationProvider>(context, listen: false);

      print("🚀 Sending Data:");
      print("📍 Booking Token: $bookingToken");
      print("📍 Latitude: ${vehicleProvider.latitude}");
      print("📍 Longitude: ${vehicleProvider.longitude}");
      print("📍 Drop ID: ${dropprovider.selectedStationId}");
      print("🖼️ Image Path: ${_selectedPhoto!.path}");

      request.fields['booking_token'] = bookingToken;
      request.fields['current_lat'] = vehicleProvider.latitude.toString();
      request.fields['current_long'] = vehicleProvider.longitude.toString();
      request.fields['drop_id'] = dropprovider.selectedStationId.toString();
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _selectedPhoto!.path,
      ));

      var response = await request.send();

      if (response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('booking_token');

        setState(() {
          _isLoading = false;
          _isSubmitted = true;
        });

        Provider.of<LocationTrackingProvider>(context, listen: false)
            .stopTracking();

        showUploadSuccessDialog(context);

        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const Asplashscreen(),
            ),
            (Route<dynamic> route) => false,
          );
        });

        print('✅ Location and image sent successfully');
      } else if (response.statusCode == 402) {
        final responseBody = await response.stream.bytesToString();
        final decodedResponse = json.decode(responseBody);
        final rawAmount = decodedResponse['data']['amount_label'].toString();
        final double amount =
            double.parse(rawAmount.replaceAll(RegExp(r'[^\d.]'), ''));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InsufficientAmount(amount: amount),
          ),
        );
        Provider.of<WalletProvider>(context, listen: false)
            .fetchWalletHistory(context);
      } else {
        String responseBody = await response.stream.bytesToString();
        print('❌ Failed to send location. Status Code: ${response.statusCode}');
        print('🔍 Response Body: $responseBody');
        _animationController.repeat(reverse: true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit photo: $responseBody'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error sending location or image: $e');
      print('🔍 Stack Trace: $stackTrace');
      _animationController.repeat(reverse: true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to submit photo and location: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFF9A9E),
              Color(0xFFFAD0C4),
              Color(0xFFFFB347),
            ],
            //
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isSubmitted
                  ? const Text(
                      'Your ride has been completed!',
                      style: TextStyle(fontSize: 24, color: Colors.green),
                      textAlign: TextAlign.center,
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'To complete the ride, you must upload a drop station photo.',
                        style: TextStyle(fontSize: 20, color: Colors.green),
                        textAlign: TextAlign.center,
                      ),
                    ),
              const SizedBox(height: 2),
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
                      const Text(
                        'Tap here',
                        style: TextStyle(color: Colors.blue),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SlideTransition(
                            position: _animation,
                            child: const Icon(
                              Icons.arrow_forward,
                              size: 32,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 13),
                          const Icon(
                            Icons.camera_alt,
                            size: 90,
                            color: Colors.black,
                          ),
                          SlideTransition(
                            position: _animation,
                            child: const Icon(
                              Icons.arrow_back,
                              size: 32,
                              color: Colors.green,
                            ),
                          ),
                        ],
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
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed:
                          _isLoading || _isSubmitted ? null : _submitPhoto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLoading
                            ? Colors.transparent
                            : EasyrideColors.buttonColor,
                        shadowColor: Colors.transparent,
                        elevation: _isLoading ? 0 : 4,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.1,
                                    child: Lottie.asset(
                                      'assets/lang/uploading.json',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const Text(
                                    'Confirming...',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 14),
                                  ),
                                ],
                              ),
                            )
                          : Text(
                              _isSubmitted ? 'Confirmed' : 'Confirm',
                              style: TextStyle(
                                fontSize: 18,
                                color: _isSubmitted ? Colors.red : Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              if (_selectedPhoto != null && !_isLoading && !_isSubmitted)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedPhoto = null;
                    });
                    _openCamera(context);
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Retake Photo',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

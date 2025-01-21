// ignore_for_file: unrelated_type_equality_checks
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easyride/AppColors.dart/EasyrideAppColors.dart';
import 'package:easyride/Placelist/placelist.dart';
import 'package:easyride/Screen/Complete.dart';
import 'package:easyride/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easyride/Screen/asplashscreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  String? imageUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadBannerImageFromPreferences();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();

    Future.delayed(Duration(seconds: 2), () {
      initializeApp();
    });
  }

  Future<void> initializeApp() async {
    setState(() {
      isLoading = true;
    });
    await LocationService.getAndSaveLocation();
    setState(() {
      isLoading = false;
    });
    await _checkBookingToken();
  }

  Future<void> loadBannerImageFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedImageUrl = prefs.getString('BannerImageUrl');

    setState(() {
      imageUrl = savedImageUrl;
    });

    print('Loaded imageUrl from SharedPreferences: $imageUrl');
  }

  Future<void> _checkBookingToken() async {
    final prefs = await SharedPreferences.getInstance();
    final bookingToken = prefs.getString('booking_token');
    final vehicleno = prefs.getString('VehicleNo');

    if (vehicleno != null && vehicleno.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PlaceList(),
        ),
      );
    } else if (bookingToken != null && bookingToken.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => CompleteRideScreen(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Asplashscreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animation.value,
                  child: Opacity(
                    opacity: _animation.value,
                    child: Image.network(
                      imageUrl ?? '',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/splash.png',
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            if (isLoading) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: LinearProgressIndicator(),
              ),
              SizedBox(height: 10),
              Text(
                "Please wait, loading...",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LocationService {
  static Future<void> getAndSaveLocation() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      while (connectivityResult == ConnectivityResult.none) {
        await showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => AlertDialog(
            title: Text("No Internet Connection"),
            content:
                Text("Please turn on your internet connection to proceed."),
            actions: [
              TextButton(
                onPressed: () async {
                  await Geolocator.openAppSettings();
                  connectivityResult = await Connectivity().checkConnectivity();
                  if (connectivityResult != ConnectivityResult.none) {
                    Navigator.pop(context);
                  }
                },
                child: Text("Turn On Internet"),
              ),
            ],
          ),
        );
        connectivityResult = await Connectivity().checkConnectivity();
      }
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      while (!serviceEnabled) {
        await showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text("Location Service is Off"),
                content:
                    Text("Please turn on your location service to proceed."),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await Geolocator.openLocationSettings();

                      serviceEnabled =
                          await Geolocator.isLocationServiceEnabled();

                      if (serviceEnabled) {
                        Navigator.pop(context);
                      } else {
                        print("Location service is still off.");
                      }
                    },
                    child: Card(
                        color: EasyrideColors.buttonColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Turn On",
                            style: TextStyle(
                                color: EasyrideColors.buttontextColor),
                          ),
                        )),
                  ),
                ],
              );
            },
          ),
        );
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          SystemNavigator.pop();
          print('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print(
            'Location permissions are permanently denied, we cannot request permissions.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String? state = placemark.administrativeArea;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('StartState', state ?? '');

        print('State: $state');
      } else {
        print('No placemarks found for the given coordinates.');
      }
    } catch (e) {
      print('Error occurred while fetching location: $e');
    }
  }
}

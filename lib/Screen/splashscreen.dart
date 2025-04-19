// ignore_for_file: unrelated_type_equality_checks, library_private_types_in_public_api, avoid_print, use_build_context_synchronously, deprecated_member_use
import 'dart:async';
import 'package:easymotorbike/AppColors.dart/VehicleLocationProvider.dart';
import 'package:easymotorbike/Placelist/drop_station_screen.dart';
import 'package:easymotorbike/Placelist/new_place.dart';
import 'package:easymotorbike/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easymotorbike/Screen/asplashscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBannerImage();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      _requestLocationPermission(context);
    });
  }

  Uint8List? imageBytes;
  Future<void> _loadBannerImage() async {
    Uint8List? image = await Bannersave.getSavedBannerImage();
    setState(() {
      imageBytes = image;
    });
  }

  Future<void> _checkBookingToken() async {
    final prefs = await SharedPreferences.getInstance();
    final bookingToken = prefs.getString('booking_token');
    final vehicleno = prefs.getString('VehicleNo');
    if (!mounted) return;
    if (vehicleno != null && vehicleno.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MapScreen(),
        ),
      );
    } else if (bookingToken != null && bookingToken.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const DropStationsScreen(),
        ),
      );
      if (mounted) {
        await Provider.of<LocationTrackingProvider>(context, listen: false)
            .fetchAndTrackVehicleLocation();
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const Asplashscreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _requestLocationPermission(context);
    }
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
                    child: imageBytes != null
                        ? Image.memory(
                            imageBytes!,
                            fit: BoxFit.contain,
                          )
                        : const CircularProgressIndicator(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestLocationPermission(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationDialog(context);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        SystemNavigator.pop();
        return;
      }
    } else if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied');
      SystemNavigator.pop();
      return;
    }
    _checkBookingToken();
  }

  void _showLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Location Service Disabled"),
          content: const Text("Please enable location services to continue."),
          actions: [
            TextButton(
              onPressed: () async {
                await Geolocator.openLocationSettings();
                Navigator.of(context).pop();
              },
              child: const Text("Enable"),
            ),
          ],
        );
      },
    );
  }
}

/*class LocationService {
  static Future<void> getAndSaveLocation() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      while (connectivityResult == ConnectivityResult.none) {
        await showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) => AlertDialog(
            title: const Text("No Internet Connection"),
            content: const Text(
                "Please turn on your internet connection to proceed."),
            actions: [
              TextButton(
                onPressed: () async {
                  await Geolocator.openAppSettings();
                  connectivityResult = await Connectivity().checkConnectivity();
                  if (connectivityResult != ConnectivityResult.none) {
                    Navigator.pop(context);
                  }
                },
                child: const Text("Turn On Internet"),
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
                title: const Text("Location Service is Off"),
                content: const Text(
                    "Please turn on your location service to proceed."),
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
                    child: const Card(
                        color: EasyrideColors.buttonColor,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
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
        print('State: $state  Gaurav Pathak');
      } else {
        print('No placemarks found for the given coordinates.');
      }
    } catch (e) {
      print('Error occurred while fetching location: $e');
    }
  }
}
*/
// ignore_for_file: avoid_print, use_build_context_synchronously
import 'dart:convert';
import 'dart:io';
//import 'package:easy_localization/easy_localization.dart';
import 'package:easymotorbike/NewScreen/homenew.dart';
//import 'package:easymotorbike/NewScreen/login.dart';
import 'package:easymotorbike/Screen/beforelogin.dart';
import 'package:easymotorbike/notification/notification_service.dart';
//import 'package:easymotorbike/settings/setting.dart';
import 'package:http/http.dart' as http;
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/Screen/homescreen.dart';
import 'package:flutter/material.dart';
//import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Asplashscreen extends StatefulWidget {
  const Asplashscreen({super.key});

  @override
  State<Asplashscreen> createState() => _AsplashscreenState();
}

class _AsplashscreenState extends State<Asplashscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EasyrideColors.vibrantGreen,
      // body: Stack(
      //   children: [
      //     InkWell(
      //       onTap: () {},
      //       child: CarouselSlider(
      //         items: imageUrls
      //             .map(
      //               (imageUrl) => Image.network(
      //                 imageUrl,
      //                 fit: BoxFit.fill,
      //                 height: MediaQuery.of(context).size.height,
      //                 width: MediaQuery.of(context).size.width,
      //                 loadingBuilder: (context, child, loadingProgress) {
      //                   if (loadingProgress == null) return child;
      //                   return Center(
      //                     child: CircularProgressIndicator(
      //                       value: loadingProgress.expectedTotalBytes != null
      //                           ? loadingProgress.cumulativeBytesLoaded /
      //                               (loadingProgress.expectedTotalBytes ?? 1)
      //                           : null,
      //                     ),
      //                   );
      //                 },
      //                 errorBuilder: (context, error, stackTrace) {
      //                   return const Center(
      //                     child: Icon(
      //                       Icons.error,
      //                       color: Colors.red,
      //                       size: 50,
      //                     ),
      //                   );
      //                 },
      //               ),
      //             )
      //             .toList(),
      //         options: CarouselOptions(
      //           autoPlay: true,
      //           aspectRatio: MediaQuery.of(context).size.width /
      //               MediaQuery.of(context).size.height,
      //           viewportFraction: 1.0,
      //           onPageChanged: (index, reason) {
      //             setState(() {
      //               currentIndex = index;
      //             });
      //           },
      //         ),
      //       ),
      //     ),
      //     Positioned(
      //       bottom: 12,
      //       left: 0,
      //       right: 0,
      //       child: Row(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: imageUrls.asMap().entries.map((entry) {
      //           return GestureDetector(
      //             onTap: () => carouselController.animateToPage(entry.key),
      //             child: Container(
      //               width: currentIndex == entry.key ? 17 : 7,
      //               height: 7,
      //               margin: const EdgeInsets.symmetric(horizontal: 3.0),
      //               decoration: BoxDecoration(
      //                 borderRadius: BorderRadius.circular(10),
      //                 color:
      //                     currentIndex == entry.key ? Colors.red : Colors.green,
      //               ),
      //             ),
      //           );
      //         }).toList(),
      //       ),
      //     ),
      //     Positioned(
      //       top: 45,
      //       right: 21,
      //       child: ElevatedButton(
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: EasyrideColors.buttonColor,
      //         ),
      //         onPressed: () => _checkUserLoggedIn(),
      //         child: Text(
      //           "START".tr(),
      //           style: const TextStyle(
      //             color: EasyrideColors.buttontextColor,
      //             fontWeight: FontWeight.bold,
      //           ),
      //         ),
      //       ),
      //     ),
      //     Positioned(
      //       top: 45,
      //       left: -16,
      //       child: ElevatedButton(
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: EasyrideColors.buttonColor,
      //         ),
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(
      //               builder: (context) => const SettingsScreen(),
      //             ),
      //           );
      //         },
      //         child: Text(
      //           "Choose Language".tr(),
      //           style: const TextStyle(
      //             color: EasyrideColors.buttontextColor,
      //             fontWeight: FontWeight.bold,
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Spacer(flex: 1),
          // Image
          Image.asset(
            'assets/scooter.jpeg',
            height: 300,
          ),

          Spacer(flex: 1),
          const Column(
            children: [
              Text(
                'Welcome to EasyMotorbike',
                style: TextStyle(
                  fontSize: 24,
                  color: EasyrideColors.pureWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                child: Text(
                  'Join now for the most fun, affordable and eco-friendly way to get around town.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: EasyrideColors.pureWhite,
                  ),
                ),
              ),
            ],
          ),

          // Button
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0, right: 24, left: 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: EasyrideColors.pureWhite,
                  foregroundColor: EasyrideColors.vibrantGreen,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: const BorderSide(
                    color: EasyrideColors.vibrantGreen,
                    width: 2,
                  ),
                ),
                onPressed: () {
                  _checkUserLoggedIn();
                },
                child: const Text(
                  'Start now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> imageUrls = [];
  final CarouselController carouselController = CarouselController();
  int currentIndex = 0;
  NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      notificationService.firebaseInit();
      notificationService.requestNotificationPermissions();
      notificationService.getDeviceToken().then((value) {
        print('device Token: $value');
      });
    } else {
      print("📵 iOS detected – skipping notification setup");
    }
    fetchBannerImages();
    _atomaticmove();
  }

  Future<void> fetchBannerImages() async {
    try {
      final response = await http.get(Uri.parse(AppApi.Bannerlist));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final banners = jsonData['data']['banners'] as List;
        if (!mounted) return;
        setState(() {
          imageUrls = banners.map<String>((banner) => banner['image']).toList();
        });
      } else {
        print("Failed to load banners. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching banners: $e");
    }
  }

  Future<void> _atomaticmove() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      _checkUserLoggedIn();
    }
    return;
  }

  Future<void> _checkUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? mobile = prefs.getString('mobile');
    String? registeredDate = prefs.getString('registered_date');

    if (token != null && mobile != null && registeredDate != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            Mobile: mobile,
            Token: token,
            registered_date: registeredDate,
          ),
        ),
      );
    } else if (token != null && mobile != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Homenew(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BeamLoginScreen()),
      );
    }
  }
}

extension on CarouselController {
  // animateToPage(int key) {}
}

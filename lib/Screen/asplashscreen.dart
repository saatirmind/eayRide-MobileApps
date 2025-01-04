import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:easyride/settings/setting.dart';
import 'package:http/http.dart' as http;
import 'package:easyride/AppColors.dart/EasyrideAppColors.dart';
import 'package:easyride/Screen/homescreen.dart';
import 'package:easyride/Screen/phonescreen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
      backgroundColor: EasyrideColors.background,
      body: Stack(
        children: [
          InkWell(
            onTap: () {},
            child: CarouselSlider(
              items: imageUrls
                  .map(
                    (imageUrl) => Image.network(
                      imageUrl,
                      fit: BoxFit.fill,
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 50,
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
              options: CarouselOptions(
                autoPlay: true,
                aspectRatio: MediaQuery.of(context).size.width /
                    MediaQuery.of(context).size.height,
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imageUrls.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => carouselController.animateToPage(entry.key),
                  child: Container(
                    width: currentIndex == entry.key ? 17 : 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 3.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color:
                          currentIndex == entry.key ? Colors.red : Colors.green,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Positioned(
            top: 45,
            right: 21,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: EasyrideColors.buttonColor,
              ),
              onPressed: () => _checkUserLoggedIn(),
              child: Text(
                "START".tr(),
                style: TextStyle(
                  color: EasyrideColors.buttontextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 45,
            left: -16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: EasyrideColors.buttonColor,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(),
                  ),
                );
              },
              child: Text(
                "Choose Language".tr(),
                style: TextStyle(
                  color: EasyrideColors.buttontextColor,
                  fontWeight: FontWeight.bold,
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

  @override
  void initState() {
    super.initState();
    fetchBannerImages();
  }

  Future<void> fetchBannerImages() async {
    try {
      final response = await http.get(Uri.parse(AppApi.Bannerlist));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final banners = jsonData['data']['banners'] as List;
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

  Future<void> _checkUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? mobile = prefs.getString('mobile');
    String? firstname = prefs.getString('firstname');
    String? registeredDate = prefs.getString('registered_date');

    if (token != null &&
        mobile != null &&
        firstname != null &&
        registeredDate != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            Mobile: mobile,
            Token: token,
            Firstname: firstname,
            registered_date: registeredDate,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PhoneNumberScreen()),
      );
    }
  }
}

extension on CarouselController {
  animateToPage(int key) {}
}

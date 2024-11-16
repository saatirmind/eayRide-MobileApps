import 'package:easyride/Screen/homescreen.dart';
import 'package:easyride/Screen/phonescreen.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Asplashscreen extends StatefulWidget {
  Asplashscreen({super.key});

  @override
  State<Asplashscreen> createState() => _AsplashscreenState();
}

class _AsplashscreenState extends State<Asplashscreen> {
  List imageList = [
    {"id": 1, "image_path": 'assets/Splashh.jpg'},
    {"id": 2, "image_path": 'assets/Splash1.jpg'},
    {"id": 3, "image_path": 'assets/Splash5.jpg'},
    {"id": 4, "image_path": 'assets/Splash3.webp'},
    {"id": 5, "image_path": 'assets/Splash4.jpg'},
  ];

  final carouselController = CarouselController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          InkWell(
            onTap: () {},
            child: CarouselSlider(
              items: imageList
                  .map(
                    (item) => Image.asset(
                      item['image_path'],
                      fit: BoxFit.fill,
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
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
              carouselController: carouselController,
            ),
          ),
          Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: imageList.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => carouselController.animateToPage(entry.key),
                    child: Container(
                      width: currentIndex == entry.key ? 17 : 7,
                      height: 7,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 3.0,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: currentIndex == entry.key
                              ? Colors.red
                              : Colors.green),
                    ),
                  );
                }).toList(),
              )),
          Positioned(
            top: 45,
            right: 21,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow,
              ),
              onPressed: () => _checkUserLoggedIn(),
              child: const Text(
                "START",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static CarouselController() {}

  Future<void> _checkUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? mobile = prefs.getString('mobile');

    if (token != null && mobile != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(Mobile: mobile, Token: token),
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

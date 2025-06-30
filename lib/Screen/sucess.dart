// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, use_build_context_synchronously
import 'package:easymotorbike/Placelist/new_place.dart';
import 'package:easymotorbike/Placelist/placelist.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  _SuccessScreenState createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _lottieController;
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(vsync: this);

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const PlaceList()),
        (Route<dynamic> route) => false,
      );
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.green,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _bounceAnimation,
                child: Lottie.asset(
                  'assets/lang/success.json',
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width * 0.5,
                  fit: BoxFit.cover,
                  repeat: false,
                  controller: _lottieController,
                  onLoaded: (composition) {
                    _lottieController
                      ..duration = composition.duration
                      ..forward().whenComplete(() {
                        Future.delayed(const Duration(milliseconds: 2), () {
                          _bounceController.repeat(reverse: true);
                        });
                      });
                  },
                ),
              ),
              const Text(
                "Your Booking Successful",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              /*const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapScreen(),
                  ),
                  (Route<dynamic> route) => false,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Start Ride',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}

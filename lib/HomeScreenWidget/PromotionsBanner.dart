// ignore_for_file: file_names
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:flutter/material.dart';

class PromotionsBanner extends StatefulWidget {
  const PromotionsBanner({super.key});

  @override
  State<PromotionsBanner> createState() => _PromotionsBannerState();
}

class _PromotionsBannerState extends State<PromotionsBanner> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        _buildPromotionsBanner(),
        _buildCarouselIndicator(),
      ],
    );
  }

  Widget _buildPromotionsBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.10,
          decoration: BoxDecoration(
            color: EasyrideColors.buttonColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: CarouselSlider(
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height * 0.10,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
              viewportFraction: 1.0,
            ),
            items: [
              _buildBannerItem(
                "Don't forget to check out our promotions page to save more on your rides!"
                    .tr(),
              ),
              _buildBannerItem("Flat 50% off on first ride!".tr()),
              _buildBannerItem(
                  "Please check the Appstore for the Latest updates!".tr()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 3; i++)
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentIndex == i ? 18 : 8,
            height: _currentIndex == i ? 9 : 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentIndex == i ? Colors.white : Colors.grey,
            ),
          ),
      ],
    );
  }

  Widget _buildBannerItem(String text) {
    return Container(
      color: Colors.transparent,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration,
                  color: Colors.black,
                )),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
            ),
          )),
        ],
      ),
    );
  }
}

/*
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:async';
import 'package:provider/provider.dart';

// ✅ STATE MANAGEMENT CLASS
class BannerProvider extends ChangeNotifier {
  int _currentIndex = 0;
  double _opacity = 1.0;
  late Timer _timer;

  final List<String> _banners = [
    "Don't forget to check out our promotions page to save more on your rides!"
        .tr(),
    "Flat 50% off on first ride!".tr(),
    "Please check the Appstore for the Latest updates!".tr(),
  ];

  BannerProvider() {
    _startBannerTimer();
  }

  int get currentIndex => _currentIndex;
  double get opacity => _opacity;
  List<String> get banners => _banners;

  void _startBannerTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _opacity = 0.0;
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 500), () {
        _currentIndex = (_currentIndex + 1) % _banners.length;
        _opacity = 1.0;
        notifyListeners();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

// ✅ MAIN WIDGET
class PromotionsBanner extends StatelessWidget {
  const PromotionsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BannerProvider(),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          _buildPromotionsBanner(),
          _buildCarouselIndicator(),
        ],
      ),
    );
  }

  Widget _buildPromotionsBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 310,
        height: 90,
        color: EasyrideColors.buttonColor,
        child: _buildBannerContent(),
      ),
    );
  }

  Widget _buildCarouselIndicator() {
    return Consumer<BannerProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(provider.banners.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: provider.currentIndex == i ? 12 : 8,
              height: provider.currentIndex == i ? 9 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: provider.currentIndex == i ? Colors.white : Colors.grey,
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildBannerContent() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.campaign,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Consumer<BannerProvider>(
            builder: (context, provider, child) {
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: provider.opacity,
                child: Text(
                  provider.banners[provider.currentIndex],
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
*/

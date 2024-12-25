import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easyride/AppColors.dart/EasyrideAppColors.dart';
import 'package:flutter/material.dart';

class PromotionsBanner extends StatefulWidget {
  const PromotionsBanner({Key? key}) : super(key: key);

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
      child: Container(
        width: 310,
        height: 90,
        child: CarouselSlider(
          options: CarouselOptions(
            height: 90,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 3),
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
    );
  }

  Widget _buildCarouselIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 3; i++)
          AnimatedContainer(
            duration: Duration(seconds: 1),
            margin: EdgeInsets.symmetric(horizontal: 4),
            width: _currentIndex == i ? 12 : 8,
            height: _currentIndex == i ? 9 : 8,
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
      color: EasyrideColors.buttonColor,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.campaign,
                  color: Colors.black,
                )),
          ),
          SizedBox(width: 10),
          Expanded(
              child: Text(
            text,
            style: TextStyle(
              color: EasyrideColors.Pramotionbannertext,
            ),
          )),
        ],
      ),
    );
  }
}

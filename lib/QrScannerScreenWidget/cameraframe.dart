import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:flutter/material.dart';

class Cameraframe extends StatelessWidget {
  const Cameraframe({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            height: 50,
            width: 5,
            decoration: const BoxDecoration(color: EasyrideColors.Scannerframe),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            height: 5,
            width: 50,
            decoration: const BoxDecoration(color: EasyrideColors.Scannerframe),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            height: 50,
            width: 5,
            decoration: const BoxDecoration(color: EasyrideColors.Scannerframe),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            height: 5,
            width: 50,
            decoration: const BoxDecoration(color: EasyrideColors.Scannerframe),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            height: 50,
            width: 5,
            decoration: const BoxDecoration(color: EasyrideColors.Scannerframe),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            height: 5,
            width: 50,
            decoration: const BoxDecoration(color: EasyrideColors.Scannerframe),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            height: 50,
            width: 5,
            decoration: const BoxDecoration(color: EasyrideColors.Scannerframe),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            height: 5,
            width: 50,
            decoration: const BoxDecoration(color: EasyrideColors.Scannerframe),
          ),
        ),
      ],
    );
  }
}

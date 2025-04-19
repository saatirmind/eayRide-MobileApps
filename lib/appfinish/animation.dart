import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void showUploadSuccessDialog(BuildContext context) {
  late final AnimationController controller;
  Timer(const Duration(seconds: 2), () {
    if (Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  });
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Lottie.asset(
          'assets/lang/uploded.json',
          fit: BoxFit.cover,
          repeat: false,
          onLoaded: (composition) {
            controller = AnimationController(
              vsync: Navigator.of(context),
              duration: composition.duration,
            );
            controller.forward().whenComplete(() {
              controller.dispose();
            });
          },
        ),
        content: const Text(
          'Photo has been uploaded successfully!',
          style: TextStyle(color: Colors.green),
        ),
      );
    },
  );
}

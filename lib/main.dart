import 'package:easy_localization/easy_localization.dart';
import 'package:easyride/AppColors.dart/EasyrideAppColors.dart';
import 'package:easyride/Screen/homescreen.dart';
import 'package:easyride/Screen/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HomeScreen.homeScreenKey.currentState?.initializeApp();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('hi')],
      path: 'assets/lang',
      fallbackLocale: Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyRide',
      theme: ThemeData(scaffoldBackgroundColor: EasyrideColors.background),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}

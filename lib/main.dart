import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:easyride/AppColors.dart/EasyrideAppColors.dart';
import 'package:easyride/Screen/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await EasyLocalization.ensureInitialized();
  await LocationService.fetchBannerImage();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('zh'),
        Locale('ms'),
        Locale('fr'),
      ],
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
      navigatorKey: navigatorKey,
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}

class LocationService {
  static String? imageUrl;

  static Future<void> fetchBannerImage() async {
    try {
      final response = await http.get(
        Uri.parse(AppApi.Bannerlist),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String? fetchedImageUrl =
            data['data']['app_details']['display_mobile_logo'];

        if (fetchedImageUrl != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('BannerImageUrl', fetchedImageUrl);

          imageUrl = fetchedImageUrl;
        }
      }
    } catch (error) {
      print('Error fetching banner image: $error');
    }
  }
}

// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:easymotorbike/AppColors.dart/VehicleLocationProvider.dart';
import 'package:easymotorbike/AppColors.dart/currentlocationprovide.dart';
import 'package:easymotorbike/AppColors.dart/drop_station_provider.dart';
import 'package:easymotorbike/AppColors.dart/stationprovider.dart';
import 'package:easymotorbike/AppColors.dart/tripprovide.dart';
import 'package:easymotorbike/AppColors.dart/userprovider.dart';
import 'package:easymotorbike/AppColors.dart/walletapi.dart';
import 'package:easymotorbike/Placelist/toggle.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/Screen/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await EasyLocalization.ensureInitialized();
  await Bannersave().fetchBannerImage();

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
      fallbackLocale: const Locale('en'),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TripProvider()),
          ChangeNotifierProvider(create: (_) => StationProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => CityLocationProvider()),
          ChangeNotifierProvider(create: (_) => WalletProvider()),
          ChangeNotifierProvider(create: (_) => DropStationProvider()),
          ChangeNotifierProvider(create: (_) => VehicleVisibilityProvider()),
          ChangeNotifierProvider(
              create: (context) => LocationTrackingProvider()),
          ChangeNotifierProvider(
              create: (context) => VehicleLocationProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Platform.isAndroid && message.notification != null) {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    flutterLocalNotificationsPlugin.show(
      1,
      message.notification!.title,
      message.notification!.body,
      notificationDetails,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyMotorbike',
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}

/*class Bannersave {
  Future<void> fetchBannerImage() async {
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
        }
      }
    } catch (error) {
      print('Error fetching banner image: $error');
    }
  }
}*/

class Bannersave {
  Future<void> fetchBannerImage() async {
    try {
      final response = await http.get(
        Uri.parse(AppApi.Bannerlist),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String? fetchedImageUrl =
            data['data']['app_details']['display_mobile_logo'];

        if (fetchedImageUrl != null) {
          final imageResponse = await http.get(Uri.parse(fetchedImageUrl));

          if (imageResponse.statusCode == 200) {
            String base64Image = base64Encode(imageResponse.bodyBytes);

            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('BannerImageBase64', base64Image);
          }
        }
      }
    } catch (error) {
      print('Error fetching banner image: $error');
    }
  }

  static Future<Uint8List?> getSavedBannerImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? base64Image = prefs.getString('BannerImageBase64');
    if (base64Image != null) {
      return base64Decode(base64Image);
    }
    return null;
  }
}

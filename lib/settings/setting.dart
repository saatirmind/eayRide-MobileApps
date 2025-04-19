// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'package:easy_localization/easy_localization.dart';
import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/settings/customlanguagetile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'en';
    });
  }

  _changeLanguage(String langCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);
    context.setLocale(Locale(langCode));
    setState(() {
      _selectedLanguage = langCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'.tr()),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: EasyrideColors.buttonColor,
        child: Column(
          children: [
            Card(
              color: EasyrideColors.buttontextColor,
              elevation: 5,
              child: CustomLanguageTile(
                selectedLanguage: _selectedLanguage,
                onLanguageChanged: (value) {
                  _changeLanguage(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:easyride/AppColors.dart/EasyrideAppColors.dart';
import 'package:flutter/material.dart';

class CustomLanguageTile extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String> onLanguageChanged;

  const CustomLanguageTile({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: EasyrideColors.buttonColor,
          title: Text(
            'Select Language'.tr(),
            style: TextStyle(color: EasyrideColors.buttontextColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  'English'.tr(),
                  style: TextStyle(color: EasyrideColors.buttontextColor),
                ),
                leading: Radio(
                  value: 'en',
                  groupValue: selectedLanguage,
                  onChanged: (value) {
                    onLanguageChanged(value.toString());
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ListTile(
                title: Text(
                  'Hindi'.tr(),
                  style: TextStyle(color: EasyrideColors.buttontextColor),
                ),
                leading: Radio(
                  value: 'hi',
                  groupValue: selectedLanguage,
                  onChanged: (value) {
                    onLanguageChanged(value.toString());
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ListTile(
                title: Text(
                  'Malay'.tr(),
                  style: TextStyle(color: EasyrideColors.buttontextColor),
                ),
                leading: Radio(
                  value: 'ms',
                  groupValue: selectedLanguage,
                  onChanged: (value) {
                    onLanguageChanged(value.toString());
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ListTile(
                title: Text(
                  'Chinese'.tr(),
                  style: TextStyle(color: EasyrideColors.buttontextColor),
                ),
                leading: Radio(
                  value: 'zh',
                  groupValue: selectedLanguage,
                  onChanged: (value) {
                    onLanguageChanged(value.toString());
                    Navigator.of(context).pop();
                  },
                ),
              ),
              ListTile(
                title: Text(
                  'French'.tr(),
                  style: TextStyle(color: EasyrideColors.buttontextColor),
                ),
                leading: Radio(
                  value: 'fr',
                  groupValue: selectedLanguage,
                  onChanged: (value) {
                    onLanguageChanged(value.toString());
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.translate_sharp,
        color: Colors.blue,
      ),
      title: Text('Language'.tr()),
      subtitle: Text(_getLanguageName(selectedLanguage)),
      onTap: () => _showLanguageDialog(context),
      trailing: const Icon(Icons.arrow_forward_ios),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English'.tr();
      case 'hi':
        return 'Hindi'.tr();
      case 'zh':
        return 'Chinese'.tr();
      case 'ms':
        return 'Malay'.tr();
      case 'fr':
        return 'French'.tr();
      default:
        return 'Unknown'.tr();
    }
  }
}

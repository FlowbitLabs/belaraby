import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Switches the app locale between Arabic and English.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SegmentedButton<String>(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: yellow120,
          selectedForegroundColor: Colors.white,
        ),
        segments: [
          ButtonSegment(
            value: 'ar',
            label: Text('settings_language_ar'.tr()),
          ),
          ButtonSegment(
            value: 'en',
            label: Text('settings_language_en'.tr()),
          ),
        ],
        selected: {context.locale.languageCode},
        onSelectionChanged: (selection) {
          final code = selection.first;
          context.setLocale(Locale(code));
        },
      ),
    );
  }
}

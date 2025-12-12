import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class KeywordsTabView extends StatelessWidget {
  const KeywordsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'lesson_tab_keywords'.tr(),
        style: BTextStyles.of(
          context,
        ).displayLarge.copyWith(color: grey190),
      ),
    );
  }
}

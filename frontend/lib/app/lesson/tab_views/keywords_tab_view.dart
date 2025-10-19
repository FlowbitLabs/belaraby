import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:belaraby/l10n/l10n.dart';
import 'package:flutter/material.dart';

class KeywordsTabView extends StatelessWidget {
  const KeywordsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: L10n.of(context).lesson_tab_keywords,
        style: BTextStyles.of(
          context,
        ).displayLarge.copyWith(color: grey190),
      ),
    );
  }
}

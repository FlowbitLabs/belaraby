import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:belaraby/l10n/l10n.dart';
import 'package:flutter/material.dart';

class QuizTabView extends StatelessWidget {
  const QuizTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: L10n.of(context).lesson_tab_quiz,
        style: BTextStyles.of(
          context,
        ).displayLarge.copyWith(color: grey190),
      ),
    );
  }
}

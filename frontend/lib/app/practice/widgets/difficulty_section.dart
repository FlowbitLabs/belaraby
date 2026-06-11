import 'package:belaraby/app/practice/widgets/practice_bucket_style.dart';
import 'package:belaraby/app/practice/widgets/practice_word_card.dart';
import 'package:belaraby/app/util/convert_arabic_digits.dart';
import 'package:belaraby/data/models/practice_word_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// One difficulty bucket on the exercise screen: header row plus its words.
class DifficultySection extends StatelessWidget {
  const DifficultySection({
    required this.difficulty,
    required this.words,
    super.key,
  });

  final PracticeDifficulty difficulty;
  final List<PracticeWord> words;

  @override
  Widget build(BuildContext context) {
    final style = practiceBucketStyles[difficulty]!;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(style.icon, color: style.color, size: 20),
              const SizedBox(width: 6),
              Text(
                style.labelKey.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: style.color,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: style.tint,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  convertToArabicDigits(number: words.length),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: style.color,
                    height: 1,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final word in words) PracticeWordCard(word: word),
        ],
      ),
    );
  }
}

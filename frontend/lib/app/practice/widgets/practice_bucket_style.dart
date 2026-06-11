import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/data/models/practice_word_model.dart';
import 'package:flutter/material.dart';

/// Visual identity of one difficulty bucket on the exercise screen.
class PracticeBucketStyle {
  const PracticeBucketStyle({
    required this.labelKey,
    required this.color,
    required this.tint,
    required this.icon,
  });

  final String labelKey;
  final Color color;
  final Color tint;
  final IconData icon;
}

/// Bucket styles keyed by difficulty (shared with the training page).
const Map<PracticeDifficulty, PracticeBucketStyle> practiceBucketStyles = {
  PracticeDifficulty.newWord: PracticeBucketStyle(
    labelKey: 'practice_difficulty_new',
    color: blue140,
    tint: blue10,
    icon: Icons.fiber_new_outlined,
  ),
  PracticeDifficulty.easy: PracticeBucketStyle(
    labelKey: 'practice_difficulty_easy',
    color: green140,
    tint: green10,
    icon: Icons.sentiment_satisfied_alt,
  ),
  PracticeDifficulty.medium: PracticeBucketStyle(
    labelKey: 'practice_difficulty_medium',
    color: yellow140,
    tint: yellow15,
    icon: Icons.sentiment_neutral,
  ),
  PracticeDifficulty.hard: PracticeBucketStyle(
    labelKey: 'practice_difficulty_hard',
    color: red130,
    tint: red10,
    icon: Icons.sentiment_very_dissatisfied,
  ),
  PracticeDifficulty.done: PracticeBucketStyle(
    labelKey: 'practice_difficulty_done',
    color: grey160,
    tint: grey100,
    icon: Icons.verified,
  ),
};

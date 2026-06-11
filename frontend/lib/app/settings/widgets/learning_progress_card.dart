import 'package:belaraby/app/lesson/cubit/favorite_cubit.dart';
import 'package:belaraby/app/lesson/cubit/learned_cubit.dart';
import 'package:belaraby/app/practice/cubit/practice_cubit.dart';
import 'package:belaraby/app/util/convert_arabic_digits.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/data/models/practice_word_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Gamified learning metrics on the profile: learned/favorite counts, the
/// current achievement badge and progress toward the next milestone.
class LearningProgressCard extends StatelessWidget {
  const LearningProgressCard({super.key});

  /// Learned-lessons thresholds that unlock the next badge.
  static const List<int> _milestones = [1, 5, 10, 25, 50];

  static const Map<int, String> _badgeKeys = {
    0: 'profile_badge_new',
    1: 'profile_badge_learner',
    5: 'profile_badge_reader',
    10: 'profile_badge_bookworm',
    25: 'profile_badge_scholar',
    50: 'profile_badge_master',
  };

  String _badgeKey(int learnedCount) {
    var key = _badgeKeys[0]!;
    for (final entry in _badgeKeys.entries) {
      if (learnedCount >= entry.key) key = entry.value;
    }
    return key;
  }

  /// The next milestone to reach, or null when all are unlocked.
  int? _nextMilestone(int learnedCount) {
    for (final milestone in _milestones) {
      if (learnedCount < milestone) return milestone;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final learnedCount = context.select(
      (LearnedCubit cubit) => cubit.state.learnedIds.length,
    );
    final favoriteCount = context.select(
      (FavoriteCubit cubit) => cubit.state.favoriteIds.length,
    );
    final masteredWords = context.select(
      (PracticeCubit cubit) =>
          cubit.state.byDifficulty(PracticeDifficulty.done).length,
    );
    final next = _nextMilestone(learnedCount);
    final progress = next == null ? 1.0 : learnedCount / next;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        margin: EdgeInsets.zero,
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events, color: yellow120, size: 26),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _badgeKey(learnedCount).tr(),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: grey190,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      icon: Icons.school,
                      color: green115,
                      value: learnedCount,
                      labelKey: 'profile_stat_learned',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatChip(
                      icon: Icons.favorite,
                      color: red110,
                      value: favoriteCount,
                      labelKey: 'profile_stat_favorites',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatChip(
                      icon: Icons.style,
                      color: navy110,
                      value: masteredWords,
                      labelKey: 'profile_stat_keywords',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: progress.clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 10,
                    backgroundColor: grey110,
                    valueColor: const AlwaysStoppedAnimation<Color>(yellow100),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                next == null
                    ? 'profile_all_milestones'.tr()
                    : 'profile_next_milestone'.tr(
                        args: [
                          convertToArabicDigits(number: learnedCount),
                          convertToArabicDigits(number: next),
                        ],
                      ),
                style: const TextStyle(fontSize: 13, color: grey160),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.color,
    required this.value,
    required this.labelKey,
  });

  final IconData icon;
  final Color color;
  final int value;
  final String labelKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: appBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  convertToArabicDigits(number: value),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: grey190,
                    height: 1.1,
                  ),
                ),
                Text(
                  labelKey.tr(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: grey160,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

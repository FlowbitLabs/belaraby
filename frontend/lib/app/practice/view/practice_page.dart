import 'package:belaraby/app/lesson/utils/word_speaker.dart';
import 'package:belaraby/app/practice/cubit/practice_cubit.dart';
import 'package:belaraby/app/practice/view/flashcard_training_page.dart';
import 'package:belaraby/app/util/convert_arabic_digits.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:belaraby/data/models/practice_word_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

/// The exercise screen: the user's practice deck grouped by difficulty,
/// with a flashcard training entry point.
class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 24,
        centerTitle: false,
        title: Text(
          'practice_title'.tr(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: grey190,
          ),
        ),
      ),
      body: BlocConsumer<PracticeCubit, PracticeState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage.isNotEmpty,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage.tr())),
          );
        },
        builder: (context, state) {
          if (state.status == PracticeStatus.loading && state.words.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: yellow120),
            );
          }
          if (state.status == PracticeStatus.error && state.words.isEmpty) {
            return _PracticeMessage(
              icon: Icons.cloud_off,
              message: 'practice_load_error'.tr(),
              actionLabel: 'retry'.tr(),
              onAction: () => context.read<PracticeCubit>().loadPractice(),
            );
          }
          if (state.words.isEmpty) {
            return _PracticeMessage(
              icon: Icons.style_outlined,
              message: 'practice_empty'.tr(),
            );
          }
          return RefreshIndicator(
            color: yellow120,
            onRefresh: () => context.read<PracticeCubit>().loadPractice(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                _TrainingBanner(deckSize: state.trainingDeck.length),
                const SizedBox(height: 8),
                for (final difficulty in [
                  PracticeDifficulty.newWord,
                  PracticeDifficulty.hard,
                  PracticeDifficulty.medium,
                  PracticeDifficulty.easy,
                  PracticeDifficulty.done,
                ])
                  if (state.byDifficulty(difficulty).isNotEmpty)
                    _DifficultySection(
                      difficulty: difficulty,
                      words: state.byDifficulty(difficulty),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Gradient banner with the training call-to-action.
class _TrainingBanner extends StatelessWidget {
  const _TrainingBanner({required this.deckSize});

  final int deckSize;

  @override
  Widget build(BuildContext context) {
    final hasDeck = deckSize > 0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [navy140, navy110],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'practice_banner_title'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasDeck
                      ? 'practice_banner_subtitle'.tr(
                          args: [convertToArabicDigits(number: deckSize)],
                        )
                      : 'practice_banner_all_done'.tr(),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: hasDeck
                      ? () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const FlashcardTrainingPage(),
                          ),
                        )
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellow120,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white24,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 22),
                  label: Text(
                    'practice_start_training'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.style, color: Colors.white24, size: 64),
        ],
      ),
    );
  }
}

class _DifficultySection extends StatelessWidget {
  const _DifficultySection({required this.difficulty, required this.words});

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
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final word in words) _PracticeWordCard(word: word),
        ],
      ),
    );
  }
}

class _PracticeWordCard extends StatelessWidget {
  const _PracticeWordCard({required this.word});

  final PracticeWord word;

  @override
  Widget build(BuildContext context) {
    final style = practiceBucketStyles[word.difficulty]!;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: style.tint, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 8, 4, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.word,
                    style: BTextStyles.of(context).title1.copyWith(
                      color: grey190,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (word.meaning.isNotEmpty)
                    Text(
                      word.meaning,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: BTextStyles.of(context).body1.copyWith(
                        color: grey160,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up, color: yellow120, size: 22),
              tooltip: 'tooltip_play'.tr(),
              onPressed: () => WordSpeaker().speak(word.word),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: grey140,
                size: 22,
              ),
              tooltip: 'practice_remove_tooltip'.tr(),
              onPressed: () =>
                  context.read<PracticeCubit>().removeEntry(word),
            ),
          ],
        ),
      ),
    );
  }
}

class _PracticeMessage extends StatelessWidget {
  const _PracticeMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: grey140),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: grey160,
                height: 1.6,
              ),
            ),
            if (onAction != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionLabel ?? '',
                  style: const TextStyle(
                    color: yellow140,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

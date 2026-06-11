import 'package:belaraby/app/lesson/utils/word_speaker.dart';
import 'package:belaraby/app/practice/widgets/assess_button.dart';
import 'package:belaraby/app/practice/widgets/flip_card.dart';
import 'package:belaraby/app/practice/widgets/training_card_face.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:belaraby/data/models/practice_word_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// The active training card: progress bar, flip card and the
/// self-assessment row (shown once the meaning was revealed).
class TrainingCardView extends StatelessWidget {
  const TrainingCardView({
    required this.word,
    required this.progress,
    required this.revealed,
    required this.onFlip,
    required this.onAssess,
    super.key,
  });

  final PracticeWord word;
  final double progress;
  final bool revealed;
  final VoidCallback onFlip;
  final ValueChanged<PracticeDifficulty> onAssess;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Progress bar across the deck.
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(yellow100),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GestureDetector(
              onTap: onFlip,
              child: FlipCard(
                revealed: revealed,
                front: TrainingCardFace(
                  background: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        word.word,
                        textAlign: TextAlign.center,
                        style: BTextStyles.of(context).displaySmall.copyWith(
                          color: grey190,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      IconButton(
                        icon: const Icon(
                          Icons.volume_up,
                          color: yellow120,
                          size: 32,
                        ),
                        tooltip: 'tooltip_play'.tr(),
                        onPressed: () => WordSpeaker().speak(word.word),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'practice_tap_to_flip'.tr(),
                        style: const TextStyle(color: grey140, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                back: TrainingCardFace(
                  background: yellow15,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        word.word,
                        textAlign: TextAlign.center,
                        style: BTextStyles.of(context).title1.copyWith(
                          color: grey160,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(indent: 48, endIndent: 48),
                      const SizedBox(height: 12),
                      Text(
                        word.meaning.isNotEmpty
                            ? word.meaning
                            : 'practice_no_meaning'.tr(),
                        textAlign: TextAlign.center,
                        style: BTextStyles.of(context).body1.copyWith(
                          color: grey190,
                          fontSize: 22,
                          height: 1.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Self-assessment appears once the meaning was revealed.
          AnimatedOpacity(
            opacity: revealed ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !revealed,
              child: Row(
                children: [
                  AssessButton(
                    labelKey: 'practice_difficulty_hard',
                    color: red110,
                    onPressed: () => onAssess(PracticeDifficulty.hard),
                  ),
                  AssessButton(
                    labelKey: 'practice_difficulty_medium',
                    color: yellow120,
                    onPressed: () => onAssess(PracticeDifficulty.medium),
                  ),
                  AssessButton(
                    labelKey: 'practice_difficulty_easy',
                    color: green115,
                    onPressed: () => onAssess(PracticeDifficulty.easy),
                  ),
                  AssessButton(
                    labelKey: 'practice_mastered',
                    color: blue140,
                    onPressed: () => onAssess(PracticeDifficulty.done),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

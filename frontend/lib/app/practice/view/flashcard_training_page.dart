import 'dart:math' as math;

import 'package:belaraby/app/lesson/utils/word_speaker.dart';
import 'package:belaraby/app/practice/cubit/practice_cubit.dart';
import 'package:belaraby/app/util/convert_arabic_digits.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:belaraby/data/models/practice_word_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Flashcard training: one card at a time — tap to flip word → meaning,
/// then self-assess (easy / medium / hard / mastered) to advance. The
/// deck is captured once on entry (hardest words first) so cards don't
/// reshuffle mid-session as difficulties change.
class FlashcardTrainingPage extends StatefulWidget {
  const FlashcardTrainingPage({super.key});

  @override
  State<FlashcardTrainingPage> createState() => _FlashcardTrainingPageState();
}

class _FlashcardTrainingPageState extends State<FlashcardTrainingPage> {
  late final List<PracticeWord> _deck = context
      .read<PracticeCubit>()
      .state
      .trainingDeck;

  int _index = 0;
  bool _revealed = false;
  int _reviewed = 0;

  bool get _isFinished => _index >= _deck.length;

  void _assess(PracticeDifficulty difficulty) {
    final word = _deck[_index];
    context.read<PracticeCubit>().setDifficulty(word.id, difficulty);
    setState(() {
      _reviewed++;
      _index++;
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy140,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'practice_training_title'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (!_isFinished)
            Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 16),
                child: Text(
                  '${convertToArabicDigits(number: _index + 1)}'
                  '/'
                  '${convertToArabicDigits(number: _deck.length)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _isFinished ? _buildSummary() : _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    final word = _deck[_index];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Progress bar across the deck.
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _deck.isEmpty ? 0 : _index / _deck.length,
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(yellow100),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _revealed = !_revealed),
              child: _FlipCard(
                revealed: _revealed,
                front: _CardFace(
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
                back: _CardFace(
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
            opacity: _revealed ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_revealed,
              child: Row(
                children: [
                  _AssessButton(
                    labelKey: 'practice_difficulty_hard',
                    color: red110,
                    onPressed: () => _assess(PracticeDifficulty.hard),
                  ),
                  _AssessButton(
                    labelKey: 'practice_difficulty_medium',
                    color: yellow120,
                    onPressed: () => _assess(PracticeDifficulty.medium),
                  ),
                  _AssessButton(
                    labelKey: 'practice_difficulty_easy',
                    color: green115,
                    onPressed: () => _assess(PracticeDifficulty.easy),
                  ),
                  _AssessButton(
                    labelKey: 'practice_mastered',
                    color: blue140,
                    onPressed: () => _assess(PracticeDifficulty.done),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, color: yellow100, size: 72),
            const SizedBox(height: 16),
            Text(
              'practice_training_done_title'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'practice_training_done_subtitle'.tr(
                args: [convertToArabicDigits(number: _reviewed)],
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: yellow120,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: const StadiumBorder(),
              ),
              child: Text(
                'practice_back'.tr(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 3D Y-axis flip between [front] and [back].
class _FlipCard extends StatelessWidget {
  const _FlipCard({
    required this.revealed,
    required this.front,
    required this.back,
  });

  final bool revealed;
  final Widget front;
  final Widget back;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: revealed ? 1 : 0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      builder: (context, value, _) {
        final angle = value * math.pi;
        final showBack = angle > math.pi / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: showBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: back,
                )
              : front,
        );
      },
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({required this.background, required this.child});

  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AssessButton extends StatelessWidget {
  const _AssessButton({
    required this.labelKey,
    required this.color,
    required this.onPressed,
  });

  final String labelKey;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: FittedBox(
            child: Text(
              labelKey.tr(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

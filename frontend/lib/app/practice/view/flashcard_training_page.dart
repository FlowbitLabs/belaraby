import 'package:belaraby/app/practice/cubit/practice_cubit.dart';
import 'package:belaraby/app/practice/widgets/training_card_view.dart';
import 'package:belaraby/app/practice/widgets/training_summary_view.dart';
import 'package:belaraby/app/util/convert_arabic_digits.dart';
import 'package:belaraby/constant/colors.dart';
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
        child: _isFinished
            ? TrainingSummaryView(reviewed: _reviewed)
            : TrainingCardView(
                word: _deck[_index],
                progress: _deck.isEmpty ? 0 : _index / _deck.length,
                revealed: _revealed,
                onFlip: () => setState(() => _revealed = !_revealed),
                onAssess: _assess,
              ),
      ),
    );
  }
}

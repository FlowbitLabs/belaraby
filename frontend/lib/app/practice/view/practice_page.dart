import 'package:belaraby/app/practice/cubit/practice_cubit.dart';
import 'package:belaraby/app/practice/widgets/difficulty_section.dart';
import 'package:belaraby/app/practice/widgets/practice_message.dart';
import 'package:belaraby/app/practice/widgets/training_banner.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/data/models/practice_word_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            return PracticeMessage(
              icon: Icons.cloud_off,
              message: 'practice_load_error'.tr(),
              actionLabel: 'retry'.tr(),
              onAction: () => context.read<PracticeCubit>().loadPractice(),
            );
          }
          if (state.words.isEmpty) {
            return PracticeMessage(
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
                TrainingBanner(deckSize: state.trainingDeck.length),
                const SizedBox(height: 8),
                for (final difficulty in [
                  PracticeDifficulty.newWord,
                  PracticeDifficulty.hard,
                  PracticeDifficulty.medium,
                  PracticeDifficulty.easy,
                  PracticeDifficulty.done,
                ])
                  if (state.byDifficulty(difficulty).isNotEmpty)
                    DifficultySection(
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

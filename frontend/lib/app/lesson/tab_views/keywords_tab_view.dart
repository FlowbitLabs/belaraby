import 'package:belaraby/app/lesson/cubit/keywords_cubit.dart';
import 'package:belaraby/app/lesson/utils/word_speaker.dart';
import 'package:belaraby/app/lesson/widgets/lesson_content_status.dart';
import 'package:belaraby/app/practice/cubit/practice_cubit.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:belaraby/data/models/lesson_keyword_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Keyword cards of the lesson: word + meaning, playable via TTS, with an
/// add-to-practice toggle feeding the flashcard exercise screen.
class KeywordsTabView extends StatelessWidget {
  const KeywordsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KeywordsCubit, KeywordsState>(
      builder: (context, state) {
        if (state.status == KeywordsStatus.loading ||
            state.status == KeywordsStatus.initial) {
          return const LessonContentLoading();
        }
        if (state.status == KeywordsStatus.error) {
          return LessonContentError(
            onRetry: () => context.read<KeywordsCubit>().loadKeywords(),
          );
        }
        if (state.keywords.isEmpty) {
          return const LessonContentEmpty(
            messageKey: 'lesson_keywords_empty',
            icon: Icons.style_outlined,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.keywords.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) =>
              KeywordCard(keyword: state.keywords[index]),
        );
      },
    );
  }
}

/// One keyword: the word with its meaning, a TTS play action and the
/// add-to-practice toggle.
class KeywordCard extends StatelessWidget {
  const KeywordCard({required this.keyword, super.key});

  final LessonKeyword keyword;

  @override
  Widget build(BuildContext context) {
    final isInPractice = context.select(
      (PracticeCubit cubit) => cubit.state.keywordIds.contains(keyword.id),
    );
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    keyword.keyword,
                    style: BTextStyles.of(context).title1.copyWith(
                      color: grey190,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (keyword.meaning.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      keyword.meaning,
                      style: BTextStyles.of(context).body1.copyWith(
                        color: grey160,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up, color: yellow120),
              tooltip: 'tooltip_play'.tr(),
              onPressed: () => WordSpeaker().speak(keyword.keyword),
            ),
            IconButton(
              icon: Icon(
                isInPractice
                    ? Icons.bookmark_added
                    : Icons.bookmark_add_outlined,
                color: isInPractice ? green115 : grey140,
              ),
              tooltip: isInPractice
                  ? 'practice_remove_tooltip'.tr()
                  : 'practice_add_tooltip'.tr(),
              onPressed: () =>
                  context.read<PracticeCubit>().toggleWord(keyword.id),
            ),
          ],
        ),
      ),
    );
  }
}

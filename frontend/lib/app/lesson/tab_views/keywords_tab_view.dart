import 'package:belaraby/app/lesson/cubit/keywords_cubit.dart';
import 'package:belaraby/app/lesson/utils/word_speaker.dart';
import 'package:belaraby/app/lesson/widgets/lesson_content_status.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Keyword list of the lesson, each entry playable via TTS.
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
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final keyword = state.keywords[index];
            return Card(
              margin: EdgeInsets.zero,
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  keyword.keyword,
                  style: BTextStyles.of(context).title1.copyWith(
                    color: grey190,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.volume_up, color: orange120),
                  tooltip: 'tooltip_play'.tr(),
                  onPressed: () => WordSpeaker().speak(keyword.keyword),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

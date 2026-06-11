import 'package:belaraby/app/lesson/utils/word_speaker.dart';
import 'package:belaraby/app/practice/cubit/practice_cubit.dart';
import 'package:belaraby/app/practice/widgets/mini_flashcard_sheet.dart';
import 'package:belaraby/app/practice/widgets/practice_bucket_style.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:belaraby/data/models/practice_word_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// One word row in a difficulty bucket: tap for a mini flashcard,
/// with play and remove actions.
class PracticeWordCard extends StatelessWidget {
  const PracticeWordCard({required this.word, super.key});

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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showMiniFlashcard(context, word),
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
      ),
    );
  }
}

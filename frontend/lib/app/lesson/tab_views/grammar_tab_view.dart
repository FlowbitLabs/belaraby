import 'package:belaraby/app/lesson/cubit/grammar_cubit.dart';
import 'package:belaraby/app/lesson/widgets/lesson_content_status.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Grammar explanations of the lesson.
class GrammarTabView extends StatelessWidget {
  const GrammarTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GrammarCubit, GrammarState>(
      builder: (context, state) {
        if (state.status == GrammarStatus.loading ||
            state.status == GrammarStatus.initial) {
          return const LessonContentLoading();
        }
        if (state.status == GrammarStatus.error) {
          return LessonContentError(
            onRetry: () => context.read<GrammarCubit>().loadGrammar(),
          );
        }
        if (state.items.isEmpty) {
          return const LessonContentEmpty(
            messageKey: 'lesson_grammar_empty',
            icon: Icons.menu_book_outlined,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = state.items[index];
            return Card(
              margin: EdgeInsets.zero,
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsetsDirectional.only(end: 12, top: 2),
                      child: Icon(Icons.lightbulb_outline, color: yellow120),
                    ),
                    Expanded(
                      child: Text(
                        item.explanation,
                        style: BTextStyles.of(context).body1.copyWith(
                          color: grey180,
                          fontSize: 17,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

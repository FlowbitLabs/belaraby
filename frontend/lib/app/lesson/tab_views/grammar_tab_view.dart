import 'package:belaraby/app/lesson/cubit/grammar_cubit.dart';
import 'package:belaraby/app/lesson/widgets/lesson_content_status.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:belaraby/data/models/lesson_grammar_model.dart';
import 'package:easy_localization/easy_localization.dart';
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
          itemBuilder: (context, index) =>
              GrammarCard(item: state.items[index]),
        );
      },
    );
  }
}

/// One grammar note: title heading, explanation body and, when present, the
/// example sentence in a tinted container.
class GrammarCard extends StatelessWidget {
  const GrammarCard({required this.item, super.key});

  final LessonGrammarItem item;

  @override
  Widget build(BuildContext context) {
    final styles = BTextStyles.of(context);
    final example = item.example;
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.title.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsetsDirectional.only(end: 12, top: 2),
                    child: Icon(Icons.lightbulb_outline, color: orange120),
                  ),
                  Expanded(
                    child: Text(
                      item.title,
                      style: styles.body1.copyWith(
                        color: grey180,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            Text(
              item.explanation,
              style: styles.body1.copyWith(
                color: grey180,
                fontSize: 17,
                height: 1.6,
              ),
            ),
            if (example != null && example.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: navy10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'lesson_grammar_example'.tr(),
                      style: styles.body1.copyWith(
                        color: navy110,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      example,
                      style: styles.body1.copyWith(
                        color: navy140,
                        fontSize: 16,
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

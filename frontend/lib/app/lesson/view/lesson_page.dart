import 'package:belaraby/app/lesson/controller/lesson_player_controller.dart';
import 'package:belaraby/app/lesson/cubit/grammar_cubit.dart';
import 'package:belaraby/app/lesson/cubit/keywords_cubit.dart';
import 'package:belaraby/app/lesson/cubit/quiz_cubit.dart';
import 'package:belaraby/app/lesson/tab_views/grammar_tab_view.dart';
import 'package:belaraby/app/lesson/tab_views/keywords_tab_view.dart';
import 'package:belaraby/app/lesson/tab_views/lesson_tab_view.dart';
import 'package:belaraby/app/lesson/tab_views/quiz_tab_view.dart';
import 'package:belaraby/app/lesson/utils/translation_helper.dart';
import 'package:belaraby/app/lesson/widgets/learned_toggle_button.dart';
import 'package:belaraby/app/lesson/widgets/lesson_back_button.dart';
import 'package:belaraby/app/lesson/widgets/lesson_hero_image.dart';
import 'package:belaraby/app/lesson/widgets/lesson_tab_bar.dart';
import 'package:belaraby/app/lesson/widgets/quiz_progress_ring.dart';
import 'package:belaraby/app/lesson/widgets/word_translation_card.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:belaraby/data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'lesson_view.dart';

class LessonPage extends StatelessWidget {
  const LessonPage(this.lesson, {super.key});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => QuizCubit(lessonId: lesson.id)..loadExercises(),
        ),
        BlocProvider(
          create: (_) => KeywordsCubit(lessonId: lesson.id)..loadKeywords(),
        ),
        BlocProvider(
          create: (_) => GrammarCubit(lessonId: lesson.id)..loadGrammar(),
        ),
      ],
      child: LessonView(lesson),
    );
  }
}

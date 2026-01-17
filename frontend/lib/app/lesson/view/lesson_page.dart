import 'package:belaraby/app/lesson/controller/lesson_player_controller.dart';
import 'package:belaraby/app/lesson/cubit/lesson_cubit.dart';
import 'package:belaraby/app/lesson/tab_views/grammar_tab_view.dart';
import 'package:belaraby/app/lesson/tab_views/keywords_tab_view.dart';
import 'package:belaraby/app/lesson/tab_views/lesson_tab_view.dart';
import 'package:belaraby/app/lesson/tab_views/quiz_tab_view.dart';
import 'package:belaraby/app/lesson/utils/word_speaker.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/typography.dart';
import 'package:belaraby/data/data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'lesson_view.dart';

class LessonPage extends StatelessWidget {
  const LessonPage(this.lesson, {super.key});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LessonCubit(),
      child: LessonView(lesson),
    );
  }
}

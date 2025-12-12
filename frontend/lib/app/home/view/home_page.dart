import 'package:belaraby/app/home/cubit/cubit.dart';
import 'package:belaraby/app/home/widgets/filter_bar.dart';
import 'package:belaraby/app/home/widgets/free_lessons.dart';
import 'package:belaraby/app/home/widgets/lessons_section.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit()..getLessons(),
      child: const HomeView(),
    );
  }
}

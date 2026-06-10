import 'package:belaraby/app/home/cubit/home_cubit.dart';
import 'package:belaraby/app/home/cubit/home_state.dart';

import 'package:belaraby/app/home/widgets/free_lessons.dart';
import 'package:belaraby/app/home/widgets/home_header_delegate.dart';
import 'package:belaraby/app/home/widgets/lesson_filter_delegate.dart';
import 'package:belaraby/app/home/widgets/lessons_section.dart';
import 'package:belaraby/app/lesson/cubit/learned_cubit.dart';
import 'package:belaraby/app/subscription/cubit/subscription_cubit.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()
        ..updateLearnedIds(context.read<LearnedCubit>().state.learnedIds)
        ..getLessons(),
      child: MultiBlocListener(
        listeners: [
          // Story bodies are gated server-side, so a list fetched before a
          // purchase holds masked bodies — refetch when premium status
          // changes. Right after a purchase the webhook may not have landed
          // yet, so the post-purchase path retries with bounded backoff.
          BlocListener<SubscriptionCubit, SubscriptionState>(
            listenWhen: (previous, current) =>
                previous.isPremium != current.isPremium,
            listener: (context, state) {
              final cubit = context.read<HomeCubit>();
              if (state.isPremium) {
                cubit.getLessonsAfterPurchase();
              } else {
                cubit.getLessons();
              }
            },
          ),
          // Keep the "Hide Learned" filter in sync with the learned set.
          BlocListener<LearnedCubit, LearnedState>(
            listenWhen: (previous, current) =>
                previous.learnedIds != current.learnedIds,
            listener: (context, state) =>
                context.read<HomeCubit>().updateLearnedIds(state.learnedIds),
          ),
        ],
        child: const HomeView(),
      ),
    );
  }
}

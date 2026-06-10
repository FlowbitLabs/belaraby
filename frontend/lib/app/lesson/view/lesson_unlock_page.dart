import 'package:belaraby/app/lesson/cubit/lesson_unlock_cubit.dart';
import 'package:belaraby/app/lesson/view/lesson_page.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/data/models/lesson_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bridge page shown right after a purchase while the story body is still
/// masked server-side (the RevenueCat webhook has not landed yet).
///
/// Polls with bounded backoff and replaces itself with the [LessonPage]
/// once the content is unlocked; offers a manual retry on timeout.
class LessonUnlockPage extends StatelessWidget {
  const LessonUnlockPage(this.lesson, {super.key});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LessonUnlockCubit(lesson: lesson)..waitForUnlock(),
      child: const LessonUnlockView(),
    );
  }
}

class LessonUnlockView extends StatelessWidget {
  const LessonUnlockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: grey170),
          tooltip: 'paywall_close'.tr(),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<LessonUnlockCubit, LessonUnlockState>(
        listenWhen: (previous, current) =>
            current.status == LessonUnlockStatus.success &&
            previous.status != LessonUnlockStatus.success,
        listener: (context, state) {
          final lesson = state.lesson;
          if (lesson == null) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => LessonPage(lesson)),
          );
        },
        builder: (context, state) {
          if (state.status == LessonUnlockStatus.timeout ||
              state.status == LessonUnlockStatus.error) {
            return _UnlockRetry(
              messageKey: state.status == LessonUnlockStatus.timeout
                  ? 'unlock_timeout'
                  : 'unlock_error',
            );
          }
          return const _UnlockLoading();
        },
      ),
    );
  }
}

class _UnlockLoading extends StatelessWidget {
  const _UnlockLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: yellow120),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'unlock_preparing'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: grey160),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockRetry extends StatelessWidget {
  const _UnlockRetry({required this.messageKey});

  final String messageKey;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_top, size: 48, color: yellow120),
            const SizedBox(height: 16),
            Text(
              messageKey.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: grey160),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: yellow120,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
              ),
              onPressed: () =>
                  context.read<LessonUnlockCubit>().waitForUnlock(),
              child: Text('retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

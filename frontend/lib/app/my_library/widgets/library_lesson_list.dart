import 'package:belaraby/app/home/widgets/lesson_card.dart';
import 'package:belaraby/app/my_library/cubit/my_library_cubit.dart';
import 'package:belaraby/app/router.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Sliver rendering the lessons of the selected library section.
class LibraryLessonList extends StatelessWidget {
  const LibraryLessonList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyLibraryCubit, MyLibraryState>(
      builder: (context, state) {
        if (state.status == MyLibraryStatus.loading &&
            state.sectionLessons.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator(color: yellow120)),
          );
        }
        if (state.status == MyLibraryStatus.error &&
            state.sectionLessons.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _LibraryMessage(
              icon: Icons.cloud_off,
              message: 'library_load_error'.tr(),
            ),
          );
        }
        final lessons = state.sectionLessons;
        if (lessons.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _LibraryMessage(
              icon: state.section == MyLibrarySection.favorites
                  ? Icons.favorite_border
                  : Icons.library_add_check_outlined,
              message: state.section == MyLibrarySection.favorites
                  ? 'library_empty_favorites'.tr()
                  : 'library_empty_learned'.tr(),
            ),
          );
        }
        return SliverList.builder(
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            return InkWell(
              // Paid lessons go through the paywall for non-premium users.
              onTap: () async {
                await navigateToLessonGated(context, lesson);
                // Refresh so newly learned/unfavorited lessons show up.
                if (context.mounted) {
                  await context.read<MyLibraryCubit>().loadLibrary();
                }
              },
              child: LessonCard(lesson: lesson),
            );
          },
        );
      },
    );
  }
}

class _LibraryMessage extends StatelessWidget {
  const _LibraryMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: grey140),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: grey160),
          ),
        ],
      ),
    );
  }
}

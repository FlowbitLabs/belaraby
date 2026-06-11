import 'package:belaraby/app/my_library/cubit/my_library_cubit.dart';
import 'package:belaraby/app/router.dart';
import 'package:belaraby/app/util/get_level_color.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/data/data.dart';
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
            child: Center(child: CircularProgressIndicator(color: orange120)),
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
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          sliver: SliverList.builder(
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              return _CompactLessonCard(
                lesson: lesson,
                // Paid lessons go through the paywall for non-premium users.
                onTap: () async {
                  await navigateToLessonGated(context, lesson);
                  // Refresh so newly learned/unfavorited lessons show up.
                  if (context.mounted) {
                    await context.read<MyLibraryCubit>().loadLibrary();
                  }
                },
              );
            },
          ),
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


/// Compact library row: thumbnail, title, level badge and a chevron —
/// denser than the home feed's full-size cards.
class _CompactLessonCard extends StatelessWidget {
  const _CompactLessonCard({required this.lesson, required this.onTap});

  final Lesson lesson;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  lesson.heroImage,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 64,
                    height: 64,
                    color: grey110,
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: grey140),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: grey190,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: getLevelColor(lesson.level),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            lesson.level,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: grey180,
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (lesson.isPaid) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.lock_outline,
                              size: 14, color: grey140),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: grey140),
            ],
          ),
        ),
      ),
    );
  }
}

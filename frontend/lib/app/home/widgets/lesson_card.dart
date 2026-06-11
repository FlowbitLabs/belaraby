import 'package:belaraby/app/lesson/cubit/favorite_cubit.dart';
import 'package:belaraby/app/subscription/cubit/subscription_cubit.dart';
import 'package:belaraby/app/util/get_level_color.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/data/models/lesson_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({required this.lesson, super.key});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final isPremium = context.select(
      (SubscriptionCubit cubit) => cubit.state.isPremium,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cover image — 2:1 like the generated covers, so the whole
          // illustration is visible instead of a center crop.
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 2,
                child: Image.network(
                  lesson.heroImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, _, _) => const ColoredBox(color: grey140),
                ),
              ),

              // Lock badge — premium users see no locks.
              if (lesson.isPaid && !isPremium)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent.withAlpha(150),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.lock_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Content below the image
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  lesson.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                // Body
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 15),
                  child: Text(
                    lesson.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black.withAlpha((0.7 * 255).toInt()),
                      fontSize: 18,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Bottom row: level badge + favorite
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: getLevelColor(lesson.level),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lesson.level,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                      ),
                    ),
                    _FavoriteButton(lessonId: lesson.id),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select(
      (FavoriteCubit cubit) => cubit.state.isFavorite(lessonId),
    );
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? red110 : null,
      ),
      tooltip: 'favorite_button_tooltip'.tr(),
      onPressed: () => context.read<FavoriteCubit>().toggleFavorite(lessonId),
    );
  }
}

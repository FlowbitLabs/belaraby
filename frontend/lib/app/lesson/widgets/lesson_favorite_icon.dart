import 'package:belaraby/app/lesson/cubit/favorite_cubit.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Heart icon toggling the lesson in the user's favorites.
class LessonFavoriteIcon extends StatelessWidget {
  const LessonFavoriteIcon({required this.lessonId, super.key});

  final String lessonId;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select(
      (FavoriteCubit cubit) => cubit.state.isFavorite(lessonId),
    );
    return GestureDetector(
      onTap: () => context.read<FavoriteCubit>().toggleFavorite(lessonId),
      child: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? red110 : grey140,
        size: 30,
      ),
    );
  }
}

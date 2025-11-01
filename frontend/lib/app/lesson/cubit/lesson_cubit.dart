import 'package:belaraby/data/repositories/lesson_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LessonCubit extends Cubit<LessonState> {
  LessonCubit() : super(const LessonState());

  Future<void> toggleLearnedLesson({
    required int userId,
    required int lessonId,
  }) async {
    try {
      final success = await LessonRepository().toggleLearnedLesson(
        userId: userId,
        lessonId: lessonId,
      );

      if (success) {
        emit(state.copyWith(favorite: true));
      } else {
        emit(state.copyWith(favorite: false));
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      emit(state.copyWith(favorite: false));
    }
  }
}

class LessonState extends Equatable {
  const LessonState({this.favorite});

  final bool? favorite;

  @override
  List<Object?> get props => [favorite];

  LessonState copyWith({bool? favorite}) {
    return LessonState(
      favorite: favorite ?? this.favorite,
    );
  }
}

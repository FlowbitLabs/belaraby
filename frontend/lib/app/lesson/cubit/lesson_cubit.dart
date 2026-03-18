import 'package:belaraby/data/repositories/lesson_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LessonCubit extends Cubit<LessonState> {
  LessonCubit() : super(const LessonState());

  Future<void> toggleLearnedLesson({
    required String userId,
    required String lessonId,
  }) async {
    try {
      final success = await LessonRepository().toggleLearnedLesson(
        userId: userId,
        lessonId: lessonId,
      );

      emit(state.copyWith(learned: success));
    } on Exception catch (e) {
      debugPrint(e.toString());
      emit(state.copyWith(learned: false));
    }
  }
}

class LessonState extends Equatable {
  const LessonState({this.learned});

  final bool? learned;

  @override
  List<Object?> get props => [learned];

  LessonState copyWith({bool? learned}) {
    return LessonState(
      learned: learned ?? this.learned,
    );
  }
}

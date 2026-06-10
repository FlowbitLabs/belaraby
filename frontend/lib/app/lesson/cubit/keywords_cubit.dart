import 'package:belaraby/data/models/lesson_keyword_model.dart';
import 'package:belaraby/data/repositories/lesson_content_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum KeywordsStatus { initial, loading, success, error }

/// Cubit for the keywords tab of one lesson.
class KeywordsCubit extends Cubit<KeywordsState> {
  KeywordsCubit({required String lessonId, LessonContentRepository? repository})
    : _lessonId = lessonId,
      _repository = repository ?? LessonContentRepository(),
      super(const KeywordsState());

  final String _lessonId;
  final LessonContentRepository _repository;

  /// Loads the keywords of the lesson.
  Future<void> loadKeywords() async {
    emit(state.copyWith(status: KeywordsStatus.loading));
    try {
      final keywords = await _repository.fetchKeywords(_lessonId);
      emit(state.copyWith(status: KeywordsStatus.success, keywords: keywords));
    } on Exception catch (error) {
      debugPrint('KeywordsCubit.loadKeywords failed: $error');
      emit(state.copyWith(status: KeywordsStatus.error));
    }
  }
}

class KeywordsState extends Equatable {
  const KeywordsState({
    this.status = KeywordsStatus.initial,
    this.keywords = const [],
  });

  final KeywordsStatus status;
  final List<LessonKeyword> keywords;

  @override
  List<Object?> get props => [status, keywords];

  KeywordsState copyWith({
    KeywordsStatus? status,
    List<LessonKeyword>? keywords,
  }) {
    return KeywordsState(
      status: status ?? this.status,
      keywords: keywords ?? this.keywords,
    );
  }
}

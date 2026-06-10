import 'package:belaraby/data/models/lesson_grammar_model.dart';
import 'package:belaraby/data/repositories/lesson_content_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum GrammarStatus { initial, loading, success, error }

/// Cubit for the grammar tab of one lesson.
class GrammarCubit extends Cubit<GrammarState> {
  GrammarCubit({required String lessonId, LessonContentRepository? repository})
    : _lessonId = lessonId,
      _repository = repository ?? LessonContentRepository(),
      super(const GrammarState());

  final String _lessonId;
  final LessonContentRepository _repository;

  /// Loads the grammar explanations of the lesson.
  Future<void> loadGrammar() async {
    emit(state.copyWith(status: GrammarStatus.loading));
    try {
      final items = await _repository.fetchGrammar(_lessonId);
      emit(state.copyWith(status: GrammarStatus.success, items: items));
    } on Exception catch (error) {
      debugPrint('GrammarCubit.loadGrammar failed: $error');
      emit(state.copyWith(status: GrammarStatus.error));
    }
  }
}

class GrammarState extends Equatable {
  const GrammarState({
    this.status = GrammarStatus.initial,
    this.items = const [],
  });

  final GrammarStatus status;
  final List<LessonGrammarItem> items;

  @override
  List<Object?> get props => [status, items];

  GrammarState copyWith({
    GrammarStatus? status,
    List<LessonGrammarItem>? items,
  }) {
    return GrammarState(
      status: status ?? this.status,
      items: items ?? this.items,
    );
  }
}

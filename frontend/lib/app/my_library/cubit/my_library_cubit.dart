import 'package:belaraby/data/data.dart';
import 'package:belaraby/data/supabase_client.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum MyLibraryStatus { initial, loading, success, error }

class MyLibraryCubit extends Cubit<MyLibraryState> {
  MyLibraryCubit({LessonRepository? repository})
      : _repository = repository ?? LessonRepository(),
        super(const MyLibraryState());

  final LessonRepository _repository;

  Future<void> loadLibrary() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    emit(state.copyWith(status: MyLibraryStatus.loading));
    try {
      final results = await Future.wait([
        _repository.getFavoriteLessons(userId: userId),
        _repository.getLearnedLessons(userId: userId),
      ]);
      emit(
        state.copyWith(
          status: MyLibraryStatus.success,
          favorites: results[0],
          learnedLessons: results[1],
        ),
      );
    } on Exception catch (e) {
      emit(state.copyWith(status: MyLibraryStatus.error, error: e.toString()));
    }
  }
}

class MyLibraryState extends Equatable {
  const MyLibraryState({
    this.status = MyLibraryStatus.initial,
    this.favorites = const [],
    this.learnedLessons = const [],
    this.error = '',
  });

  final MyLibraryStatus status;
  final List<Lesson> favorites;
  final List<Lesson> learnedLessons;
  final String error;

  @override
  List<Object> get props => [status, favorites, learnedLessons, error];

  MyLibraryState copyWith({
    MyLibraryStatus? status,
    List<Lesson>? favorites,
    List<Lesson>? learnedLessons,
    String? error,
  }) {
    return MyLibraryState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      learnedLessons: learnedLessons ?? this.learnedLessons,
      error: error ?? this.error,
    );
  }
}

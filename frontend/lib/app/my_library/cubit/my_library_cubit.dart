import 'package:belaraby/data/data.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum MyLibraryStatus { initial, loading, success, error }

/// The section of the library currently shown.
enum MyLibrarySection { favorites, learned }

/// Cubit for the My Library screen: the user's favorite and learned
/// lessons plus the selected section.
///
/// [loadLibrary] emits `loading` then `success` with both lists (or
/// `error` with a translation key). The view re-invokes it whenever a
/// favorite toggle has settled (see `FavoriteState.syncCount`).
class MyLibraryCubit extends Cubit<MyLibraryState> {
  MyLibraryCubit({LibraryRepository? repository})
    : _repository = repository ?? LibraryRepository(),
      super(const MyLibraryState());

  final LibraryRepository _repository;

  /// Switches the visible list between favorites and learned lessons.
  void selectSection(MyLibrarySection section) {
    emit(state.copyWith(section: section));
  }

  /// Loads both the favorite and the learned lessons.
  Future<void> loadLibrary() async {
    emit(state.copyWith(status: MyLibraryStatus.loading, error: ''));
    try {
      final results = await Future.wait([
        _repository.fetchFavorites(),
        _repository.fetchLearned(),
      ]);
      emit(
        state.copyWith(
          status: MyLibraryStatus.success,
          favorites: results[0],
          learnedLessons: results[1],
        ),
      );
    } on Exception catch (error) {
      debugPrint('MyLibraryCubit.loadLibrary failed: $error');
      emit(
        state.copyWith(
          status: MyLibraryStatus.error,
          error: 'library_load_error',
        ),
      );
    }
  }
}

class MyLibraryState extends Equatable {
  const MyLibraryState({
    this.status = MyLibraryStatus.initial,
    this.section = MyLibrarySection.favorites,
    this.favorites = const [],
    this.learnedLessons = const [],
    this.error = '',
  });

  final MyLibraryStatus status;
  final MyLibrarySection section;
  final List<Lesson> favorites;
  final List<Lesson> learnedLessons;

  /// Translation key for the error message, empty when there is none.
  final String error;

  /// The lessons of the currently selected [section].
  List<Lesson> get sectionLessons =>
      section == MyLibrarySection.favorites ? favorites : learnedLessons;

  @override
  List<Object> get props => [
    status,
    section,
    favorites,
    learnedLessons,
    error,
  ];

  MyLibraryState copyWith({
    MyLibraryStatus? status,
    MyLibrarySection? section,
    List<Lesson>? favorites,
    List<Lesson>? learnedLessons,
    String? error,
  }) {
    return MyLibraryState(
      status: status ?? this.status,
      section: section ?? this.section,
      favorites: favorites ?? this.favorites,
      learnedLessons: learnedLessons ?? this.learnedLessons,
      error: error ?? this.error,
    );
  }
}

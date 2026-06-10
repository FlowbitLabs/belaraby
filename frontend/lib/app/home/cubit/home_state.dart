import 'package:belaraby/app/home/cubit/home_cubit.dart';
import 'package:belaraby/constant/lesson_constants.dart';
import 'package:belaraby/data/data.dart';
import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.lessons = const [],
    this.filterBy = 'level_filter_all',
    this.hideLearned = false,
    this.learnedIds = const {},
    this.error = '',
  });

  final HomeStatus status;
  final List<Lesson> lessons;

  /// The selected level filter translation key (see
  /// `levelFilterKeys` in `constant/lesson_constants.dart`).
  final String filterBy;

  /// Whether lessons the user already learned are hidden from the list.
  final bool hideLearned;

  /// Ids of the learned lessons, mirrored from the global `LearnedCubit`.
  final Set<String> learnedIds;

  final String error;

  List<Lesson> get freeLessons =>
      lessons.where((lesson) => !lesson.isPaid).toList();

  List<Lesson> get paidLessonsBySelectedLevel {
    final allowedGrade = levelFilterGrades[filterBy];
    return lessons.where((lesson) {
      if (hideLearned && learnedIds.contains(lesson.id)) return false;
      if (allowedGrade == null) return true;
      return lesson.grade == allowedGrade;
    }).toList();
  }

  List<String> get levels =>
      lessons.map((lesson) => lesson.level).toSet().toList();

  @override
  List<Object> get props => [
    status,
    lessons,
    filterBy,
    hideLearned,
    learnedIds,
    error,
  ];

  HomeState copyWith({
    HomeStatus? status,
    String? error,
    String? filterBy,
    bool? hideLearned,
    Set<String>? learnedIds,
    List<Lesson>? lessons,
  }) {
    return HomeState(
      status: status ?? this.status,
      lessons: lessons ?? this.lessons,
      filterBy: filterBy ?? this.filterBy,
      hideLearned: hideLearned ?? this.hideLearned,
      learnedIds: learnedIds ?? this.learnedIds,
      error: error ?? this.error,
    );
  }
}

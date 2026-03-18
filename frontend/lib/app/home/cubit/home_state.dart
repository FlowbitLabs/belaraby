import 'package:belaraby/app/home/cubit/home_cubit.dart';
import 'package:belaraby/constant/lesson_constants.dart';
import 'package:belaraby/data/data.dart';
import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.lessons = const [],
    this.filterBy = 'الكل',
    this.error = '',
  });

  final HomeStatus status;
  final List<Lesson> lessons;
  final String filterBy;
  final String error;

  List<Lesson> get freeLessons =>
      lessons.where((lesson) => !lesson.isPaid).toList();

  List<Lesson> get paidLessonsBySelectedLevel {
    final allowedLevel = levelGradeFilters[filterBy];
    return lessons.where((lesson) {
      if (allowedLevel == null) return true;
      return lesson.grade == allowedLevel;
    }).toList();
  }

  List<String> get levels =>
      lessons.map((lesson) => lesson.level).toSet().toList();

  @override
  List<Object> get props => [status, lessons, filterBy, error];

  HomeState copyWith({
    HomeStatus? status,
    String? error,
    String? filterBy,
    List<Lesson>? lessons,
  }) {
    return HomeState(
      status: status ?? this.status,
      lessons: lessons ?? this.lessons,
      filterBy: filterBy ?? this.filterBy,
      error: error ?? this.error,
    );
  }
}

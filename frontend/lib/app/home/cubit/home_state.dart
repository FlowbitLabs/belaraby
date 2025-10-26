import 'package:belaraby/app/home/cubit/home_cubit.dart';
import 'package:belaraby/data/data.dart';
import 'package:equatable/equatable.dart';

final List<String> levelsFilterList = [
  'الكل',
  'الأول ابتدائي',
  'الثاني ابتدائي',
  'الثالث ابتدائي',
  'الرابع ابتدائي',
];

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
    final levelFilters = {
      'الكل': null, // null means no filtering on grade
      'الأول ابتدائي': '1',
      'الثاني ابتدائي': '2',
      'الثالث ابتدائي': '3',
      'الرابع ابتدائي': '4',
    };

    final allowedLevel = levelFilters[filterBy];

    return lessons.where((lesson) {
      if (allowedLevel == null) return true; // 'الكل' case
      return lesson.grade == allowedLevel;
    }).toList();
  }

  List<String> get levels =>
      lessons.map((lesson) => lesson.level).toSet().toList();

  String get title => 'Home';

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

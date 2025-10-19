import 'package:belaraby/app/home/cubit/home_cubit.dart';
import 'package:belaraby/app/home/cubit/model/lesson.dart';
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
  final List<dynamic> lessons;
  final String filterBy;
  final String error;

  List<Lesson> get lessonsList {
    return lessons.map((lesson) {
      return Lesson.fromJson(lesson as Map<String, dynamic>);
    }).toList();
  }

  List<Lesson> get freeLessons {
    return lessonsList.where((lesson) => !lesson.isPaid).toList();
  }

  List<Lesson> get paidLessonsBySelectedLevel {
    final levelFilters = {
      'الكل': null, // null means no filtering on grade
      'الأول ابتدائي': '1',
      'الثاني ابتدائي': '2',
      'الثالث ابتدائي': '3',
      'الرابع ابتدائي': '4',
    };

    final allowedLevel = levelFilters[filterBy];

    return lessonsList.where((lesson) {
      if (allowedLevel == null) return true; // 'الكل' case
      return lesson.grade == allowedLevel;
    }).toList();
  }

  List<String> get levels {
    return lessonsList.map((lesson) => lesson.level).toSet().toList();
  }

  String get title => 'Home';

  @override
  List<Object> get props => [status, lessons, filterBy, error];

  HomeState copyWith({
    HomeStatus? status,
    String? error,
    String? filterBy,
    List<dynamic>? lessons,
  }) {
    return HomeState(
      status: status ?? this.status,
      lessons: lessons ?? this.lessons,
      filterBy: filterBy ?? this.filterBy,
      error: error ?? this.error,
    );
  }
}

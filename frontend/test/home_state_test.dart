import 'package:belaraby/app/home/cubit/home_cubit.dart';
import 'package:belaraby/app/home/cubit/home_state.dart';
import 'package:belaraby/data/models/lesson_model.dart';
import 'package:flutter_test/flutter_test.dart';

Lesson _lesson({
  required String id,
  String grade = '1',
  bool isPaid = true,
  String body = 'نص',
}) {
  return Lesson(
    id: id,
    isPaid: isPaid,
    title: 'قصة $id',
    body: body,
    level: 'A1',
    grade: grade,
    heroImage: 'https://example.com/$id.png',
  );
}

void main() {
  group('HomeState', () {
    test('has sensible defaults', () {
      const state = HomeState();
      expect(state.status, HomeStatus.initial);
      expect(state.filterBy, 'level_filter_all');
      expect(state.hideLearned, isFalse);
      expect(state.learnedIds, isEmpty);
      expect(state.lessons, isEmpty);
    });

    test('paidLessonsBySelectedLevel filters by grade key', () {
      final state = HomeState(
        lessons: [
          _lesson(id: 'a'),
          _lesson(id: 'b', grade: '2'),
        ],
        filterBy: 'level_filter_grade_2',
      );
      expect(
        state.paidLessonsBySelectedLevel.map((lesson) => lesson.id),
        ['b'],
      );
    });

    test('paidLessonsBySelectedLevel hides learned lessons when enabled', () {
      final lessons = [_lesson(id: 'a'), _lesson(id: 'b')];
      final visible = HomeState(lessons: lessons, learnedIds: const {'a'});
      expect(visible.paidLessonsBySelectedLevel.length, 2);

      final hidden = visible.copyWith(hideLearned: true);
      expect(
        hidden.paidLessonsBySelectedLevel.map((lesson) => lesson.id),
        ['b'],
      );
    });

    test('copyWith overrides only the given fields', () {
      const state = HomeState();
      final updated = state.copyWith(
        hideLearned: true,
        learnedIds: {'x'},
        filterBy: 'level_filter_grade_1',
      );
      expect(updated.hideLearned, isTrue);
      expect(updated.learnedIds, {'x'});
      expect(updated.filterBy, 'level_filter_grade_1');
      expect(updated.status, state.status);
      expect(updated.lessons, state.lessons);
    });
  });

  group('Lesson.isBodyMasked', () {
    test('is true only for paid lessons with an empty body', () {
      expect(_lesson(id: 'a', body: '').isBodyMasked, isTrue);
      expect(_lesson(id: 'a').isBodyMasked, isFalse);
      expect(_lesson(id: 'a', isPaid: false, body: '').isBodyMasked, isFalse);
    });
  });
}

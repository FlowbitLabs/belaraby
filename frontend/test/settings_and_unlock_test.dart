import 'package:belaraby/app/lesson/cubit/learned_cubit.dart';
import 'package:belaraby/app/lesson/cubit/lesson_unlock_cubit.dart';
import 'package:belaraby/app/settings/cubit/settings_cubit.dart';
import 'package:belaraby/data/models/lesson_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SettingsState', () {
    test('has sensible defaults', () {
      const state = SettingsState();
      expect(state.status, SettingsStatus.initial);
      expect(state.appVersion, isEmpty);
      expect(state.accountDeleted, isFalse);
      expect(state.errorMessage, isEmpty);
    });

    test('copyWith overrides only the given fields', () {
      const state = SettingsState();
      final updated = state.copyWith(
        status: SettingsStatus.success,
        accountDeleted: true,
      );
      expect(updated.status, SettingsStatus.success);
      expect(updated.accountDeleted, isTrue);
      expect(updated.appVersion, state.appVersion);
      expect(updated.errorMessage, state.errorMessage);
    });
  });

  group('LearnedState', () {
    test('isLearned reflects learnedIds', () {
      const state = LearnedState(learnedIds: {'a'});
      expect(state.isLearned('a'), isTrue);
      expect(state.isLearned('b'), isFalse);
    });

    test('copyWith replaces learnedIds', () {
      const state = LearnedState();
      final updated = state.copyWith(
        status: LearnedStatus.success,
        learnedIds: {'x'},
      );
      expect(updated.learnedIds, {'x'});
      expect(updated.status, LearnedStatus.success);
    });
  });

  group('LessonUnlockState', () {
    test('copyWith keeps the lesson when only the status changes', () {
      const lesson = Lesson(
        id: 'l1',
        isPaid: true,
        title: 'قصة',
        body: 'نص القصة',
        level: 'A1',
        grade: '1',
        heroImage: 'https://example.com/l1.png',
      );
      const state = LessonUnlockState(
        status: LessonUnlockStatus.success,
        lesson: lesson,
      );
      final updated = state.copyWith(status: LessonUnlockStatus.timeout);
      expect(updated.status, LessonUnlockStatus.timeout);
      expect(updated.lesson, lesson);
    });
  });
}

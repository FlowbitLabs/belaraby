import 'package:belaraby/app/lesson/cubit/favorite_cubit.dart';
import 'package:belaraby/app/lesson/cubit/learned_cubit.dart';
import 'package:belaraby/app/my_library/cubit/my_library_cubit.dart';
import 'package:belaraby/app/subscription/cubit/subscription_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubscriptionState', () {
    test('has sensible defaults', () {
      const state = SubscriptionState();
      expect(state.status, SubscriptionStatus.initial);
      expect(state.isPremium, isFalse);
      expect(state.isBillingAvailable, isTrue);
      expect(state.packages, isEmpty);
      expect(state.errorMessage, isEmpty);
      expect(state.infoMessage, isEmpty);
    });

    test('copyWith overrides only the given fields', () {
      const state = SubscriptionState();
      final updated = state.copyWith(
        status: SubscriptionStatus.success,
        isPremium: true,
      );
      expect(updated.status, SubscriptionStatus.success);
      expect(updated.isPremium, isTrue);
      expect(updated.isBillingAvailable, state.isBillingAvailable);
      expect(updated.errorMessage, state.errorMessage);
    });
  });

  group('FavoriteState', () {
    test('isFavorite reflects favoriteIds', () {
      const state = FavoriteState(favoriteIds: {'a', 'b'});
      expect(state.isFavorite('a'), isTrue);
      expect(state.isFavorite('c'), isFalse);
    });

    test('copyWith replaces favoriteIds', () {
      const state = FavoriteState();
      final updated = state.copyWith(
        status: FavoriteStatus.success,
        favoriteIds: {'x'},
      );
      expect(updated.favoriteIds, {'x'});
      expect(updated.status, FavoriteStatus.success);
    });
  });

  group('LearnedState', () {
    test('isLearned reflects learnedIds', () {
      const state = LearnedState(learnedIds: {'a'});
      expect(state.isLearned('a'), isTrue);
      expect(state.isLearned('b'), isFalse);
    });

    test('copyWith replaces learnedIds and keeps the rest', () {
      const state = LearnedState();
      final updated = state.copyWith(
        status: LearnedStatus.success,
        learnedIds: {'x'},
      );
      expect(updated.learnedIds, {'x'});
      expect(updated.status, LearnedStatus.success);
      expect(updated.syncCount, state.syncCount);
    });
  });

  group('MyLibraryState', () {
    test('sectionLessons follows the selected section', () {
      const state = MyLibraryState();
      expect(state.section, MyLibrarySection.favorites);
      expect(state.sectionLessons, state.favorites);

      final learned = state.copyWith(section: MyLibrarySection.learned);
      expect(learned.sectionLessons, learned.learnedLessons);
    });
  });
}

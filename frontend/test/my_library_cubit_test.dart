import 'package:belaraby/app/my_library/cubit/my_library_cubit.dart';
import 'package:belaraby/data/data.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers.dart';

void main() {
  late MockLibraryRepository repository;

  final favorite = buildLesson(id: 'fav');
  final learned = buildLesson(id: 'learned');

  setUp(() {
    repository = MockLibraryRepository();
  });

  MyLibraryCubit buildCubit() => MyLibraryCubit(repository: repository);

  group('loadLibrary', () {
    blocTest<MyLibraryCubit, MyLibraryState>(
      'emits both sections on success',
      setUp: () {
        when(
          () => repository.fetchFavorites(),
        ).thenAnswer((_) async => [favorite]);
        when(
          () => repository.fetchLearned(),
        ).thenAnswer((_) async => [learned]);
      },
      build: buildCubit,
      act: (cubit) => cubit.loadLibrary(),
      expect: () => [
        const MyLibraryState(status: MyLibraryStatus.loading),
        MyLibraryState(
          status: MyLibraryStatus.success,
          favorites: [favorite],
          learnedLessons: [learned],
        ),
      ],
    );

    blocTest<MyLibraryCubit, MyLibraryState>(
      'emits success with empty lists when the library is empty',
      setUp: () {
        when(
          () => repository.fetchFavorites(),
        ).thenAnswer((_) async => const []);
        when(() => repository.fetchLearned()).thenAnswer((_) async => const []);
      },
      build: buildCubit,
      act: (cubit) => cubit.loadLibrary(),
      expect: () => [
        const MyLibraryState(status: MyLibraryStatus.loading),
        const MyLibraryState(status: MyLibraryStatus.success),
      ],
    );

    blocTest<MyLibraryCubit, MyLibraryState>(
      'emits error with a translation key on failure',
      setUp: () {
        when(() => repository.fetchFavorites()).thenThrow(Exception('boom'));
        when(() => repository.fetchLearned()).thenAnswer((_) async => const []);
      },
      build: buildCubit,
      act: (cubit) => cubit.loadLibrary(),
      expect: () => [
        const MyLibraryState(status: MyLibraryStatus.loading),
        const MyLibraryState(
          status: MyLibraryStatus.error,
          error: 'library_load_error',
        ),
      ],
    );

    test('a reload picks up favorites changed elsewhere', () async {
      // The view triggers this reload whenever FavoriteState.syncCount
      // changes (i.e. a favorite toggle settled on the backend).
      final responses = <List<Lesson>>[
        [favorite],
        [favorite, buildLesson(id: 'fav-2')],
      ];
      when(
        () => repository.fetchFavorites(),
      ).thenAnswer((_) async => responses.removeAt(0));
      when(() => repository.fetchLearned()).thenAnswer((_) async => const []);

      final cubit = buildCubit();
      await cubit.loadLibrary();
      expect(cubit.state.favorites.map((lesson) => lesson.id), ['fav']);

      await cubit.loadLibrary();
      expect(
        cubit.state.favorites.map((lesson) => lesson.id),
        ['fav', 'fav-2'],
      );
      await cubit.close();
    });
  });

  group('selectSection', () {
    blocTest<MyLibraryCubit, MyLibraryState>(
      'switches the visible section without refetching',
      build: buildCubit,
      act: (cubit) => cubit.selectSection(MyLibrarySection.learned),
      expect: () => [
        const MyLibraryState(section: MyLibrarySection.learned),
      ],
      verify: (_) {
        verifyZeroInteractions(repository);
      },
    );

    test('sectionLessons follows the selected section', () async {
      when(
        () => repository.fetchFavorites(),
      ).thenAnswer((_) async => [favorite]);
      when(() => repository.fetchLearned()).thenAnswer((_) async => [learned]);

      final cubit = buildCubit();
      await cubit.loadLibrary();
      expect(cubit.state.sectionLessons, [favorite]);

      cubit.selectSection(MyLibrarySection.learned);
      expect(cubit.state.sectionLessons, [learned]);
      await cubit.close();
    });
  });
}

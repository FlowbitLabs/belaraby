import 'package:belaraby/app/home/cubit/home_state.dart';
import 'package:belaraby/data/data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum HomeStatus { initial, loading, success, error }

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  void filterBy(String level) {
    emit(state.copyWith(filterBy: level));
  }

  Future<void> getLessons() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final lessons = await LessonRepository().getAllLessons();

      emit(state.copyWith(status: HomeStatus.success, lessons: lessons));
    } on Exception catch (e) {
      emit(state.copyWith(status: HomeStatus.error, error: e.toString()));
    }
  }
}

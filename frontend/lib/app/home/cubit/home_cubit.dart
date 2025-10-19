import 'package:belaraby/app/home/cubit/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum HomeStatus { initial, loading, success, error }

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  void filterBy(String level) {
    emit(state.copyWith(filterBy: level));
  }

  Future<void> getLessons() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final lessons = await Supabase.instance.client.from('lessons').select();

      emit(state.copyWith(status: HomeStatus.success, lessons: lessons));
    } on Exception catch (e) {
      emit(state.copyWith(status: HomeStatus.error, error: e.toString()));
    }
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LessonCubit extends Cubit<LessonState> {
  LessonCubit() : super(const LessonState());
}

class LessonState extends Equatable {
  const LessonState();

  @override
  List<Object> get props => [];

  LessonState copyWith() {
    return const LessonState();
  }
}

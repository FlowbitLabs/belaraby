import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyLibraryCubit extends Cubit<MyLibraryState> {
  MyLibraryCubit() : super(const MyLibraryState());
}

class MyLibraryState extends Equatable {
  const MyLibraryState();

  @override
  List<Object> get props => [];

  MyLibraryState copyWith() {
    return const MyLibraryState();
  }
}

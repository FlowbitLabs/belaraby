import 'package:belaraby/app/authentication/cubit/auth_state.dart';
import 'package:belaraby/data/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class AuthCubit extends Cubit<AuthState> {
  
  AuthCubit(this._authService) : super(AuthInitial());
  final AuthService _authService;

  Future<void> login(String email , String password) async {
    emit(AuthLoading());
    try {
      await _authService.signIn(email, password);
      emit(AuthSuccess());
    } on Exception catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> signup(String email , String password) async {
    emit(AuthLoading());
    try {
      await _authService.signUp(email, password);
      emit(AuthSuccess());
    } on Exception catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _authService.signOut();
      emit(AuthSuccess());
    } on Exception catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}

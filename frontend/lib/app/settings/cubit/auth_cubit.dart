import 'package:belaraby/data/repositories/auth_repository.dart';
import 'package:belaraby/data/repositories/profile_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

enum AuthStatus { initial, loading, success, error }

/// Cubit for the profile's account state: guest vs signed-in, plus the
/// email sign-in / sign-up / sign-out flows.
///
/// Sign-up upgrades the anonymous Supabase user (same user id), so the
/// guest's favorites, learned lessons and purchases carry over.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({AuthRepository? repository, ProfileRepository? profileRepository})
    : _repository = repository ?? AuthRepository(),
      _profileRepository = profileRepository ?? ProfileRepository(),
      super(const AuthState());

  final AuthRepository _repository;
  final ProfileRepository _profileRepository;

  /// Reads the current session (and the profile's username) into the state.
  Future<void> load() async {
    emit(
      state.copyWith(
        isAnonymous: _repository.isAnonymous,
        email: _repository.currentEmail ?? '',
      ),
    );
    if (_repository.isAnonymous) {
      emit(state.copyWith(username: ''));
      return;
    }
    try {
      final username = await _profileRepository.fetchUsername();
      if (isClosed) return;
      emit(state.copyWith(username: username ?? ''));
    } on Exception catch (error) {
      debugPrint('AuthCubit.load username fetch failed: $error');
    }
  }

  /// Saves the username on the profile.
  Future<void> setUsername(String username) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        errorMessage: '',
        infoMessage: '',
      ),
    );
    try {
      await _profileRepository.updateUsername(username);
      emit(
        state.copyWith(
          status: AuthStatus.initial,
          username: username,
          infoMessage: 'profile_username_saved',
        ),
      );
    } on Exception catch (error) {
      debugPrint('AuthCubit.setUsername failed: $error');
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'auth_error_generic',
        ),
      );
    }
  }

  /// Signs in to an existing account.
  Future<void> signIn(String email, String password) {
    return _run(() => _repository.signIn(email: email, password: password));
  }

  /// Creates an account by upgrading the anonymous user.
  Future<void> signUp(String email, String password) {
    return _run(() => _repository.signUp(email: email, password: password));
  }

  /// Emails a password-recovery link to [email].
  Future<void> sendPasswordReset(String email) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        errorMessage: '',
        infoMessage: '',
      ),
    );
    try {
      await _repository.sendPasswordReset(email);
      emit(
        state.copyWith(
          status: AuthStatus.initial,
          infoMessage: 'auth_reset_sent',
        ),
      );
    } on Exception catch (error) {
      debugPrint('AuthCubit.sendPasswordReset failed: $error');
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'auth_error_generic',
        ),
      );
    }
  }

  /// Sets a new password (recovery flow).
  Future<void> updatePassword(String password) {
    return _run(() => _repository.updatePassword(password));
  }

  /// Signs out back to a fresh guest session.
  Future<void> signOut() => _run(_repository.signOut);

  Future<void> _run(Future<void> Function() action) async {
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        errorMessage: '',
        infoMessage: '',
      ),
    );
    try {
      await action();
      emit(
        state.copyWith(
          status: AuthStatus.success,
          isAnonymous: _repository.isAnonymous,
          email: _repository.currentEmail ?? '',
        ),
      );
    } on AuthException catch (error) {
      debugPrint('AuthCubit: auth failed: ${error.code} ${error.message}');
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: _errorKey(error),
        ),
      );
    } on Exception catch (error) {
      debugPrint('AuthCubit: auth failed: $error');
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'auth_error_generic',
        ),
      );
    }
  }

  static String _errorKey(AuthException error) {
    switch (error.code) {
      case 'invalid_credentials':
        return 'auth_error_invalid_credentials';
      case 'email_exists':
      case 'user_already_exists':
        return 'auth_error_email_exists';
      case 'weak_password':
        return 'auth_error_weak_password';
      case 'validation_failed':
        return 'auth_error_invalid_email';
      default:
        return 'auth_error_generic';
    }
  }
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.isAnonymous = true,
    this.email = '',
    this.username = '',
    this.errorMessage = '',
    this.infoMessage = '',
  });

  final AuthStatus status;
  final bool isAnonymous;
  final String email;

  /// Display name from the profiles row; empty when unset.
  final String username;

  /// Translation key for the snackbar shown on failures.
  final String errorMessage;

  /// Translation key for informational snackbars (e.g. reset email sent).
  final String infoMessage;

  @override
  List<Object?> get props => [
    status,
    isAnonymous,
    email,
    username,
    errorMessage,
    infoMessage,
  ];

  AuthState copyWith({
    AuthStatus? status,
    bool? isAnonymous,
    String? email,
    String? username,
    String? errorMessage,
    String? infoMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      email: email ?? this.email,
      username: username ?? this.username,
      errorMessage: errorMessage ?? this.errorMessage,
      infoMessage: infoMessage ?? this.infoMessage,
    );
  }
}

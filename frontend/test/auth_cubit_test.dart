import 'package:belaraby/app/settings/cubit/auth_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import 'helpers.dart';

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
    when(() => repository.isAnonymous).thenReturn(true);
    when(() => repository.currentEmail).thenReturn(null);
  });

  AuthCubit buildCubit() => AuthCubit(repository: repository);

  test('load reads the current session', () {
    when(() => repository.isAnonymous).thenReturn(false);
    when(() => repository.currentEmail).thenReturn('a@b.com');
    final cubit = buildCubit()..load();
    expect(cubit.state.isAnonymous, isFalse);
    expect(cubit.state.email, 'a@b.com');
  });

  blocTest<AuthCubit, AuthState>(
    'signIn success refreshes the session info',
    setUp: () {
      when(
        () => repository.signIn(email: 'a@b.com', password: 'password1'),
      ).thenAnswer((_) async {
        when(() => repository.isAnonymous).thenReturn(false);
        when(() => repository.currentEmail).thenReturn('a@b.com');
      });
    },
    build: buildCubit,
    act: (cubit) => cubit.signIn('a@b.com', 'password1'),
    expect: () => [
      const AuthState(status: AuthStatus.loading),
      const AuthState(
        status: AuthStatus.success,
        isAnonymous: false,
        email: 'a@b.com',
      ),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'maps invalid credentials to its message key',
    setUp: () {
      when(
        () => repository.signIn(email: 'a@b.com', password: 'wrong-pass'),
      ).thenThrow(
        const AuthException('bad', code: 'invalid_credentials'),
      );
    },
    build: buildCubit,
    act: (cubit) => cubit.signIn('a@b.com', 'wrong-pass'),
    expect: () => [
      const AuthState(status: AuthStatus.loading),
      const AuthState(
        status: AuthStatus.error,
        errorMessage: 'auth_error_invalid_credentials',
      ),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'signUp maps email_exists to its message key',
    setUp: () {
      when(
        () => repository.signUp(email: 'a@b.com', password: 'password1'),
      ).thenThrow(const AuthException('exists', code: 'email_exists'));
    },
    build: buildCubit,
    act: (cubit) => cubit.signUp('a@b.com', 'password1'),
    expect: () => [
      const AuthState(status: AuthStatus.loading),
      const AuthState(
        status: AuthStatus.error,
        errorMessage: 'auth_error_email_exists',
      ),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'signOut returns to a guest session',
    setUp: () {
      when(repository.signOut).thenAnswer((_) async {});
    },
    build: buildCubit,
    act: (cubit) => cubit.signOut(),
    expect: () => [
      const AuthState(status: AuthStatus.loading),
      const AuthState(status: AuthStatus.success),
    ],
  );
}

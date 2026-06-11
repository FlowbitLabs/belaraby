import 'package:belaraby/app/settings/cubit/auth_cubit.dart';
import 'package:belaraby/app/settings/widgets/auth_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Email/password sign-in or sign-up form.
///
/// Pops with `true` after a successful authentication so the caller can
/// refresh the account-dependent cubits. The [authCubit] is the profile
/// page's instance, so the account header updates immediately.
class AuthPage extends StatelessWidget {
  const AuthPage({
    required this.isSignUp,
    required this.authCubit,
    super.key,
  });

  final bool isSignUp;
  final AuthCubit authCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: authCubit,
      child: AuthForm(isSignUp: isSignUp),
    );
  }
}

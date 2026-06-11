import 'dart:ui' as ui;

import 'package:belaraby/app/settings/cubit/auth_cubit.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
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
      child: _AuthForm(isSignUp: isSignUp),
    );
  }
}

class _AuthForm extends StatefulWidget {
  const _AuthForm({required this.isSignUp});

  final bool isSignUp;

  @override
  State<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<_AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _titleKey => widget.isSignUp ? 'auth_sign_up' : 'auth_sign_in';

  Future<void> _sendReset() async {
    final email = _emailController.text.trim();
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('auth_error_invalid_email'.tr())),
      );
      return;
    }
    await context.read<AuthCubit>().sendPasswordReset(email);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cubit = context.read<AuthCubit>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (widget.isSignUp) {
      await cubit.signUp(email, password);
    } else {
      await cubit.signIn(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _titleKey.tr(),
          style: const TextStyle(fontWeight: FontWeight.w600, color: grey190),
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.infoMessage != current.infoMessage,
        listener: (context, state) {
          if (state.infoMessage.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.infoMessage.tr())),
            );
            return;
          }
          if (state.status == AuthStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('auth_success'.tr())),
            );
            Navigator.of(context).pop(true);
          } else if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage.tr())),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.account_circle, size: 72, color: navy110),
                  const SizedBox(height: 8),
                  Text(
                    widget.isSignUp
                        ? 'auth_sign_up_subtitle'.tr()
                        : 'auth_sign_in_subtitle'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, color: grey160),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textDirection: ui.TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: 'auth_email'.tr(),
                      prefixIcon: const Icon(Icons.mail_outline),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      final valid = RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(email);
                      return valid ? null : 'auth_error_invalid_email'.tr();
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    autofillHints: const [AutofillHints.password],
                    textDirection: ui.TextDirection.ltr,
                    decoration: InputDecoration(
                      labelText: 'auth_password'.tr(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) => (value ?? '').length >= 8
                        ? null
                        : 'auth_error_weak_password'.tr(),
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state.status == AuthStatus.loading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orange120,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _titleKey.tr(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      );
                    },
                  ),
                  if (!widget.isSignUp)
                    TextButton(
                      onPressed: _sendReset,
                      child: Text(
                        'auth_forgot_password'.tr(),
                        style: const TextStyle(
                          color: navy110,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

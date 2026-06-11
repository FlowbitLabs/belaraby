import 'dart:async';

import 'package:belaraby/app/lesson/cubit/favorite_cubit.dart';
import 'package:belaraby/app/lesson/cubit/learned_cubit.dart';
import 'package:belaraby/app/settings/cubit/auth_cubit.dart';
import 'package:belaraby/app/settings/view/auth_page.dart';
import 'package:belaraby/app/settings/widgets/settings_tile.dart';
import 'package:belaraby/app/subscription/cubit/subscription_cubit.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Sign-in / sign-up tiles for guests; email + sign-out for account holders.
class AccountTiles extends StatelessWidget {
  const AccountTiles({super.key});

  Future<void> _openAuth(BuildContext context, {required bool isSignUp}) async {
    final authenticated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AuthPage(
          isSignUp: isSignUp,
          authCubit: context.read<AuthCubit>(),
        ),
      ),
    );
    if ((authenticated ?? false) && context.mounted) {
      // The identity changed — reload everything tied to the user.
      unawaited(context.read<FavoriteCubit>().loadFavorites());
      unawaited(context.read<LearnedCubit>().loadLearned());
      unawaited(context.read<SubscriptionCubit>().load());
    }
  }

  Future<void> _editUsername(BuildContext context, String current) async {
    final cubit = context.read<AuthCubit>();
    final controller = TextEditingController(text: current);
    final username = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('profile_username_title'.tr()),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 30,
          decoration: InputDecoration(hintText: 'profile_username_hint'.tr()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('dialog_cancel'.tr()),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
            child: Text('dialog_save'.tr()),
          ),
        ],
      ),
    );
    if (username != null && username.isNotEmpty && username != current) {
      await cubit.setUsername(username);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState.isAnonymous) {
      return Column(
        children: [
          SettingsTile(
            icon: Icons.login,
            label: 'auth_sign_in'.tr(),
            onTap: () => _openAuth(context, isSignUp: false),
          ),
          SettingsTile(
            icon: Icons.person_add_alt,
            label: 'auth_sign_up'.tr(),
            onTap: () => _openAuth(context, isSignUp: true),
          ),
        ],
      );
    }
    return Column(
      children: [
        SettingsTile(
          icon: Icons.mail_outline,
          label: authState.email,
          trailing: const Icon(Icons.check_circle, size: 18, color: green115),
        ),
        SettingsTile(
          icon: Icons.badge_outlined,
          label: authState.username.isNotEmpty
              ? authState.username
              : 'profile_username_unset'.tr(),
          trailing: const Icon(Icons.edit_outlined, size: 18, color: grey140),
          onTap: () => _editUsername(context, authState.username),
        ),
        SettingsTile(
          icon: Icons.logout,
          label: 'auth_sign_out'.tr(),
          onTap: () async {
            await context.read<AuthCubit>().signOut();
            if (context.mounted) {
              unawaited(context.read<FavoriteCubit>().loadFavorites());
              unawaited(context.read<LearnedCubit>().loadLearned());
              unawaited(context.read<SubscriptionCubit>().load());
            }
          },
        ),
      ],
    );
  }
}

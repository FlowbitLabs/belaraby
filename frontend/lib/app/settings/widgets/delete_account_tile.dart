import 'package:belaraby/app/settings/cubit/settings_cubit.dart';
import 'package:belaraby/app/settings/widgets/delete_account_dialog.dart';
import 'package:belaraby/app/settings/widgets/settings_tile.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Destructive tile that confirms and triggers account deletion.
class DeleteAccountTile extends StatelessWidget {
  const DeleteAccountTile({super.key});

  @override
  Widget build(BuildContext context) {
    final isDeleting = context.select(
      (SettingsCubit cubit) => cubit.state.status == SettingsStatus.loading,
    );
    return SettingsTile(
      icon: Icons.delete_forever_outlined,
      iconColor: red110,
      labelColor: red110,
      label: 'settings_delete_account'.tr(),
      trailing: isDeleting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: red110),
            )
          : null,
      onTap: isDeleting
          ? null
          : () async {
              final confirmed = await showDeleteAccountDialog(context);
              if (confirmed && context.mounted) {
                await context.read<SettingsCubit>().deleteAccount();
              }
            },
    );
  }
}

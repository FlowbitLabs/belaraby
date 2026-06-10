import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Shows the destructive account-deletion confirmation dialog.
///
/// Resolves to `true` only when the user explicitly confirms.
Future<bool> showDeleteAccountDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('settings_delete_confirm_title'.tr()),
      content: Text('settings_delete_confirm_body'.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(
            'settings_delete_confirm_cancel'.tr(),
            style: const TextStyle(color: grey160),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            'settings_delete_confirm_delete'.tr(),
            style: const TextStyle(
              color: red110,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

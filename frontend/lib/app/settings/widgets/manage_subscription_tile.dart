import 'package:belaraby/app/settings/widgets/settings_tile.dart';
import 'package:belaraby/app/util/launch_external_url.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/store_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Tile that opens the platform store's manage-subscriptions page; on web
/// it explains that subscriptions are managed on the purchasing device.
class ManageSubscriptionTile extends StatelessWidget {
  const ManageSubscriptionTile({super.key});

  String get _storeUrl {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return appleManageSubscriptionsUrl;
    }
    return googleManageSubscriptionsUrl;
  }

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      icon: Icons.manage_accounts_outlined,
      label: 'settings_manage_subscription'.tr(),
      trailing: const Icon(Icons.open_in_new, size: 18, color: grey140),
      onTap: () async {
        // Store subscriptions are managed on the device that bought them —
        // on web there is no store, so explain instead of dead-linking.
        if (kIsWeb) {
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              icon: const Icon(Icons.phone_iphone, color: yellow120, size: 40),
              title: Text('paywall_web_only_title'.tr()),
              content: Text(
                'manage_subscription_web_message'.tr(),
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('paywall_web_only_ok'.tr()),
                ),
              ],
            ),
          );
          return;
        }
        final opened = await launchExternalUrl(_storeUrl);
        if (!opened && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('link_open_error'.tr())),
          );
        }
      },
    );
  }
}

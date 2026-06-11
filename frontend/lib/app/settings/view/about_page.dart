import 'package:belaraby/app/lesson/cubit/favorite_cubit.dart';
import 'package:belaraby/app/lesson/cubit/learned_cubit.dart';
import 'package:belaraby/app/settings/cubit/settings_cubit.dart';
import 'package:belaraby/app/settings/view/legal_page.dart';
import 'package:belaraby/app/settings/widgets/delete_account_tile.dart';
import 'package:belaraby/app/settings/widgets/settings_section.dart';
import 'package:belaraby/app/settings/widgets/settings_tile.dart';
import 'package:belaraby/app/subscription/cubit/subscription_cubit.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/legal_content.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// About sub-page: legal sub-pages and the app version.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit()..loadAppVersion(),
      child: const _AboutView(),
    );
  }
}

class _AboutView extends StatelessWidget {
  const _AboutView();

  @override
  Widget build(BuildContext context) {
    final version = context.select(
      (SettingsCubit cubit) => cubit.state.appVersion,
    );
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 24,
        title: Text(
          'settings_section_about'.tr(),
          style: const TextStyle(fontWeight: FontWeight.w600, color: grey190),
        ),
      ),
      body: BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (previous, current) =>
            !previous.accountDeleted && current.accountDeleted,
        listener: (context, state) {
          // The deleted user's data is gone; refresh the global cubits so
          // the fresh anonymous session starts clean.
          context.read<FavoriteCubit>().loadFavorites();
          context.read<LearnedCubit>().loadLearned();
          context.read<SubscriptionCubit>().load();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('settings_delete_success'.tr())),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        child: ListView(
          children: [
            SettingsSection(
              title: 'about_legal'.tr(),
              children: [
                SettingsTile(
                  icon: Icons.description_outlined,
                  label: 'legal_terms_of_use'.tr(),
                  trailing: const Icon(
                    Icons.chevron_left,
                    size: 20,
                    color: grey140,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LegalPage(
                        titleKey: 'legal_terms_of_use',
                        body: termsOfUseBody,
                      ),
                    ),
                  ),
                ),
                SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'legal_privacy_policy'.tr(),
                  trailing: const Icon(
                    Icons.chevron_left,
                    size: 20,
                    color: grey140,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LegalPage(
                        titleKey: 'legal_privacy_policy',
                        body: privacyPolicyBody,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: 'settings_version'.tr(),
              children: [
                SettingsTile(
                  icon: Icons.info_outline,
                  label: 'settings_version'.tr(),
                  trailing: Text(
                    version,
                    style: const TextStyle(fontSize: 14, color: grey160),
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: 'settings_section_account'.tr(),
              children: const [DeleteAccountTile()],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

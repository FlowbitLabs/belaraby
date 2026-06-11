part of 'settings_page.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 24,
        title: Text(
          'settings_title'.tr(),
          style: const TextStyle(fontWeight: FontWeight.w600, color: grey190),
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<SettingsCubit, SettingsState>(
            listenWhen: (previous, current) =>
                previous.errorMessage != current.errorMessage &&
                current.errorMessage.isNotEmpty,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage.tr())),
              );
            },
          ),
          // Feedback for the restore-purchases flow.
          BlocListener<SubscriptionCubit, SubscriptionState>(
            listenWhen: (previous, current) =>
                previous.errorMessage != current.errorMessage ||
                previous.infoMessage != current.infoMessage ||
                previous.isPremium != current.isPremium,
            listener: _onSubscriptionChanged,
          ),
        ],
        child: ListView(
          children: [
            const AccountHeader(),
            const LearningProgressCard(),
            SettingsSection(
              title: 'settings_section_account'.tr(),
              children: const [AccountTiles()],
            ),
            SettingsSection(
              title: 'settings_section_subscription'.tr(),
              children: const [
                RestorePurchasesTile(),
                ManageSubscriptionTile(),
              ],
            ),
            SettingsSection(
              title: 'settings_section_about'.tr(),
              children: [
                SettingsTile(
                  icon: Icons.info_outline,
                  label: 'settings_section_about'.tr(),
                  trailing: const Icon(
                    Icons.chevron_left,
                    size: 20,
                    color: grey140,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AboutPage(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _onSubscriptionChanged(BuildContext context, SubscriptionState state) {
    final messenger = ScaffoldMessenger.of(context);
    if (state.errorMessage.isNotEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(state.errorMessage.tr())));
      return;
    }
    if (state.infoMessage.isNotEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(state.infoMessage.tr())));
      return;
    }
    if (state.isPremium) {
      messenger.showSnackBar(
        SnackBar(content: Text('settings_restore_success'.tr())),
      );
    }
  }
}

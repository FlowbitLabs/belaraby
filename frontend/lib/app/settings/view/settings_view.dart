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
          BlocListener<SettingsCubit, SettingsState>(
            listenWhen: (previous, current) =>
                !previous.accountDeleted && current.accountDeleted,
            listener: _onAccountDeleted,
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
            SettingsSection(
              title: 'settings_section_subscription'.tr(),
              children: const [
                _PremiumStatusTile(),
                _RestorePurchasesTile(),
                _ManageSubscriptionTile(),
              ],
            ),
            SettingsSection(
              title: 'settings_section_about'.tr(),
              children: const [
                _LegalLinkTile(
                  labelKey: 'legal_privacy_policy',
                  url: privacyPolicyUrl,
                ),
                _LegalLinkTile(
                  labelKey: 'legal_terms_of_use',
                  url: termsOfUseUrl,
                ),
                _AppVersionTile(),
              ],
            ),
            SettingsSection(
              title: 'settings_section_account'.tr(),
              children: const [_DeleteAccountTile()],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _onAccountDeleted(BuildContext context, SettingsState state) {
    // The deleted user's data is gone; refresh the global cubits so the
    // fresh anonymous session starts clean.
    context.read<FavoriteCubit>().loadFavorites();
    context.read<LearnedCubit>().loadLearned();
    context.read<SubscriptionCubit>().load();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('settings_delete_success'.tr())),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
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

class _PremiumStatusTile extends StatelessWidget {
  const _PremiumStatusTile();

  @override
  Widget build(BuildContext context) {
    final isPremium = context.select(
      (SubscriptionCubit cubit) => cubit.state.isPremium,
    );
    return SettingsTile(
      icon: isPremium
          ? Icons.workspace_premium
          : Icons.workspace_premium_outlined,
      iconColor: isPremium ? yellow120 : grey140,
      label: isPremium
          ? 'settings_premium_active'.tr()
          : 'settings_premium_inactive'.tr(),
      trailing: isPremium
          ? const Icon(Icons.check_circle, color: green115)
          : null,
    );
  }
}

class _RestorePurchasesTile extends StatelessWidget {
  const _RestorePurchasesTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isBillingAvailable != current.isBillingAvailable,
      builder: (context, state) {
        final isEnabled =
            state.isBillingAvailable &&
            state.status != SubscriptionStatus.loading;
        return SettingsTile(
          icon: Icons.restore,
          label: 'paywall_restore'.tr(),
          trailing: state.status == SubscriptionStatus.loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: yellow120,
                  ),
                )
              : null,
          onTap: isEnabled
              ? () => context.read<SubscriptionCubit>().restore()
              : null,
        );
      },
    );
  }
}

class _ManageSubscriptionTile extends StatelessWidget {
  const _ManageSubscriptionTile();

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

class _LegalLinkTile extends StatelessWidget {
  const _LegalLinkTile({required this.labelKey, required this.url});

  final String labelKey;
  final String url;

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      icon: Icons.description_outlined,
      label: labelKey.tr(),
      trailing: const Icon(Icons.open_in_new, size: 18, color: grey140),
      onTap: () async {
        final opened = await launchExternalUrl(url);
        if (!opened && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('link_open_error'.tr())),
          );
        }
      },
    );
  }
}

class _AppVersionTile extends StatelessWidget {
  const _AppVersionTile();

  @override
  Widget build(BuildContext context) {
    final version = context.select(
      (SettingsCubit cubit) => cubit.state.appVersion,
    );
    return SettingsTile(
      icon: Icons.info_outline,
      label: 'settings_version'.tr(),
      trailing: Text(
        version,
        style: const TextStyle(fontSize: 14, color: grey160),
      ),
    );
  }
}

class _DeleteAccountTile extends StatelessWidget {
  const _DeleteAccountTile();

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

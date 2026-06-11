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
            const _AccountHeader(),
            const LearningProgressCard(),
            SettingsSection(
              title: 'settings_section_account'.tr(),
              children: const [_AccountTiles(), _DeleteAccountTile()],
            ),
            SettingsSection(
              title: 'settings_section_subscription'.tr(),
              children: const [
                _RestorePurchasesTile(),
                _ManageSubscriptionTile(),
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

/// Profile header: identity (email or guest), account tier badge and a
/// subscribe call-to-action for free users.
class _AccountHeader extends StatelessWidget {
  const _AccountHeader();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final isPremium = context.select(
      (SubscriptionCubit cubit) => cubit.state.isPremium,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        margin: EdgeInsets.zero,
        color: purple140,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: purple110,
                    child: Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.isAnonymous
                              ? 'profile_guest'.tr()
                              : authState.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _TierBadge(isPremium: isPremium),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isPremium) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => navigateToPaywall(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellow120,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.workspace_premium, size: 20),
                    label: Text(
                      'profile_subscribe_now'.tr(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPremium ? yellow120 : Colors.white24,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPremium ? Icons.workspace_premium : Icons.person_outline,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isPremium ? 'profile_tier_premium'.tr() : 'profile_tier_free'.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sign-in / sign-up tiles for guests; email + sign-out for account holders.
class _AccountTiles extends StatelessWidget {
  const _AccountTiles();

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

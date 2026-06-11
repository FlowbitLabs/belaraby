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
            const _AccountHeader(),
            const LearningProgressCard(),
            SettingsSection(
              title: 'settings_section_account'.tr(),
              children: const [_AccountTiles()],
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
        color: navy140,
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
                    backgroundColor: navy110,
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
                              : (authState.username.isNotEmpty
                                    ? authState.username
                                    : authState.email),
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
              // Web demo toggle — only for signed-in accounts on the
              // server's demo allowlist (never for anonymous guests). Also
              // kept visible while a demo subscription is active, so it can
              // always be cancelled even if the allowlist check hiccups.
              if (context.select(
                (SubscriptionCubit cubit) =>
                    cubit.state.isDemoAuthorized || cubit.state.isDemoPremium,
              )) ...[
                const SizedBox(height: 12),
                const _DemoPremiumToggle(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// WEB ONLY — toggles a locally simulated premium account so the premium
/// UI can be demonstrated without going through the store purchase flow.
class _DemoPremiumToggle extends StatelessWidget {
  const _DemoPremiumToggle();

  @override
  Widget build(BuildContext context) {
    final isDemo = context.select(
      (SubscriptionCubit cubit) => cubit.state.isDemoPremium,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () =>
              context.read<SubscriptionCubit>().toggleDemoPremium(),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white38),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(
            isDemo ? Icons.science : Icons.science_outlined,
            size: 18,
          ),
          label: Text(
            isDemo ? 'profile_demo_disable'.tr() : 'profile_demo_enable'.tr(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'profile_demo_description'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
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
              height: 1,
              leadingDistribution: TextLeadingDistribution.even,
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

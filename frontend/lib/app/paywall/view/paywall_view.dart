part of 'paywall_page.dart';

class PaywallView extends StatefulWidget {
  const PaywallView({super.key});

  @override
  State<PaywallView> createState() => _PaywallViewState();
}

class _PaywallViewState extends State<PaywallView> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: grey170),
          tooltip: 'paywall_close'.tr(),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: BlocListener<SubscriptionCubit, SubscriptionState>(
        listenWhen: (previous, current) =>
            previous.isPremium != current.isPremium ||
            previous.errorMessage != current.errorMessage ||
            previous.infoMessage != current.infoMessage,
        listener: _onStateChanged,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.workspace_premium, size: 72, color: yellow120),
                const SizedBox(height: 12),
                Text(
                  'paywall_title'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: grey190,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'paywall_subtitle'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: grey160),
                ),
                const SizedBox(height: 24),
                const PaywallFeatureRow(labelKey: 'paywall_feature_stories'),
                const PaywallFeatureRow(labelKey: 'paywall_feature_new'),
                const PaywallFeatureRow(labelKey: 'paywall_feature_quizzes'),
                const SizedBox(height: 24),
                const _PaywallPackages(),
                const SizedBox(height: 8),
                const _RestorePurchasesButton(),
                const SizedBox(height: 16),
                const _PaywallRenewalTerms(),
                const SizedBox(height: 8),
                const _PaywallLegalLinks(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, SubscriptionState state) {
    final messenger = ScaffoldMessenger.of(context);
    if (state.errorMessage.isNotEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(state.errorMessage.tr())),
      );
      return;
    }
    if (state.infoMessage.isNotEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(state.infoMessage.tr())));
      return;
    }
    if (state.isPremium) {
      messenger.showSnackBar(
        SnackBar(content: Text('paywall_purchase_success'.tr())),
      );
      Navigator.of(context).pop(true);
    }
  }
}

class _PaywallPackages extends StatelessWidget {
  const _PaywallPackages();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, state) {
        if (!state.isBillingAvailable) {
          return _PaywallMessage(message: 'paywall_billing_unavailable'.tr());
        }
        if (state.status == SubscriptionStatus.loading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator(color: yellow120)),
          );
        }
        if (state.packages.isEmpty) {
          return _PaywallMessage(message: 'paywall_no_packages'.tr());
        }
        return Column(
          children: [
            for (final package in state.packages) ...[
              PaywallPackageCard(
                package: package,
                onSubscribe: () =>
                    context.read<SubscriptionCubit>().purchase(package),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _PaywallMessage extends StatelessWidget {
  const _PaywallMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, color: grey160),
      ),
    );
  }
}

/// Auto-renewal disclosure required by Apple 3.1.2: the exact store price
/// per subscription duration plus the renewal/cancellation terms.
class _PaywallRenewalTerms extends StatelessWidget {
  const _PaywallRenewalTerms();

  String _priceLine(Package package) {
    final price = package.storeProduct.priceString;
    if (package.packageType == PackageType.monthly) {
      return 'paywall_renewal_monthly'.tr(args: [price]);
    }
    if (package.packageType == PackageType.annual) {
      return 'paywall_renewal_yearly'.tr(args: [price]);
    }
    return '${package.storeProduct.title}: $price';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      buildWhen: (previous, current) => previous.packages != current.packages,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final package in state.packages)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  _priceLine(package),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: grey160),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              'paywall_renewal_terms'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: grey160),
            ),
          ],
        );
      },
    );
  }
}

/// Tappable links to the privacy policy and terms of use, required for
/// auto-renewable subscriptions (Apple 3.1.2).
class _PaywallLegalLinks extends StatelessWidget {
  const _PaywallLegalLinks();

  Future<void> _open(BuildContext context, String url) async {
    final opened = await launchExternalUrl(url);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('link_open_error'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const linkStyle = TextStyle(
      fontSize: 13,
      color: grey160,
      decoration: TextDecoration.underline,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => _open(context, privacyPolicyUrl),
          child: Text('legal_privacy_policy'.tr(), style: linkStyle),
        ),
        const Text('·', style: TextStyle(color: grey160)),
        TextButton(
          onPressed: () => _open(context, termsOfUseUrl),
          child: Text('legal_terms_of_use'.tr(), style: linkStyle),
        ),
      ],
    );
  }
}

class _RestorePurchasesButton extends StatelessWidget {
  const _RestorePurchasesButton();

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
        return TextButton(
          onPressed: isEnabled
              ? () => context.read<SubscriptionCubit>().restore()
              : null,
          child: Text(
            'paywall_restore'.tr(),
            style: const TextStyle(
              color: grey160,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      },
    );
  }
}

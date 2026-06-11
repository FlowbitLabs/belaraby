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
                const PaywallPackages(),
                const SizedBox(height: 8),
                const RestorePurchasesButton(),
                const SizedBox(height: 16),
                const PaywallRenewalTerms(),
                const SizedBox(height: 8),
                const PaywallLegalLinks(),
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

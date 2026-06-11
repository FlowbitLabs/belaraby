import 'package:belaraby/app/paywall/widgets/paywall_message.dart';
import 'package:belaraby/app/paywall/widgets/paywall_package_card.dart';
import 'package:belaraby/app/subscription/cubit/subscription_cubit.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// List of purchasable store packages, with loading and empty states.
class PaywallPackages extends StatelessWidget {
  const PaywallPackages({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      builder: (context, state) {
        if (!state.isBillingAvailable) {
          return PaywallMessage(message: 'paywall_billing_unavailable'.tr());
        }
        if (state.status == SubscriptionStatus.loading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator(color: yellow120)),
          );
        }
        if (state.packages.isEmpty) {
          // Offerings can come back empty on flaky connections or store
          // misconfiguration — give the user a way out of the dead end.
          return Column(
            children: [
              PaywallMessage(message: 'paywall_no_packages'.tr()),
              TextButton(
                onPressed: () => context.read<SubscriptionCubit>().load(),
                child: Text(
                  'paywall_retry'.tr(),
                  style: const TextStyle(color: yellow120),
                ),
              ),
            ],
          );
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

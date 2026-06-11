import 'package:belaraby/app/subscription/cubit/subscription_cubit.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Auto-renewal disclosure required by Apple 3.1.2: the exact store price
/// per subscription duration plus the renewal/cancellation terms.
class PaywallRenewalTerms extends StatelessWidget {
  const PaywallRenewalTerms({super.key});

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

import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Card presenting one store package with its localized store price and a
/// subscribe button.
class PaywallPackageCard extends StatelessWidget {
  const PaywallPackageCard({
    required this.package,
    required this.onSubscribe,
    super.key,
  });

  final Package package;
  final VoidCallback onSubscribe;

  String get _label {
    if (package.packageType == PackageType.monthly) {
      return 'paywall_monthly'.tr();
    }
    if (package.packageType == PackageType.annual) {
      return 'paywall_yearly'.tr();
    }
    return package.storeProduct.title;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: grey190,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // Localized price string provided by the store.
                    package.storeProduct.priceString,
                    style: const TextStyle(fontSize: 16, color: grey160),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onSubscribe,
              style: ElevatedButton.styleFrom(
                backgroundColor: orange120,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text('paywall_subscribe'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

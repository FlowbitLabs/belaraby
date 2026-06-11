import 'package:belaraby/app/util/launch_external_url.dart';
import 'package:belaraby/constant/colors.dart';
import 'package:belaraby/constant/legal_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Tappable links to the privacy policy and terms of use, required for
/// auto-renewable subscriptions (Apple 3.1.2).
class PaywallLegalLinks extends StatelessWidget {
  const PaywallLegalLinks({super.key});

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

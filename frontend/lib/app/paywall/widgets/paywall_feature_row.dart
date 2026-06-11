import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// A single bullet point of the premium pitch.
class PaywallFeatureRow extends StatelessWidget {
  const PaywallFeatureRow({required this.labelKey, super.key});

  /// Translation key of the feature description.
  final String labelKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: orange120, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              labelKey.tr(),
              style: const TextStyle(fontSize: 16, color: grey180),
            ),
          ),
        ],
      ),
    );
  }
}

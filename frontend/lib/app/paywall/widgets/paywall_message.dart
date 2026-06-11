import 'package:belaraby/constant/colors.dart';
import 'package:flutter/material.dart';

/// Centered informational message shown in place of the package list.
class PaywallMessage extends StatelessWidget {
  const PaywallMessage({required this.message, super.key});

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

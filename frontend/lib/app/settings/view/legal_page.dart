import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Scrollable in-app legal text (terms of use / privacy policy).
class LegalPage extends StatelessWidget {
  const LegalPage({required this.titleKey, required this.body, super.key});

  final String titleKey;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 24,
        title: Text(
          titleKey.tr(),
          style: const TextStyle(fontWeight: FontWeight.w600, color: grey190),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            margin: EdgeInsets.zero,
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                body,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.8,
                  color: grey180,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

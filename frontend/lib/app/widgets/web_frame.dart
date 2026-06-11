import 'package:belaraby/constant/colors.dart';
import 'package:flutter/material.dart';

/// Presents the phone-designed app nicely on wide (web/desktop) viewports:
/// centers it in a phone-width card on a branded backdrop instead of
/// stretching the mobile layout across the whole window.
///
/// Narrow viewports (phones, small browser windows) pass through untouched.
class WebFrame extends StatelessWidget {
  const WebFrame({required this.child, super.key});

  /// Viewports wider than this get the centered phone frame.
  static const double _frameThreshold = 600;

  /// Width of the framed app on wide viewports.
  static const double _frameWidth = 460;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= _frameThreshold) {
          return child;
        }
        return ColoredBox(
          color: navy140,
          child: Center(
            // Phone-style bezel: a dark rounded border with a thin
            // highlight edge, so the app reads as a device mockup.
            child: Container(
              width: _frameWidth,
              margin: const EdgeInsets.symmetric(vertical: 24),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: grey190,
                borderRadius: BorderRadius.circular(44),
                border: Border.all(color: grey170),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 48,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

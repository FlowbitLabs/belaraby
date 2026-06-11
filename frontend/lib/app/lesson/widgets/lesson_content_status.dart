import 'package:belaraby/constant/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Shared loading state of the lesson content tabs.
class LessonContentLoading extends StatelessWidget {
  const LessonContentLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: yellow120));
  }
}

/// Shared error state of the lesson content tabs, with a retry button.
class LessonContentError extends StatelessWidget {
  const LessonContentError({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 40, color: grey140),
            const SizedBox(height: 12),
            Text(
              'lesson_content_error'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: grey160),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: yellow120,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              onPressed: onRetry,
              child: Text('retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared friendly empty state of the lesson content tabs.
class LessonContentEmpty extends StatelessWidget {
  const LessonContentEmpty({
    required this.messageKey,
    required this.icon,
    super.key,
  });

  final String messageKey;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: grey140),
            const SizedBox(height: 12),
            Text(
              messageKey.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: grey160),
            ),
          ],
        ),
      ),
    );
  }
}

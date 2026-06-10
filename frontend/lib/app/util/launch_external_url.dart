import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in the external browser (or matching native app).
///
/// Returns `false` when the URL could not be opened so callers can show a
/// localized error message; never throws.
Future<bool> launchExternalUrl(String url) async {
  try {
    return await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } on Exception catch (error) {
    debugPrint('launchExternalUrl failed for $url: $error');
    return false;
  }
}

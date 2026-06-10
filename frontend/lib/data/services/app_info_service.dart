import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Exposes app package metadata (version, build number) to the UI layer.
class AppInfoService {
  /// Returns `"<version> (<build>)"`, or an empty string when the platform
  /// info cannot be read.
  Future<String> getVersionLabel() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return '${info.version} (${info.buildNumber})';
    } on Exception catch (error) {
      debugPrint('AppInfoService.getVersionLabel failed: $error');
      return '';
    }
  }
}

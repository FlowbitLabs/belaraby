import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Picks and applies the best available Arabic voice on [tts].
///
/// Voice inventories differ wildly per platform (and on web they load
/// asynchronously after page load), so this retries fetching the voice
/// list, scores the Arabic candidates by quality hints in their names,
/// and falls back to a plain language tag when nothing matches.
Future<void> applyBestArabicVoice(FlutterTts tts) async {
  final voice = await _findBestArabicVoice(tts);
  if (voice != null) {
    await tts.setVoice(voice);
  } else {
    // No explicit voice available — let the engine resolve the language.
    try {
      await tts.setLanguage('ar-SA');
    } on Exception {
      await tts.setLanguage('ar');
    }
  }
  await tts.setPitch(1);
}

/// The "normal" speech rate for this platform.
///
/// flutter_tts forwards the rate verbatim: on web it becomes
/// `SpeechSynthesisUtterance.rate` where 1.0 is normal speed, while the
/// mobile engines treat ~0.5 as normal.
double get platformNormalRate => kIsWeb ? 1.0 : 0.5;

Future<Map<String, String>?> _findBestArabicVoice(FlutterTts tts) async {
  Object? raw;
  // Web browsers often report an empty voice list right after page load.
  for (var attempt = 0; attempt < 6; attempt++) {
    try {
      raw = await tts.getVoices;
    } on Exception {
      return null;
    }
    if (raw is List && raw.isNotEmpty) break;
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }
  if (raw is! List) return null;

  Map<String, String>? best;
  var bestScore = -1;
  for (final entry in raw) {
    if (entry is! Map) continue;
    final name = entry['name']?.toString() ?? '';
    final locale = entry['locale']?.toString() ?? '';
    final haystack = '$name $locale'.toLowerCase();
    if (!haystack.contains('ar-') &&
        !haystack.startsWith('ar') &&
        !haystack.contains('arabic')) {
      continue;
    }
    final score = _qualityScore(haystack);
    if (score > bestScore) {
      bestScore = score;
      best = {'name': name, 'locale': locale};
    }
  }
  return best;
}

/// Heuristic quality ranking from hints vendors put in voice names.
int _qualityScore(String voice) {
  var score = 0;
  // Cloud/neural voices first (Chrome exposes them as "Google ...").
  if (voice.contains('google')) score += 8;
  if (voice.contains('natural') || voice.contains('neural')) score += 6;
  if (voice.contains('premium') ||
      voice.contains('enhanced') ||
      voice.contains('plus')) {
    score += 4;
  }
  // Siri voices on Apple platforms are the smoothest local ones.
  if (voice.contains('siri')) score += 4;
  if (voice.contains('compact')) score -= 3;
  // Prefer a mainstream locale when otherwise tied.
  if (voice.contains('ar-sa') || voice.contains('ar_sa')) score += 2;
  if (voice.contains('ar-eg') || voice.contains('ar_eg')) score += 1;
  return score;
}

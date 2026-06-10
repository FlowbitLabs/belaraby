import 'package:flutter/foundation.dart';
import 'package:translator/translator.dart';

/// Simple service for translating Arabic text to English.
class TranslationService {
  /// Returns the shared singleton instance.
  factory TranslationService() => _instance;

  TranslationService._internal();
  static final TranslationService _instance = TranslationService._internal();

  final GoogleTranslator _translator = GoogleTranslator();

  /// Translates Arabic text to English.
  /// Returns the translated text or throws an exception if translation fails.
  Future<String> translateWord(String arabicText) async {
    try {
      if (arabicText.trim().isEmpty) {
        throw const TranslationException('Input text cannot be empty');
      }

      debugPrint('Translating: ${arabicText.trim()}');

      final translation = await _translator.translate(
        arabicText.trim(),
        from: 'ar',
      );

      final result = translation.text;

      if (result.isEmpty) {
        throw const TranslationException('Translation returned empty result');
      }

      debugPrint('Translation result: $result');
      return result;
    } on TranslationException {
      rethrow;
    } catch (e) {
      debugPrint('Translation error: $e');
      throw TranslationException('Translation failed: $e');
    }
  }
}

/// Exception thrown when translation operations fail.
class TranslationException implements Exception {
  const TranslationException(this.message);
  final String message;

  @override
  String toString() => 'TranslationException: $message';
}

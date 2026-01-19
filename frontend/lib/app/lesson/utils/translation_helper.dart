import 'package:belaraby/data/services/translation_service.dart';
import 'package:flutter/foundation.dart';

/// A simple helper class for translating words without using cubit/bloc pattern.
/// Provides direct translation functionality with callback-based results.
class TranslationHelper {
  static final TranslationHelper _instance = TranslationHelper._internal();
  factory TranslationHelper() => _instance;

  TranslationHelper._internal();

  final TranslationService _translationService = TranslationService();
  bool _isTranslating = false;

  /// Translates a word and calls the appropriate callback based on the result.
  ///
  /// [word] - The Arabic word to translate
  /// [onLoading] - Called when translation starts
  /// [onSuccess] - Called with translated text when successful
  /// [onError] - Called with error message when translation fails
  Future<void> translateWord(
    String word, {
    VoidCallback? onLoading,
    required void Function(String translatedText) onSuccess,
    required void Function(String errorMessage) onError,
  }) async {
    // Prevent concurrent translations
    if (_isTranslating) {
      debugPrint('Translation already in progress, ignoring new request');
      return;
    }

    if (word.trim().isEmpty) {
      onError('Word cannot be empty');
      return;
    }

    _isTranslating = true;
    debugPrint('Starting translation for word: $word');
    onLoading?.call();

    try {
      final translatedText = await _translationService.translateWord(word);
      debugPrint('Translation successful: $translatedText');
      onSuccess(translatedText);
    } on TranslationException catch (e) {
      debugPrint('Translation exception: ${e.message}');
      onError(e.message);
    } catch (e) {
      debugPrint('Unexpected translation error: $e');
      onError('Translation failed. Please try again.');
    } finally {
      _isTranslating = false;
    }
  }

  /// Resets the translation state (useful when canceling ongoing translations)
  void reset() {
    _isTranslating = false;
  }
}

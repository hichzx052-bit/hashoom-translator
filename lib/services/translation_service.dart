import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationResult {
  final String translatedText;
  final String detectedLanguage;
  final double confidence;

  TranslationResult({
    required this.translatedText,
    this.detectedLanguage = '',
    this.confidence = 0.0,
  });
}

class TranslationService {
  // MyMemory API - free, no key needed
  static const String _baseUrl = 'https://api.mymemory.translated.net/get';

  /// Translate text from one language to another
  Future<TranslationResult> translate({
    required String text,
    required String from,
    required String to,
  }) async {
    try {
      final langPair = '$from|$to';
      final uri = Uri.parse('$_baseUrl?q=${Uri.encodeComponent(text)}&langpair=${Uri.encodeComponent(langPair)}');

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translated = data['responseData']['translatedText'] ?? '';
        final match = data['responseData']['match'] ?? 0.0;

        // Try to detect language from matches
        String detectedLang = '';
        if (data['matches'] != null && (data['matches'] as List).isNotEmpty) {
          final firstMatch = data['matches'][0];
          detectedLang = firstMatch['source'] ?? '';
        }

        return TranslationResult(
          translatedText: translated,
          detectedLanguage: detectedLang,
          confidence: (match is double) ? match : (match as num).toDouble(),
        );
      } else {
        throw Exception('Translation API error: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback: try LibreTranslate
      return _fallbackTranslate(text: text, from: from, to: to);
    }
  }

  /// Detect the language of text
  Future<String> detectLanguage(String text) async {
    try {
      // Use MyMemory with auto-detect
      final uri = Uri.parse('$_baseUrl?q=${Uri.encodeComponent(text)}&langpair=autodetect|en');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['matches'] != null && (data['matches'] as List).isNotEmpty) {
          return data['matches'][0]['source'] ?? 'unknown';
        }
      }
      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  /// Fallback translation using LibreTranslate
  Future<TranslationResult> _fallbackTranslate({
    required String text,
    required String from,
    required String to,
  }) async {
    try {
      final uri = Uri.parse('https://libretranslate.de/translate');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'q': text,
          'source': from,
          'target': to,
          'format': 'text',
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TranslationResult(
          translatedText: data['translatedText'] ?? '',
        );
      }
    } catch (_) {}

    return TranslationResult(translatedText: '⚠️ خطأ في الترجمة');
  }

  /// Get supported languages
  static Map<String, String> get supportedLanguages => {
    'ar': 'العربية',
    'en': 'English',
    'fr': 'Français',
    'es': 'Español',
    'de': 'Deutsch',
    'tr': 'Türkçe',
    'zh': '中文',
    'ja': '日本語',
    'ko': '한국어',
    'ru': 'Русский',
    'pt': 'Português',
    'it': 'Italiano',
    'hi': 'हिन्दी',
    'ur': 'اردو',
    'fa': 'فارسی',
    'id': 'Indonesia',
    'ms': 'Malay',
    'th': 'ไทย',
    'vi': 'Tiếng Việt',
    'nl': 'Nederlands',
  };
}

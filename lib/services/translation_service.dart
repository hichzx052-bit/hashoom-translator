import 'package:translator/translator.dart';
import '../models/translation_result.dart';

class TranslationService {
  final GoogleTranslator _translator = GoogleTranslator();

  Future<TranslationResult> translate({
    required String text,
    required String from,
    required String to,
    bool isVoice = false,
  }) async {
    try {
      final translation = await _translator.translate(
        text,
        from: from == 'auto' ? 'auto' : from,
        to: to,
      );

      return TranslationResult(
        originalText: text,
        translatedText: translation.text,
        sourceLanguage: translation.sourceLanguage.code,
        targetLanguage: to,
        isVoice: isVoice,
      );
    } catch (e) {
      return TranslationResult(
        originalText: text,
        translatedText: 'خطأ في الترجمة: $e',
        sourceLanguage: from,
        targetLanguage: to,
        isVoice: isVoice,
      );
    }
  }

  Future<String> detectLanguage(String text) async {
    try {
      final translation = await _translator.translate(text, from: 'auto', to: 'en');
      return translation.sourceLanguage.code;
    } catch (e) {
      return 'unknown';
    }
  }
}

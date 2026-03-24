import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;

  /// Initialize speech recognition
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize(
      onStatus: (status) {
        _isListening = status == 'listening';
      },
      onError: (error) {
        _isListening = false;
      },
    );
    return _isInitialized;
  }

  /// Start listening for speech
  Future<void> startListening({
    required String language,
    required Function(String text, bool isFinal) onResult,
    Function(String lang)? onLanguageDetected,
  }) async {
    if (!_isInitialized) {
      final ok = await initialize();
      if (!ok) return;
    }

    _isListening = true;

    // Map language code to locale
    String localeId = _getLocaleId(language);

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords, result.finalResult);

        // Try to detect language from the recognized text
        if (onLanguageDetected != null && result.finalResult) {
          // The speech-to-text already knows the language since we specify it
          // But we can try to detect if user spoke a different language
          onLanguageDetected(language);
        }
      },
      localeId: localeId,
      listenMode: stt.ListenMode.dictation,
      cancelOnError: false,
      partialResults: true,
    );
  }

  /// Stop listening
  Future<void> stopListening() async {
    _isListening = false;
    await _speech.stop();
  }

  /// Get available languages/locales
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) await initialize();
    return _speech.locales();
  }

  /// Map our language codes to speech recognition locale IDs
  String _getLocaleId(String langCode) {
    final map = {
      'ar': 'ar_SA',
      'en': 'en_US',
      'fr': 'fr_FR',
      'es': 'es_ES',
      'de': 'de_DE',
      'tr': 'tr_TR',
      'zh': 'zh_CN',
      'ja': 'ja_JP',
      'ko': 'ko_KR',
      'ru': 'ru_RU',
      'pt': 'pt_BR',
      'it': 'it_IT',
      'hi': 'hi_IN',
      'ur': 'ur_PK',
      'fa': 'fa_IR',
      'id': 'id_ID',
      'ms': 'ms_MY',
      'th': 'th_TH',
      'vi': 'vi_VN',
      'nl': 'nl_NL',
    };
    return map[langCode] ?? 'en_US';
  }
}

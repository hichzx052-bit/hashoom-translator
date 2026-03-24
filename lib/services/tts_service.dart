import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  List<dynamic> _voices = [];
  String? _currentVoice;
  double _rate = 0.5;
  double _pitch = 1.0;

  List<dynamic> get voices => _voices;
  String? get currentVoice => _currentVoice;

  /// Initialize TTS engine
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _tts.setSharedInstance(true);
    await _tts.awaitSpeakCompletion(true);

    // Load saved settings
    final prefs = await SharedPreferences.getInstance();
    _rate = prefs.getDouble('tts_rate') ?? 0.5;
    _pitch = prefs.getDouble('tts_pitch') ?? 1.0;
    _currentVoice = prefs.getString('tts_voice');

    await _tts.setSpeechRate(_rate);
    await _tts.setPitch(_pitch);

    // Get available voices
    _voices = await _tts.getVoices;

    if (_currentVoice != null) {
      await _tts.setVoice({"name": _currentVoice!, "locale": ""});
    }

    _isInitialized = true;
  }

  /// Speak text in specified language
  Future<void> speak(String text, String language) async {
    if (!_isInitialized) await initialize();

    await _tts.setLanguage(_getLanguageCode(language));
    await _tts.speak(text);
  }

  /// Stop speaking
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Set speech rate (0.0 to 1.0)
  Future<void> setRate(double rate) async {
    _rate = rate;
    await _tts.setSpeechRate(rate);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_rate', rate);
  }

  /// Set pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    _pitch = pitch;
    await _tts.setPitch(pitch);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_pitch', pitch);
  }

  /// Set voice by name
  Future<void> setVoice(String voiceName) async {
    _currentVoice = voiceName;
    await _tts.setVoice({"name": voiceName, "locale": ""});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_voice', voiceName);
  }

  /// Get voices for a specific language
  List<dynamic> getVoicesForLanguage(String langCode) {
    final code = _getLanguageCode(langCode);
    return _voices.where((v) {
      final locale = v['locale']?.toString() ?? '';
      return locale.startsWith(langCode) || locale.startsWith(code);
    }).toList();
  }

  String _getLanguageCode(String langCode) {
    final map = {
      'ar': 'ar-SA',
      'en': 'en-US',
      'fr': 'fr-FR',
      'es': 'es-ES',
      'de': 'de-DE',
      'tr': 'tr-TR',
      'zh': 'zh-CN',
      'ja': 'ja-JP',
      'ko': 'ko-KR',
      'ru': 'ru-RU',
      'pt': 'pt-BR',
      'it': 'it-IT',
      'hi': 'hi-IN',
      'ur': 'ur-PK',
      'fa': 'fa-IR',
      'id': 'id-ID',
      'ms': 'ms-MY',
      'th': 'th-TH',
      'vi': 'vi-VN',
      'nl': 'nl-NL',
    };
    return map[langCode] ?? 'en-US';
  }
}

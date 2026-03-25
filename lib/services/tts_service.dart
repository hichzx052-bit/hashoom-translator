import 'package:flutter_tts/flutter_tts.dart';
import '../models/voice.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  List<dynamic> _availableVoices = [];
  VoiceOption? _currentVoice;
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;
  VoiceOption? get currentVoice => _currentVoice;

  Future<void> initialize() async {
    await _tts.setSharedInstance(true);
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() => _isSpeaking = true);
    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setCancelHandler(() => _isSpeaking = false);
    _tts.setErrorHandler((msg) => _isSpeaking = false);

    _availableVoices = await _tts.getVoices ?? [];
  }

  Future<List<VoiceOption>> getVoicesForLanguage(String langCode) async {
    List<VoiceOption> voices = [];
    for (var voice in _availableVoices) {
      if (voice is Map) {
        String locale = (voice['locale'] ?? '').toString().toLowerCase();
        if (locale.startsWith(langCode.toLowerCase())) {
          voices.add(VoiceOption(
            id: voice['name'] ?? '',
            name: voice['name'] ?? 'Unknown',
            language: langCode,
            gender: (voice['name'] ?? '').toString().toLowerCase().contains('female')
                ? 'female'
                : 'male',
          ));
        }
      }
    }
    return voices;
  }

  Future<void> speak(String text, {String? language, VoiceOption? voice}) async {
    if (text.isEmpty) return;

    if (voice != null) {
      await _tts.setVoice({'name': voice.id, 'locale': voice.language});
      await _tts.setPitch(voice.pitch);
      await _tts.setSpeechRate(voice.rate);
    } else if (language != null) {
      await _tts.setLanguage(language);
    }

    await _tts.speak(text);
    _isSpeaking = true;
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  Future<void> setVoice(VoiceOption voice) async {
    _currentVoice = voice;
    await _tts.setVoice({'name': voice.id, 'locale': voice.language});
    await _tts.setPitch(voice.pitch);
    await _tts.setSpeechRate(voice.rate);
  }

  void dispose() {
    _tts.stop();
  }
}

import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;

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

  Future<void> startListening({
    required Function(SpeechRecognitionResult) onResult,
    String localeId = 'ar-SA',
    Function(String)? onStatus,
  }) async {
    if (!_isInitialized) await initialize();
    if (_isListening) return;

    await _speech.listen(
      onResult: onResult,
      localeId: localeId,
      listenMode: ListenMode.dictation,
      cancelOnError: false,
      partialResults: true,
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: 3),
    );
    _isListening = true;
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    await _speech.stop();
    _isListening = false;
  }

  Future<List<LocaleName>> getLocales() async {
    if (!_isInitialized) await initialize();
    return _speech.locales();
  }

  void dispose() {
    if (_isListening) {
      _speech.stop();
    }
  }
}

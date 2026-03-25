import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/language.dart';
import '../models/voice.dart';
import '../models/translation_result.dart';
import '../utils/constants.dart';
import 'translation_service.dart';
import 'speech_service.dart';
import 'tts_service.dart';

class AppState extends ChangeNotifier {
  final TranslationService _translationService = TranslationService();
  final SpeechService _speechService = SpeechService();
  final TtsService _ttsService = TtsService();

  // State
  Language _sourceLang = Language.fromCode('auto');
  Language _targetLang = Language.fromCode('ar');
  bool _autoDetect = true;
  bool _isListening = false;
  bool _isTranslating = false;
  bool _isSpeaking = false;
  bool _backgroundMode = false;
  bool _overlayMode = false;
  String _currentText = '';
  String _translatedText = '';
  String _detectedLanguage = '';
  List<TranslationResult> _history = [];
  List<VoiceOption> _availableVoices = [];
  VoiceOption? _selectedVoice;

  // Getters
  Language get sourceLang => _sourceLang;
  Language get targetLang => _targetLang;
  bool get autoDetect => _autoDetect;
  bool get isListening => _isListening;
  bool get isTranslating => _isTranslating;
  bool get isSpeaking => _isSpeaking;
  bool get backgroundMode => _backgroundMode;
  bool get overlayMode => _overlayMode;
  String get currentText => _currentText;
  String get translatedText => _translatedText;
  String get detectedLanguage => _detectedLanguage;
  List<TranslationResult> get history => _history;
  List<VoiceOption> get availableVoices => _availableVoices;
  VoiceOption? get selectedVoice => _selectedVoice;
  SpeechService get speechService => _speechService;
  TtsService get ttsService => _ttsService;

  Future<void> initialize() async {
    await _speechService.initialize();
    await _ttsService.initialize();
    await _loadPreferences();
    await _loadVoices();
    notifyListeners();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final srcCode = prefs.getString(AppConstants.prefSourceLang) ?? 'auto';
    final tgtCode = prefs.getString(AppConstants.prefTargetLang) ?? 'ar';
    _autoDetect = prefs.getBool(AppConstants.prefAutoDetect) ?? true;
    _backgroundMode = prefs.getBool(AppConstants.prefBackgroundEnabled) ?? false;
    _overlayMode = prefs.getBool(AppConstants.prefOverlayEnabled) ?? false;

    if (srcCode != 'auto') {
      _sourceLang = Language.fromCode(srcCode);
    }
    _targetLang = Language.fromCode(tgtCode);
  }

  Future<void> _loadVoices() async {
    _availableVoices = await _ttsService.getVoicesForLanguage(_targetLang.code);
    if (_availableVoices.isNotEmpty && _selectedVoice == null) {
      _selectedVoice = _availableVoices.first;
    }
  }

  void setSourceLanguage(Language lang) async {
    _sourceLang = lang;
    _autoDetect = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefSourceLang, lang.code);
    await prefs.setBool(AppConstants.prefAutoDetect, false);
    notifyListeners();
  }

  void setTargetLanguage(Language lang) async {
    _targetLang = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefTargetLang, lang.code);
    _loadVoices();
    notifyListeners();
  }

  void setAutoDetect(bool value) async {
    _autoDetect = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefAutoDetect, value);
    notifyListeners();
  }

  void setVoice(VoiceOption voice) {
    _selectedVoice = voice;
    _ttsService.setVoice(voice);
    notifyListeners();
  }

  // Start voice listening
  Future<void> startListening() async {
    _isListening = true;
    _currentText = '';
    notifyListeners();

    String locale = _autoDetect ? 'ar-SA' : _sourceLang.speechLocale;

    await _speechService.startListening(
      localeId: locale,
      onResult: (result) {
        _currentText = result.recognizedWords;
        notifyListeners();

        if (result.finalResult) {
          _translateAndSpeak(_currentText);
        }
      },
    );
  }

  Future<void> stopListening() async {
    await _speechService.stopListening();
    _isListening = false;
    notifyListeners();

    if (_currentText.isNotEmpty) {
      await _translateAndSpeak(_currentText);
    }
  }

  // Translate text input
  Future<void> translateText(String text) async {
    if (text.isEmpty) return;
    _currentText = text;
    _isTranslating = true;
    notifyListeners();

    // Detect language if auto
    String fromLang = _sourceLang.code;
    if (_autoDetect) {
      fromLang = await _translationService.detectLanguage(text);
      _detectedLanguage = fromLang;
    }

    final result = await _translationService.translate(
      text: text,
      from: fromLang,
      to: _targetLang.code,
    );

    _translatedText = result.translatedText;
    _isTranslating = false;
    _history.insert(0, result);
    if (_history.length > 50) _history.removeLast();
    notifyListeners();
  }

  // Translate and speak
  Future<void> _translateAndSpeak(String text) async {
    await translateText(text);

    if (_translatedText.isNotEmpty) {
      await speakTranslation();
    }
  }

  Future<void> speakTranslation() async {
    if (_translatedText.isEmpty) return;
    _isSpeaking = true;
    notifyListeners();

    await _ttsService.speak(
      _translatedText,
      language: _targetLang.speechLocale,
      voice: _selectedVoice,
    );

    _isSpeaking = false;
    notifyListeners();
  }

  Future<void> stopSpeaking() async {
    await _ttsService.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  // Swap languages
  void swapLanguages() {
    if (_autoDetect) return;
    final temp = _sourceLang;
    _sourceLang = _targetLang;
    _targetLang = temp;
    _loadVoices();
    notifyListeners();
  }

  // Background mode
  void setBackgroundMode(bool value) async {
    _backgroundMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefBackgroundEnabled, value);
    notifyListeners();
  }

  void setOverlayMode(bool value) async {
    _overlayMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefOverlayEnabled, value);
    notifyListeners();
  }

  // Bidirectional translation mode for calls/games
  Future<String> translateBidirectional({
    required String text,
    required String myLang,
    required String theirLang,
    required bool isMySpeech,
  }) async {
    final from = isMySpeech ? myLang : theirLang;
    final to = isMySpeech ? theirLang : myLang;

    final result = await _translationService.translate(
      text: text,
      from: from,
      to: to,
      isVoice: true,
    );

    return result.translatedText;
  }

  @override
  void dispose() {
    _speechService.dispose();
    _ttsService.dispose();
    super.dispose();
  }
}

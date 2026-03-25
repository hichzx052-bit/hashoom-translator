class AppConfig {
  static const String appName = 'هشوم ترجمة';
  static const String appVersion = '2.0.0';
  static const String developerCode = 'Hichamdzz';
  static const String updateServerUrl = 'https://api.github.com/repos/hichzx052-bit/hashoom-translator/releases/latest';
  static const String apiKeyPrefix = 'HSHM';
  
  // Supported languages
  static const Map<String, String> supportedLanguages = {
    'ar': 'العربية',
    'en': 'English',
    'fr': 'Français',
    'es': 'Español',
    'de': 'Deutsch',
    'tr': 'Türkçe',
    'ru': 'Русский',
    'zh': '中文',
    'ja': '日本語',
    'ko': '한국어',
    'pt': 'Português',
    'it': 'Italiano',
    'hi': 'हिन्दी',
    'ur': 'اردو',
    'fa': 'فارسی',
    'id': 'Bahasa Indonesia',
    'ms': 'Bahasa Melayu',
    'th': 'ภาษาไทย',
    'vi': 'Tiếng Việt',
    'nl': 'Nederlands',
  };

  // Language codes for speech recognition
  static const Map<String, String> speechLocales = {
    'ar': 'ar-SA',
    'en': 'en-US',
    'fr': 'fr-FR',
    'es': 'es-ES',
    'de': 'de-DE',
    'tr': 'tr-TR',
    'ru': 'ru-RU',
    'zh': 'zh-CN',
    'ja': 'ja-JP',
    'ko': 'ko-KR',
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
}

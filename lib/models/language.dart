class Language {
  final String code;
  final String name;
  final String speechLocale;
  final String flag;

  const Language({
    required this.code,
    required this.name,
    required this.speechLocale,
    this.flag = '🌍',
  });

  static const List<Language> all = [
    Language(code: 'ar', name: 'العربية', speechLocale: 'ar-SA', flag: '🇸🇦'),
    Language(code: 'en', name: 'English', speechLocale: 'en-US', flag: '🇺🇸'),
    Language(code: 'fr', name: 'Français', speechLocale: 'fr-FR', flag: '🇫🇷'),
    Language(code: 'es', name: 'Español', speechLocale: 'es-ES', flag: '🇪🇸'),
    Language(code: 'de', name: 'Deutsch', speechLocale: 'de-DE', flag: '🇩🇪'),
    Language(code: 'tr', name: 'Türkçe', speechLocale: 'tr-TR', flag: '🇹🇷'),
    Language(code: 'ru', name: 'Русский', speechLocale: 'ru-RU', flag: '🇷🇺'),
    Language(code: 'zh', name: '中文', speechLocale: 'zh-CN', flag: '🇨🇳'),
    Language(code: 'ja', name: '日本語', speechLocale: 'ja-JP', flag: '🇯🇵'),
    Language(code: 'ko', name: '한국어', speechLocale: 'ko-KR', flag: '🇰🇷'),
    Language(code: 'pt', name: 'Português', speechLocale: 'pt-BR', flag: '🇧🇷'),
    Language(code: 'it', name: 'Italiano', speechLocale: 'it-IT', flag: '🇮🇹'),
    Language(code: 'hi', name: 'हिन्दी', speechLocale: 'hi-IN', flag: '🇮🇳'),
    Language(code: 'ur', name: 'اردو', speechLocale: 'ur-PK', flag: '🇵🇰'),
    Language(code: 'fa', name: 'فارسی', speechLocale: 'fa-IR', flag: '🇮🇷'),
    Language(code: 'id', name: 'Bahasa Indonesia', speechLocale: 'id-ID', flag: '🇮🇩'),
    Language(code: 'ms', name: 'Bahasa Melayu', speechLocale: 'ms-MY', flag: '🇲🇾'),
    Language(code: 'th', name: 'ภาษาไทย', speechLocale: 'th-TH', flag: '🇹🇭'),
    Language(code: 'vi', name: 'Tiếng Việt', speechLocale: 'vi-VN', flag: '🇻🇳'),
    Language(code: 'nl', name: 'Nederlands', speechLocale: 'nl-NL', flag: '🇳🇱'),
  ];

  static Language fromCode(String code) {
    return all.firstWhere(
      (l) => l.code == code,
      orElse: () => all.first,
    );
  }
}

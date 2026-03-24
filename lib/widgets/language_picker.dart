import 'package:flutter/material.dart';
import '../services/translation_service.dart';

class LanguagePicker extends StatelessWidget {
  final String selectedLang;
  final ValueChanged<String> onChanged;
  final String? label;
  final bool compact;

  const LanguagePicker({
    super.key,
    required this.selectedLang,
    required this.onChanged,
    this.label,
    this.compact = false,
  });

  static const Map<String, String> _flags = {
    'ar': '🇸🇦', 'en': '🇺🇸', 'fr': '🇫🇷', 'es': '🇪🇸',
    'de': '🇩🇪', 'tr': '🇹🇷', 'zh': '🇨🇳', 'ja': '🇯🇵',
    'ko': '🇰🇷', 'ru': '🇷🇺', 'pt': '🇧🇷', 'it': '🇮🇹',
    'hi': '🇮🇳', 'ur': '🇵🇰', 'fa': '🇮🇷', 'id': '🇮🇩',
    'ms': '🇲🇾', 'th': '🇹🇭', 'vi': '🇻🇳', 'nl': '🇳🇱',
  };

  @override
  Widget build(BuildContext context) {
    final langs = TranslationService.supportedLanguages;

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<String>(
          value: selectedLang,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1A2E),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          underline: const SizedBox(),
          items: langs.entries.map((e) => DropdownMenuItem(
            value: e.key,
            child: Text('${_flags[e.key] ?? ''} ${e.value}', overflow: TextOverflow.ellipsis),
          )).toList(),
          onChanged: (v) => onChanged(v ?? selectedLang),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showLanguageSheet(context),
      child: Column(
        children: [
          if (label != null) Text(label!, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 4),
          Text(_flags[selectedLang] ?? '🌐', style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 2),
          Text(
            langs[selectedLang] ?? selectedLang,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    final langs = TranslationService.supportedLanguages;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text('اختر اللغة', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: langs.length,
                  itemBuilder: (ctx, i) {
                    final entry = langs.entries.elementAt(i);
                    final isSelected = entry.key == selectedLang;
                    return GestureDetector(
                      onTap: () {
                        onChanged(entry.key);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF6C63FF) : Colors.white10,
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected ? null : Border.all(color: Colors.white10),
                        ),
                        child: Center(
                          child: Text(
                            '${_flags[entry.key] ?? ''} ${entry.value}',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

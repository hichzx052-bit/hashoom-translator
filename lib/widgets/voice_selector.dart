import 'package:flutter/material.dart';
import '../services/tts_service.dart';

class VoiceSelector extends StatefulWidget {
  const VoiceSelector({super.key});
  @override
  State<VoiceSelector> createState() => _VoiceSelectorState();
}

class _VoiceSelectorState extends State<VoiceSelector> {
  final TtsService _ttsService = TtsService();
  List<dynamic> _voices = [];
  String? _selectedVoice;

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    await _ttsService.initialize();
    setState(() {
      _voices = _ttsService.voices;
      _selectedVoice = _ttsService.currentVoice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎙 اختر الصوت', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          if (_voices.isEmpty)
            const Text('جاري التحميل...', style: TextStyle(color: Colors.white38))
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: _selectedVoice,
                isExpanded: true,
                dropdownColor: const Color(0xFF1A1A2E),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                underline: const SizedBox(),
                hint: const Text('اختر صوت', style: TextStyle(color: Colors.white38)),
                items: _voices.take(20).map<DropdownMenuItem<String>>((voice) {
                  final name = voice['name']?.toString() ?? 'Unknown';
                  final locale = voice['locale']?.toString() ?? '';
                  return DropdownMenuItem(
                    value: name,
                    child: Text('$name ($locale)', overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedVoice = value);
                    _ttsService.setVoice(value);
                    // Preview the voice
                    _ttsService.speak('مرحباً، أنا هشوم', 'ar');
                  }
                },
              ),
            ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _ttsService.speak('هشوم ترجمة، جاهز للخدمة!', 'ar'),
            icon: const Icon(Icons.play_arrow, size: 18, color: Color(0xFF6C63FF)),
            label: const Text('جرّب الصوت', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

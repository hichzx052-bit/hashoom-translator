import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../widgets/voice_selector.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TtsService _ttsService = TtsService();
  double _speechRate = 0.5;
  double _pitch = 1.0;
  String? _selectedVoice;
  bool _autoSpeak = true;
  bool _vibrate = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load from SharedPreferences
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A1A),
        title: const Text('⚙️ الإعدادات', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Voice settings
          _buildSection('🔊 إعدادات الصوت', [
            _buildSlider('سرعة الكلام', _speechRate, 0.1, 1.0, (v) {
              setState(() => _speechRate = v);
              _ttsService.setRate(v);
            }),
            _buildSlider('طبقة الصوت', _pitch, 0.5, 2.0, (v) {
              setState(() => _pitch = v);
              _ttsService.setPitch(v);
            }),
            const VoiceSelector(),
          ]),
          const SizedBox(height: 16),

          // Behavior settings
          _buildSection('🎯 السلوك', [
            _buildSwitch('نطق الترجمة تلقائياً', _autoSpeak, (v) {
              setState(() => _autoSpeak = v);
            }),
            _buildSwitch('اهتزاز عند الترجمة', _vibrate, (v) {
              setState(() => _vibrate = v);
            }),
          ]),
          const SizedBox(height: 16),

          // About
          _buildSection('📱 عن التطبيق', [
            const ListTile(
              leading: Text('🪶', style: TextStyle(fontSize: 24)),
              title: Text('هشوم ترجمة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text('الإصدار 2.0.0', style: TextStyle(color: Colors.white54)),
            ),
            ListTile(
              leading: const Icon(Icons.code, color: Color(0xFF6C63FF)),
              title: const Text('وضع المطور', style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white54),
              onTap: () => Navigator.pushNamed(context, '/developer'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title, style: const TextStyle(
              color: Color(0xFF6C63FF), fontSize: 16, fontWeight: FontWeight.bold,
            )),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: const Color(0xFF6C63FF),
            inactiveColor: Colors.white12,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(color: Colors.white70)),
      value: value,
      activeColor: const Color(0xFF6C63FF),
      onChanged: onChanged,
    );
  }
}

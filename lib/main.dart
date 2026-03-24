import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/developer_screen.dart';
import 'services/translation_service.dart';
import 'services/speech_service.dart';
import 'services/tts_service.dart';
import 'services/overlay_service.dart';
import 'services/update_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const HashoomTranslatorApp());
}

// Overlay entry point - when floating button is tapped
@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OverlayWidget(),
  ));
}

class OverlayWidget extends StatefulWidget {
  const OverlayWidget({super.key});
  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  bool _expanded = false;
  String _myLang = 'ar';
  String _theirLang = 'en';
  bool _listening = false;

  @override
  Widget build(BuildContext context) {
    if (!_expanded) {
      return GestureDetector(
        onTap: () => setState(() => _expanded = true),
        child: Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF3F3D9E)],
            ),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: const Center(
            child: Text('🪶', style: TextStyle(fontSize: 28)),
          ),
        ),
      );
    }

    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 15)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('🪶 هشوم', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => setState(() => _expanded = false),
                child: const Icon(Icons.close, color: Colors.white54, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // My Language
          _buildLangRow('🗣 لغتي:', _myLang, (v) => setState(() => _myLang = v!)),
          const SizedBox(height: 8),
          // Their Language
          _buildLangRow('👤 لغته:', _theirLang, (v) => setState(() => _theirLang = v!)),
          const SizedBox(height: 12),
          // Listen button
          ElevatedButton.icon(
            onPressed: () => setState(() => _listening = !_listening),
            icon: Icon(_listening ? Icons.stop : Icons.mic, size: 20),
            label: Text(_listening ? 'إيقاف' : 'ترجم الآن', style: const TextStyle(fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _listening ? Colors.red : const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 42),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangRow(String label, String value, ValueChanged<String?> onChanged) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A1A2E),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'fr', child: Text('Français')),
                DropdownMenuItem(value: 'es', child: Text('Español')),
                DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                DropdownMenuItem(value: 'zh', child: Text('中文')),
                DropdownMenuItem(value: 'ja', child: Text('日本語')),
                DropdownMenuItem(value: 'ko', child: Text('한국어')),
                DropdownMenuItem(value: 'ru', child: Text('Русский')),
                DropdownMenuItem(value: 'pt', child: Text('Português')),
                DropdownMenuItem(value: 'it', child: Text('Italiano')),
                DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
                DropdownMenuItem(value: 'ur', child: Text('اردو')),
                DropdownMenuItem(value: 'fa', child: Text('فارسی')),
                DropdownMenuItem(value: 'id', child: Text('Indonesia')),
                DropdownMenuItem(value: 'ms', child: Text('Malay')),
                DropdownMenuItem(value: 'th', child: Text('ไทย')),
                DropdownMenuItem(value: 'vi', child: Text('Tiếng Việt')),
                DropdownMenuItem(value: 'nl', child: Text('Nederlands')),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class HashoomTranslatorApp extends StatelessWidget {
  const HashoomTranslatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'هشوم ترجمة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFF0A0A1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF00D9FF),
          surface: Color(0xFF1A1A2E),
        ),
        fontFamily: 'Cairo',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/settings': (ctx) => const SettingsScreen(),
        '/developer': (ctx) => const DeveloperScreen(),
      },
    );
  }
}

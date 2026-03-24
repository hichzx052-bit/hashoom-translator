import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/translation_service.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../services/overlay_service.dart';
import '../services/update_service.dart';
import '../widgets/language_picker.dart';
import '../widgets/voice_selector.dart';
import '../widgets/wave_animation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TranslationService _translationService = TranslationService();
  final SpeechService _speechService = SpeechService();
  final TtsService _ttsService = TtsService();
  final UpdateService _updateService = UpdateService();

  final TextEditingController _textController = TextEditingController();

  String _sourceLang = 'ar';
  String _targetLang = 'en';
  String _recognizedText = '';
  String _translatedText = '';
  String _detectedLang = '';
  bool _isListening = false;
  bool _isTranslating = false;
  bool _isBidirectional = false; // Mode: bidirectional translation
  String _theirLang = 'en'; // The other person's language
  bool _backgroundMode = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _speechService.initialize();
    _ttsService.initialize();
    _checkForUpdates();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _checkForUpdates() async {
    final hasUpdate = await _updateService.checkForUpdate();
    if (hasUpdate && mounted) {
      _showUpdateDialog();
    }
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🪶', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('تحديث جديد!', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'نسخة جديدة متوفرة: ${_updateService.latestVersion}\nتبي تحدّث؟',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('لاحقاً', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateService.downloadAndInstall();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
            child: const Text('حدّث الآن', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
      _recognizedText = '';
    });
    
    await _speechService.startListening(
      language: _sourceLang,
      onResult: (text, isFinal) {
        setState(() {
          _recognizedText = text;
        });
        if (isFinal) {
          _translateText(text);
        }
      },
      onLanguageDetected: (lang) {
        setState(() => _detectedLang = lang);
      },
    );
  }

  Future<void> _stopListening() async {
    await _speechService.stopListening();
    setState(() => _isListening = false);
  }

  Future<void> _translateText(String text) async {
    if (text.isEmpty) return;
    setState(() => _isTranslating = true);

    try {
      final result = await _translationService.translate(
        text: text,
        from: _sourceLang,
        to: _targetLang,
      );
      setState(() {
        _translatedText = result.translatedText;
        if (result.detectedLanguage.isNotEmpty) {
          _detectedLang = result.detectedLanguage;
        }
        _isTranslating = false;
      });

      // Auto-speak the translation
      await _ttsService.speak(_translatedText, _targetLang);
    } catch (e) {
      setState(() {
        _translatedText = 'خطأ في الترجمة: $e';
        _isTranslating = false;
      });
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _startBackgroundMode() async {
    final granted = await OverlayService.requestPermission();
    if (granted) {
      await OverlayService.showOverlay();
      setState(() => _backgroundMode = true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يحتاج صلاحية العرض فوق التطبيقات')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: const Color(0xFF0A0A1A),
              title: Row(
                children: [
                  const Text('🪶', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 8),
                  const Text('هشوم ترجمة',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  // Background mode button
                  IconButton(
                    onPressed: _startBackgroundMode,
                    icon: const Icon(Icons.picture_in_picture_alt, color: Color(0xFF00D9FF)),
                    tooltip: 'تشغيل في الخلفية',
                  ),
                  // Settings
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                    icon: const Icon(Icons.settings, color: Colors.white54),
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Mode toggle
                    _buildModeToggle(),
                    const SizedBox(height: 16),

                    // Language selectors
                    _buildLanguageBar(),
                    const SizedBox(height: 20),

                    // Main mic button
                    _buildMicButton(),
                    const SizedBox(height: 20),

                    // Recognized text
                    if (_recognizedText.isNotEmpty) _buildTextCard(
                      title: _detectedLang.isNotEmpty 
                          ? '🎤 الكلام المسموع ($_detectedLang)'
                          : '🎤 الكلام المسموع',
                      text: _recognizedText,
                      color: const Color(0xFF1A1A2E),
                    ),
                    const SizedBox(height: 12),

                    // Translated text
                    if (_translatedText.isNotEmpty) _buildTextCard(
                      title: '🌍 الترجمة',
                      text: _translatedText,
                      color: const Color(0xFF162447),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _translatedText));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم النسخ ✅')),
                            );
                          },
                          icon: const Icon(Icons.copy, color: Colors.white54, size: 20),
                        ),
                        IconButton(
                          onPressed: () => _ttsService.speak(_translatedText, _targetLang),
                          icon: const Icon(Icons.volume_up, color: Color(0xFF00D9FF), size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Text input for manual translation
                    _buildTextInput(),
                    const SizedBox(height: 16),

                    // Bidirectional mode panel
                    if (_isBidirectional) _buildBidirectionalPanel(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _modeButton('🎤 عادي', !_isBidirectional, () {
            setState(() => _isBidirectional = false);
          })),
          Expanded(child: _modeButton('🔄 ثنائي', _isBidirectional, () {
            setState(() => _isBidirectional = true);
          })),
        ],
      ),
    );
  }

  Widget _modeButton(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF6C63FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(label, style: TextStyle(
            color: active ? Colors.white : Colors.white54,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          )),
        ),
      ),
    );
  }

  Widget _buildLanguageBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: LanguagePicker(
              selectedLang: _sourceLang,
              onChanged: (lang) => setState(() => _sourceLang = lang),
              label: 'من',
            ),
          ),
          GestureDetector(
            onTap: _swapLanguages,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.swap_horiz, color: Color(0xFF6C63FF), size: 24),
            ),
          ),
          Expanded(
            child: LanguagePicker(
              selectedLang: _targetLang,
              onChanged: (lang) => setState(() => _targetLang = lang),
              label: 'إلى',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _isListening ? _stopListening : _startListening,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = _isListening ? 1.0 + (_pulseController.value * 0.15) : 1.0;
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isListening
                      ? [Colors.red, Colors.redAccent]
                      : [const Color(0xFF6C63FF), const Color(0xFF3F3D9E)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? Colors.red : const Color(0xFF6C63FF)).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 42,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextCard({
    required String title,
    required String text,
    required Color color,
    List<Widget>? actions,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(
                  color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold,
                )),
              ),
              if (actions != null) ...actions,
            ],
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(
            color: Colors.white, fontSize: 18, height: 1.5,
          )),
        ],
      ),
    );
  }

  Widget _buildTextInput() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'اكتب نص للترجمة...',
                hintStyle: TextStyle(color: Colors.white30),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: 3,
              minLines: 1,
            ),
          ),
          IconButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                _translateText(_textController.text);
              }
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF6C63FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidirectionalPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF162447), Color(0xFF1A1A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00D9FF).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text('🔄 وضع المحادثة الثنائية',
            style: TextStyle(color: Color(0xFF00D9FF), fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'أنت تتكلم بلغتك → الطرف الثاني يسمع بلغته\nوالعكس صحيح!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('🗣 لغتي', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    LanguagePicker(
                      selectedLang: _sourceLang,
                      onChanged: (lang) => setState(() => _sourceLang = lang),
                      compact: true,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.compare_arrows, color: Color(0xFF00D9FF), size: 30),
              Expanded(
                child: Column(
                  children: [
                    const Text('👤 لغته', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    LanguagePicker(
                      selectedLang: _theirLang,
                      onChanged: (lang) => setState(() => _theirLang = lang),
                      compact: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _sourceLang = _sourceLang;
                      _targetLang = _theirLang;
                    });
                    _startListening();
                  },
                  icon: const Icon(Icons.mic, size: 18),
                  label: const Text('أتكلم أنا', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _sourceLang = _theirLang;
                      _targetLang = _sourceLang;
                    });
                    _startListening();
                  },
                  icon: const Icon(Icons.mic, size: 18),
                  label: const Text('يتكلم هو', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D9FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

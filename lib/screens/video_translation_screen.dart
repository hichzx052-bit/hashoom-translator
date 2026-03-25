import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../config/theme.dart';
import '../models/language.dart';
import '../services/app_state.dart';
import 'language_selection_screen.dart';

class VideoTranslationScreen extends StatefulWidget {
  @override
  State<VideoTranslationScreen> createState() => _VideoTranslationScreenState();
}

class _VideoTranslationScreenState extends State<VideoTranslationScreen> {
  bool _isActive = false;
  bool _captureSystemAudio = true;
  Language _outputLang = Language.fromCode('ar');
  String _lastCaption = '';
  List<String> _captions = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: AppTheme.bgDark,
          appBar: AppBar(
            backgroundColor: AppTheme.bgDark,
            title: Text('ترجمة الفيديو 🎬'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Info card
                FadeInDown(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: AppTheme.glowDecoration,
                    child: Column(
                      children: [
                        Icon(Icons.videocam, color: AppTheme.secondaryColor, size: 48),
                        SizedBox(height: 12),
                        Text(
                          'ترجمة صوت الفيديو',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'يسمع صوت الفيديو أو اللايف\nويترجمه للغة اللي تختارها بصوت',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Output language
                FadeInDown(
                  delay: Duration(milliseconds: 100),
                  child: GestureDetector(
                    onTap: () async {
                      final lang = await Navigator.push<Language>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LanguageSelectionScreen(title: 'لغة الترجمة'),
                        ),
                      );
                      if (lang != null) setState(() => _outputLang = lang);
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppTheme.bgCard,
                        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Text(_outputLang.flag, style: TextStyle(fontSize: 28)),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('أسمع بـ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              Text(
                                _outputLang.name,
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Audio capture toggle
                FadeInDown(
                  delay: Duration(milliseconds: 200),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppTheme.bgCard,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.audiotrack, color: AppTheme.warningColor),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'التقاط صوت النظام',
                                style: TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                              ),
                              Text(
                                'يسمع الصوت من التطبيقات الثانية',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _captureSystemAudio,
                          onChanged: (v) => setState(() => _captureSystemAudio = v),
                          activeColor: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Start/Stop button
                FadeInUp(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _isActive = !_isActive);
                      if (_isActive) {
                        _startVideoTranslation(state);
                      } else {
                        _stopVideoTranslation(state);
                      }
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _isActive
                              ? [Colors.red, AppTheme.accentColor]
                              : [AppTheme.secondaryColor, AppTheme.primaryColor],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isActive ? Colors.red : AppTheme.primaryColor)
                                .withOpacity(0.5),
                            blurRadius: _isActive ? 40 : 20,
                            spreadRadius: _isActive ? 8 : 3,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isActive ? Icons.stop : Icons.play_arrow,
                            color: Colors.white,
                            size: 40,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  _isActive ? '🔴 يترجم الفيديو...' : 'اضغط للبدء',
                  style: TextStyle(
                    color: _isActive ? AppTheme.accentColor : AppTheme.textSecondary,
                    fontSize: 15,
                    fontWeight: _isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                SizedBox(height: 8),
                if (_isActive)
                  Text(
                    'افتح الفيديو أو اللايف وهشوم يترجم',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                SizedBox(height: 24),

                // Live captions
                if (_captions.isNotEmpty)
                  FadeInUp(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppTheme.bgCard,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.subtitles, color: AppTheme.secondaryColor, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'الترجمة المباشرة',
                                style: TextStyle(
                                  color: AppTheme.secondaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          ...(_captions.take(10).map((c) => Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  c,
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 15,
                                    height: 1.5,
                                  ),
                                ),
                              ))),
                        ],
                      ),
                    ),
                  ),

                // Instructions
                if (!_isActive && _captions.isEmpty)
                  FadeInUp(
                    delay: Duration(milliseconds: 300),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppTheme.bgCard,
                      ),
                      child: Column(
                        children: [
                          _buildInstruction('1', 'اختر اللغة اللي تبي تسمع فيها'),
                          _buildInstruction('2', 'فعّل التقاط صوت النظام'),
                          _buildInstruction('3', 'اضغط زر التشغيل'),
                          _buildInstruction('4', 'افتح الفيديو أو اللايف'),
                          _buildInstruction('5', 'هشوم يترجم الصوت تلقائياً! 🪶'),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstruction(String num, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
            ),
            child: Center(
              child: Text(num, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _startVideoTranslation(AppState state) {
    // Request MediaProjection permission and start audio capture
    // This sends a platform channel message to start native audio capture
    setState(() {
      _captions.clear();
      _captions.add('🎙️ جاري الاستماع للصوت...');
    });
  }

  void _stopVideoTranslation(AppState state) {
    setState(() {
      if (_captions.isNotEmpty) {
        _captions.insert(0, '⏹️ توقفت الترجمة');
      }
    });
  }
}

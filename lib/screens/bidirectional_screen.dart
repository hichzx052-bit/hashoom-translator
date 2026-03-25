import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../config/theme.dart';
import '../models/language.dart';
import '../services/app_state.dart';
import 'language_selection_screen.dart';

class BidirectionalScreen extends StatefulWidget {
  @override
  State<BidirectionalScreen> createState() => _BidirectionalScreenState();
}

class _BidirectionalScreenState extends State<BidirectionalScreen> {
  Language _myLang = Language.fromCode('ar');
  Language _theirLang = Language.fromCode('en');
  bool _isMyTurn = true;
  String _lastTranslation = '';
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              FadeInDown(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: AppTheme.glowDecoration,
                  child: Column(
                    children: [
                      Icon(Icons.people, color: AppTheme.primaryColor, size: 40),
                      SizedBox(height: 8),
                      Text(
                        'محادثة ثنائية',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'كل واحد يتكلم بلغته والثاني يسمع بلغته',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Language pair selector
              FadeInDown(
                delay: Duration(milliseconds: 100),
                child: Row(
                  children: [
                    // My language
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final lang = await Navigator.push<Language>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LanguageSelectionScreen(title: 'لغتي'),
                            ),
                          );
                          if (lang != null) setState(() => _myLang = lang);
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: _isMyTurn
                                ? AppTheme.primaryColor.withOpacity(0.2)
                                : AppTheme.bgCard,
                            border: _isMyTurn
                                ? Border.all(color: AppTheme.primaryColor)
                                : null,
                          ),
                          child: Column(
                            children: [
                              Text('أنا 🗣️', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              SizedBox(height: 4),
                              Text(_myLang.flag, style: TextStyle(fontSize: 32)),
                              SizedBox(height: 4),
                              Text(
                                _myLang.name,
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.compare_arrows, color: AppTheme.secondaryColor, size: 32),
                    ),
                    // Their language
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final lang = await Navigator.push<Language>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LanguageSelectionScreen(title: 'لغته'),
                            ),
                          );
                          if (lang != null) setState(() => _theirLang = lang);
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: !_isMyTurn
                                ? AppTheme.secondaryColor.withOpacity(0.2)
                                : AppTheme.bgCard,
                            border: !_isMyTurn
                                ? Border.all(color: AppTheme.secondaryColor)
                                : null,
                          ),
                          child: Column(
                            children: [
                              Text('هو 👤', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              SizedBox(height: 4),
                              Text(_theirLang.flag, style: TextStyle(fontSize: 32)),
                              SizedBox(height: 4),
                              Text(
                                _theirLang.name,
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Turn toggle
              FadeInUp(
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() => _isMyTurn = true),
                        icon: Icon(Icons.person),
                        label: Text('دوري أنا'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isMyTurn ? AppTheme.primaryColor : AppTheme.bgCardLight,
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() => _isMyTurn = false),
                        icon: Icon(Icons.person_outline),
                        label: Text('دوره هو'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !_isMyTurn ? AppTheme.secondaryColor : AppTheme.bgCardLight,
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Big mic button
              FadeInUp(
                delay: Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: () async {
                    if (_isActive) {
                      await state.stopListening();
                      setState(() => _isActive = false);
                    } else {
                      setState(() => _isActive = true);
                      String locale = _isMyTurn ? _myLang.speechLocale : _theirLang.speechLocale;
                      await state.speechService.initialize();
                      await state.speechService.startListening(
                        localeId: locale,
                        onResult: (result) async {
                          if (result.finalResult) {
                            final translated = await state.translateBidirectional(
                              text: result.recognizedWords,
                              myLang: _myLang.code,
                              theirLang: _theirLang.code,
                              isMySpeech: _isMyTurn,
                            );
                            setState(() {
                              _lastTranslation = translated;
                              _isActive = false;
                            });
                            // Speak in target language
                            String targetLocale = _isMyTurn ? _theirLang.speechLocale : _myLang.speechLocale;
                            await state.ttsService.speak(translated, language: targetLocale);
                          }
                        },
                      );
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
                            : _isMyTurn
                                ? [AppTheme.primaryColor, AppTheme.secondaryColor]
                                : [AppTheme.secondaryColor, AppTheme.successColor],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isActive ? Colors.red : AppTheme.primaryColor).withOpacity(0.5),
                          blurRadius: _isActive ? 40 : 20,
                          spreadRadius: _isActive ? 8 : 3,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isActive ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              Text(
                _isActive ? 'يسمع...' : (_isMyTurn ? 'اضغط وتكلم بلغتك' : 'اضغط وخله يتكلم بلغته'),
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              SizedBox(height: 20),

              // Translation result
              if (_lastTranslation.isNotEmpty)
                FadeInUp(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.successColor.withOpacity(0.15),
                          AppTheme.primaryColor.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.volume_up, color: AppTheme.successColor),
                        SizedBox(height: 8),
                        Text(
                          _lastTranslation,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 20,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

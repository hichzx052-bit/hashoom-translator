import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../config/theme.dart';
import '../models/language.dart';
import '../services/app_state.dart';
import '../services/overlay_service.dart';
import '../services/background_service.dart';
import 'settings_screen.dart';
import 'voice_selection_screen.dart';
import 'language_selection_screen.dart';
import 'developer_screen.dart';
import 'bidirectional_screen.dart';
import 'video_translation_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late AnimationController _pulseController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: AppTheme.bgDark,
          appBar: _buildAppBar(state),
          body: _buildBody(state),
          bottomNavigationBar: _buildBottomNav(),
          floatingActionButton: _buildFAB(state),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(AppState state) {
    return AppBar(
      backgroundColor: AppTheme.bgDark,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🪶', style: TextStyle(fontSize: 24)),
          SizedBox(width: 8),
          Text(
            'هشوم ترجمة',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        if (state.backgroundMode)
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.circle, color: AppTheme.successColor, size: 12),
          ),
        IconButton(
          icon: Icon(Icons.settings, color: AppTheme.textSecondary),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SettingsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(AppState state) {
    switch (_currentTab) {
      case 0:
        return _buildTranslateTab(state);
      case 1:
        return _buildBidirectionalTab(state);
      case 2:
        return _buildHistoryTab(state);
      default:
        return _buildTranslateTab(state);
    }
  }

  Widget _buildTranslateTab(AppState state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Language selector
          FadeInDown(
            child: _buildLanguageSelector(state),
          ),
          SizedBox(height: 16),

          // Voice selector
          FadeInDown(
            delay: Duration(milliseconds: 100),
            child: _buildVoiceSelector(state),
          ),
          SizedBox(height: 16),

          // Text input
          FadeInDown(
            delay: Duration(milliseconds: 200),
            child: _buildTextInput(state),
          ),
          SizedBox(height: 16),

          // Mic button
          FadeInUp(
            delay: Duration(milliseconds: 300),
            child: _buildMicButton(state),
          ),
          SizedBox(height: 16),

          // Result card
          if (state.translatedText.isNotEmpty)
            FadeInUp(
              child: _buildResultCard(state),
            ),

          // Detected language
          if (state.detectedLanguage.isNotEmpty && state.autoDetect)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'اللغة المكتشفة: ${Language.fromCode(state.detectedLanguage).name} ${Language.fromCode(state.detectedLanguage).flag}',
                style: TextStyle(color: AppTheme.secondaryColor, fontSize: 14),
              ),
            ),

          SizedBox(height: 16),

          // Background mode toggle
          FadeInUp(
            delay: Duration(milliseconds: 400),
            child: _buildBackgroundToggle(state),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(AppState state) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: AppTheme.glowDecoration,
      child: Row(
        children: [
          // Source language
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final lang = await Navigator.push<Language>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LanguageSelectionScreen(
                      title: 'لغة المصدر',
                      showAutoDetect: true,
                    ),
                  ),
                );
                if (lang != null) state.setSourceLanguage(lang);
              },
              child: Column(
                children: [
                  Text(
                    state.autoDetect ? '🔍' : state.sourceLang.flag,
                    style: TextStyle(fontSize: 28),
                  ),
                  SizedBox(height: 4),
                  Text(
                    state.autoDetect ? 'تلقائي' : state.sourceLang.name,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          // Swap button
          GestureDetector(
            onTap: state.autoDetect ? null : () => state.swapLanguages(),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: state.autoDetect
                    ? AppTheme.bgCardLight
                    : AppTheme.primaryColor.withOpacity(0.2),
              ),
              child: Icon(
                Icons.swap_horiz,
                color: state.autoDetect ? AppTheme.textSecondary : AppTheme.primaryColor,
                size: 24,
              ),
            ),
          ),
          // Target language
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final lang = await Navigator.push<Language>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LanguageSelectionScreen(title: 'لغة الترجمة'),
                  ),
                );
                if (lang != null) state.setTargetLanguage(lang);
              },
              child: Column(
                children: [
                  Text(state.targetLang.flag, style: TextStyle(fontSize: 28)),
                  SizedBox(height: 4),
                  Text(
                    state.targetLang.name,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
  }

  Widget _buildVoiceSelector(AppState state) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VoiceSelectionScreen()),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.bgCard,
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.record_voice_over, color: AppTheme.primaryColor),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                state.selectedVoice?.name ?? 'اختر الصوت',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput(AppState state) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.bgCard,
      ),
      child: Column(
        children: [
          TextField(
            controller: _textController,
            maxLines: 4,
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'اكتب النص هنا أو اضغط الميكروفون...',
              hintStyle: TextStyle(color: AppTheme.textSecondary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            onChanged: (text) {
              if (text.length > 2) {
                state.translateText(text);
              }
            },
          ),
          // Live text from speech
          if (state.isListening && state.currentText.isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                '🎙️ ${state.currentText}',
                style: TextStyle(color: AppTheme.secondaryColor, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMicButton(AppState state) {
    final isActive = state.isListening;
    return GestureDetector(
      onTap: () {
        if (isActive) {
          state.stopListening();
          _pulseController.stop();
        } else {
          state.startListening();
          _pulseController.repeat();
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isActive
              ? LinearGradient(colors: [AppTheme.accentColor, Colors.red])
              : AppTheme.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: (isActive ? AppTheme.accentColor : AppTheme.primaryColor)
                  .withOpacity(0.5),
              blurRadius: isActive ? 30 : 15,
              spreadRadius: isActive ? 5 : 2,
            ),
          ],
        ),
        child: Icon(
          isActive ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }

  Widget _buildResultCard(AppState state) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.15),
            AppTheme.secondaryColor.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.translate, color: AppTheme.secondaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                'الترجمة',
                style: TextStyle(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Spacer(),
              // Speak button
              IconButton(
                icon: Icon(
                  state.isSpeaking ? Icons.stop_circle : Icons.volume_up,
                  color: AppTheme.primaryColor,
                ),
                onPressed: () {
                  if (state.isSpeaking) {
                    state.stopSpeaking();
                  } else {
                    state.speakTranslation();
                  }
                },
              ),
              // Copy button
              IconButton(
                icon: Icon(Icons.copy, color: AppTheme.textSecondary, size: 20),
                onPressed: () {
                  // Copy to clipboard
                },
              ),
            ],
          ),
          SizedBox(height: 8),
          SelectableText(
            state.translatedText,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundToggle(AppState state) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.bgCard,
      ),
      child: Column(
        children: [
          // Background service toggle
          Row(
            children: [
              Icon(Icons.speed, color: AppTheme.warningColor),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'تشغيل في الخلفية',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                ),
              ),
              Switch(
                value: state.backgroundMode,
                onChanged: (v) async {
                  state.setBackgroundMode(v);
                  if (v) {
                    await BackgroundTranslationService.startService();
                    await OverlayService.showOverlay();
                    state.setOverlayMode(true);
                  } else {
                    await BackgroundTranslationService.stopService();
                    await OverlayService.closeOverlay();
                    state.setOverlayMode(false);
                  }
                },
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
          if (state.backgroundMode)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '🪶 الزر العائم شغّال — اضغطه للتحكم',
                style: TextStyle(color: AppTheme.successColor, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBidirectionalTab(AppState state) {
    return BidirectionalScreen();
  }

  Widget _buildHistoryTab(AppState state) {
    if (state.history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text(
              'ما في ترجمات بعد',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: state.history.length,
      itemBuilder: (context, index) {
        final item = state.history[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.bgCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (item.isVoice) Icon(Icons.mic, size: 16, color: AppTheme.primaryColor),
                  SizedBox(width: 4),
                  Text(
                    '${Language.fromCode(item.sourceLanguage).flag} → ${Language.fromCode(item.targetLanguage).flag}',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  Spacer(),
                  Text(
                    '${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                item.originalText,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Divider(color: AppTheme.bgCardLight),
              Text(
                item.translatedText,
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (i) => setState(() => _currentTab = i),
        backgroundColor: AppTheme.bgCard,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.translate), label: 'ترجمة'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'ثنائي'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'السجل'),
        ],
      ),
    );
  }

  Widget? _buildFAB(AppState state) {
    return null; // Floating overlay is handled by the system
  }
}

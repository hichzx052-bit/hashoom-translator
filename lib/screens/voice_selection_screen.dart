import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/voice.dart';
import '../services/app_state.dart';

class VoiceSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: AppTheme.bgDark,
          appBar: AppBar(
            backgroundColor: AppTheme.bgDark,
            title: Text('اختر الصوت 🎙️'),
            centerTitle: true,
          ),
          body: state.availableVoices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.voice_over_off, size: 64, color: AppTheme.textSecondary),
                      SizedBox(height: 16),
                      Text(
                        'ما لقيت أصوات لهالغة',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'غيّر لغة الترجمة وجرب مرة ثانية',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: state.availableVoices.length,
                  itemBuilder: (context, index) {
                    final voice = state.availableVoices[index];
                    final isSelected = state.selectedVoice?.id == voice.id;
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? AppTheme.primaryColor.withOpacity(0.2)
                            : AppTheme.bgCard,
                        border: isSelected
                            ? Border.all(color: AppTheme.primaryColor, width: 2)
                            : null,
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: voice.gender == 'female'
                                ? Colors.pink.withOpacity(0.2)
                                : AppTheme.primaryColor.withOpacity(0.2),
                          ),
                          child: Icon(
                            voice.gender == 'female' ? Icons.woman : Icons.man,
                            color: voice.gender == 'female' ? Colors.pink : AppTheme.primaryColor,
                          ),
                        ),
                        title: Text(
                          voice.name,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          voice.gender == 'female' ? 'أنثى' : 'ذكر',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Preview button
                            IconButton(
                              icon: Icon(Icons.play_circle, color: AppTheme.secondaryColor),
                              onPressed: () {
                                state.ttsService.speak(
                                  'مرحباً، أنا صوت هشوم ترجمة',
                                  voice: voice,
                                );
                              },
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: AppTheme.primaryColor),
                          ],
                        ),
                        onTap: () => state.setVoice(voice),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

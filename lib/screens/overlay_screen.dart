import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../config/theme.dart';

/// This is the overlay entry point — runs as a separate isolate
/// Shows the floating Hashoom button 🪶 and control panel
class OverlayScreen extends StatefulWidget {
  @override
  State<OverlayScreen> createState() => _OverlayScreenState();
}

class _OverlayScreenState extends State<OverlayScreen> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _isListening = false;
  String _selectedMode = 'translate'; // translate, bidirectional, video
  String _sourceLang = 'auto';
  String _targetLang = 'ar';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Listen for data from main app
    FlutterOverlayWindow.overlayListener.listen((data) {
      if (data is Map) {
        setState(() {
          if (data.containsKey('sourceLang')) _sourceLang = data['sourceLang'];
          if (data.containsKey('targetLang')) _targetLang = data['targetLang'];
          if (data.containsKey('mode')) _selectedMode = data['mode'];
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_expanded) {
      return _buildFloatingButton();
    }
    return _buildExpandedPanel();
  }

  /// The floating Hashoom button 🪶
  Widget _buildFloatingButton() {
    return GestureDetector(
      onTap: () => setState(() => _expanded = true),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = 1.0 + (_pulseController.value * 0.08);
          return Transform.scale(
            scale: _isListening ? scale : 1.0,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isListening
                      ? [Colors.red, AppTheme.accentColor]
                      : [AppTheme.primaryColor, AppTheme.secondaryColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? Colors.red : AppTheme.primaryColor)
                        .withOpacity(0.6),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '🪶',
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Expanded control panel
  Widget _buildExpandedPanel() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 280,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppTheme.bgDark.withOpacity(0.95),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Text('🪶', style: TextStyle(fontSize: 24)),
                SizedBox(width: 8),
                Text(
                  'هشوم ترجمة',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _expanded = false),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.bgCardLight,
                    ),
                    child: Icon(Icons.close, color: AppTheme.textSecondary, size: 18),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Mode selector
            Row(
              children: [
                _buildModeButton('translate', Icons.translate, 'ترجمة'),
                SizedBox(width: 8),
                _buildModeButton('bidirectional', Icons.people, 'ثنائي'),
                SizedBox(width: 8),
                _buildModeButton('video', Icons.videocam, 'فيديو'),
              ],
            ),
            SizedBox(height: 16),

            // Language display
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppTheme.bgCard,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _sourceLang == 'auto' ? '🔍 تلقائي' : _sourceLang.toUpperCase(),
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward, color: AppTheme.secondaryColor, size: 16),
                  ),
                  Text(
                    _targetLang.toUpperCase(),
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Big action button
            GestureDetector(
              onTap: () {
                setState(() => _isListening = !_isListening);
                if (_isListening) {
                  // Send start command to main app
                  FlutterOverlayWindow.shareData({
                    'action': 'startListening',
                    'mode': _selectedMode,
                    'sourceLang': _sourceLang,
                    'targetLang': _targetLang,
                  });
                } else {
                  FlutterOverlayWindow.shareData({
                    'action': 'stopListening',
                  });
                }
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _isListening
                        ? [Colors.red, AppTheme.accentColor]
                        : [AppTheme.primaryColor, AppTheme.secondaryColor],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? Colors.red : AppTheme.primaryColor)
                          .withOpacity(0.5),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              _isListening ? '🔴 يسمع...' : 'اضغط للترجمة',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            SizedBox(height: 12),

            // Quick actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(Icons.swap_horiz, 'عكس', () {
                  FlutterOverlayWindow.shareData({'action': 'swapLangs'});
                }),
                _buildQuickAction(Icons.voice_over_off, 'صوت', () {
                  FlutterOverlayWindow.shareData({'action': 'changeVoice'});
                }),
                _buildQuickAction(Icons.close, 'إغلاق', () async {
                  FlutterOverlayWindow.shareData({'action': 'stopService'});
                  await FlutterOverlayWindow.closeOverlay();
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String mode, IconData icon, String label) {
    final isActive = _selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMode = mode),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isActive ? AppTheme.primaryColor.withOpacity(0.3) : AppTheme.bgCard,
            border: isActive ? Border.all(color: AppTheme.primaryColor, width: 1) : null,
          ),
          child: Column(
            children: [
              Icon(icon, color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary, size: 20),
              SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.bgCardLight,
            ),
            child: Icon(icon, color: AppTheme.textSecondary, size: 18),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}

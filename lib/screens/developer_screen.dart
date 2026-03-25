import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';
import '../utils/constants.dart';

class DeveloperScreen extends StatefulWidget {
  @override
  State<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends State<DeveloperScreen> {
  String? _apiKey;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKey = prefs.getString(AppConstants.prefApiKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        title: Text('لوحة المطور 🛠️'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // API Key display
          Container(
            padding: EdgeInsets.all(20),
            decoration: AppTheme.glowDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.vpn_key, color: AppTheme.warningColor),
                    SizedBox(width: 8),
                    Text(
                      'API Key',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.bgCardLight,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          _apiKey ?? 'لم يُنشأ بعد',
                          style: TextStyle(
                            color: AppTheme.secondaryColor,
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (_apiKey != null)
                        IconButton(
                          icon: Icon(Icons.copy, color: AppTheme.textSecondary),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _apiKey!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('تم النسخ ✅')),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'استخدم هذا المفتاح في تطبيق التحديثات',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Instructions
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppTheme.bgCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'كيف تستخدم تطبيق التحديثات 📱',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                _buildStep('1', 'افتح تطبيق "هشوم أبديت"'),
                _buildStep('2', 'أدخل API Key من فوق'),
                _buildStep('3', 'اكتب الميزة أو التحديث المطلوب'),
                _buildStep('4', 'اضغط "إرسال التحديث"'),
                _buildStep('5', 'التطبيق الرئيسي يستقبل التحديث تلقائياً'),
              ],
            ),
          ),
          SizedBox(height: 20),

          // App stats
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppTheme.bgCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إحصائيات 📊',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                _buildStat('الإصدار', '2.0.0'),
                _buildStat('المطور', 'Hichamdzz'),
                _buildStat('المحرك', 'Google Translate + TTS'),
                _buildStat('اللغات', '20 لغة'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: AppTheme.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

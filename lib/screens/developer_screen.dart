import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/update_service.dart';

class DeveloperScreen extends StatefulWidget {
  const DeveloperScreen({super.key});
  @override
  State<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends State<DeveloperScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isUnlocked = false;
  bool _isChecking = false;
  int _attempts = 0;
  static const String _secretCode = 'Hichamdzz';

  // Developer features
  String _apiKey = '';
  String _currentVersion = '2.0.0';
  String _updateUrl = '';
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _checkIfUnlocked();
  }

  Future<void> _checkIfUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isUnlocked = prefs.getBool('dev_unlocked') ?? false;
      _apiKey = prefs.getString('api_key') ?? '';
    });
  }

  Future<void> _verifyCode() async {
    setState(() => _isChecking = true);
    await Future.delayed(const Duration(milliseconds: 500));

    if (_codeController.text == _secretCode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dev_unlocked', true);
      setState(() {
        _isUnlocked = true;
        _isChecking = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔓 وضع المطور مفعّل!'),
            backgroundColor: Color(0xFF6C63FF),
          ),
        );
      }
    } else {
      _attempts++;
      setState(() => _isChecking = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ كود خاطئ ($_attempts/3)'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    _codeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A1A),
        title: const Text('🔐 وضع المطور', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isUnlocked ? _buildDeveloperPanel() : _buildLockScreen(),
    );
  }

  Widget _buildLockScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.5), width: 2),
              ),
              child: const Icon(Icons.lock, color: Color(0xFF6C63FF), size: 48),
            ),
            const SizedBox(height: 24),
            const Text('أدخل كود المطور',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('هذا القسم للمطور فقط',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _codeController,
                obscureText: true,
                style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 3),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '• • • • • • •',
                  hintStyle: TextStyle(color: Colors.white24),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                onSubmitted: (_) => _verifyCode(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isChecking ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isChecking
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('فتح', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperPanel() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // API Key
        _buildDevCard('🔑 مفتاح API', [
          Text(_apiKey.isEmpty ? 'لا يوجد مفتاح' : _apiKey.substring(0, 10) + '...',
            style: const TextStyle(color: Colors.white54, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 8),
          const Text('المفتاح يُستخدم من تطبيق التحديثات للتحكم بالميزات',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ]),
        const SizedBox(height: 12),

        // Version info
        _buildDevCard('📦 معلومات الإصدار', [
          _devRow('الإصدار الحالي', _currentVersion),
          _devRow('اسم الحزمة', 'com.hashoom.translator'),
          _devRow('نوع البناء', 'release'),
        ]),
        const SizedBox(height: 12),

        // Update management
        _buildDevCard('🔄 إدارة التحديثات', [
          const Text('التحديثات تأتي من تطبيق التحديثات عبر API Key',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              final updateService = UpdateService();
              final hasUpdate = await updateService.checkForUpdate();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(hasUpdate ? '✅ تحديث متوفر!' : '✅ أنت على آخر إصدار')),
                );
              }
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('تحقق من التحديثات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
            ),
          ),
        ]),
        const SizedBox(height: 12),

        // Feature toggles
        _buildDevCard('⚡ التحكم بالميزات', [
          _featureToggle('الترجمة الصوتية', true),
          _featureToggle('النافذة العائمة', true),
          _featureToggle('الوضع الثنائي', true),
          _featureToggle('ترجمة الفيديو', true),
          _featureToggle('التحديثات التلقائية', true),
        ]),
        const SizedBox(height: 12),

        // Logs
        _buildDevCard('📋 السجلات', [
          if (_logs.isEmpty)
            const Text('لا توجد سجلات بعد', style: TextStyle(color: Colors.white38))
          else
            ..._logs.map((log) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(log, style: const TextStyle(color: Colors.white54, fontFamily: 'monospace', fontSize: 11)),
            )),
        ]),
      ],
    );
  }

  Widget _buildDevCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(
            color: Color(0xFF6C63FF), fontSize: 15, fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _devRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _featureToggle(String name, bool enabled) {
    return SwitchListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(name, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      value: enabled,
      activeColor: const Color(0xFF6C63FF),
      onChanged: (v) {},
    );
  }
}

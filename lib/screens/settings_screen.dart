import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';
import '../config/app_config.dart';
import '../services/app_state.dart';
import '../services/update_service.dart';
import '../utils/constants.dart';
import 'developer_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _devTapCount = 0;
  bool _devMode = false;
  String? _apiKey;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _devMode = prefs.getBool(AppConstants.prefDeveloperMode) ?? false;
      _apiKey = prefs.getString(AppConstants.prefApiKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        title: Text('الإعدادات ⚙️'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // App info
          _buildSection('التطبيق', [
            _buildInfoTile(
              'الإصدار',
              AppConfig.appVersion,
              Icons.info_outline,
              onTap: () {
                _devTapCount++;
                if (_devTapCount >= 7) {
                  _unlockDeveloper();
                }
              },
            ),
            _buildActionTile(
              'التحقق من التحديثات',
              Icons.system_update,
              AppTheme.secondaryColor,
              () => _checkUpdate(),
            ),
          ]),
          SizedBox(height: 16),

          // Translation settings
          _buildSection('الترجمة', [
            Consumer<AppState>(
              builder: (_, state, __) => SwitchListTile(
                title: Text('تعرف تلقائي على اللغة', style: TextStyle(color: AppTheme.textPrimary)),
                subtitle: Text('يكتشف اللغة من كلامك', style: TextStyle(color: AppTheme.textSecondary)),
                value: state.autoDetect,
                onChanged: (v) => state.setAutoDetect(v),
                activeColor: AppTheme.primaryColor,
                secondary: Icon(Icons.auto_fix_high, color: AppTheme.primaryColor),
              ),
            ),
          ]),
          SizedBox(height: 16),

          // API Key
          if (_devMode) ...[
            _buildSection('المطور', [
              _buildInfoTile(
                'API Key',
                _apiKey ?? 'لم يُنشأ بعد',
                Icons.vpn_key,
              ),
              _buildActionTile(
                'إنشاء API Key جديد',
                Icons.refresh,
                AppTheme.warningColor,
                () => _generateApiKey(),
              ),
              _buildActionTile(
                'لوحة المطور',
                Icons.developer_mode,
                AppTheme.accentColor,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => DeveloperScreen())),
              ),
            ]),
            SizedBox(height: 16),
          ],

          // About
          _buildSection('حول', [
            _buildInfoTile('المطور', 'هشام | Hichamdzz', Icons.person),
            _buildInfoTile('هشوم', 'ابن هشام 🪶', Icons.favorite, color: AppTheme.accentColor),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8, right: 4),
          child: Text(
            title,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.bgCard,
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon,
      {VoidCallback? onTap, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.textSecondary),
      title: Text(title, style: TextStyle(color: AppTheme.textPrimary)),
      subtitle: Text(value, style: TextStyle(color: AppTheme.textSecondary)),
      onTap: onTap,
    );
  }

  Widget _buildActionTile(String title, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: AppTheme.textPrimary)),
      trailing: Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: onTap,
    );
  }

  Future<void> _unlockDeveloper() async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: Text('كود المطور 🔐', style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: AppTheme.textPrimary),
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'أدخل كود المطور',
            hintStyle: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('تأكيد'),
          ),
        ],
      ),
    );

    if (result == true && controller.text == AppConfig.developerCode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.prefDeveloperMode, true);
      setState(() {
        _devMode = true;
        _devTapCount = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('وضع المطور مفعّل! 🔓'), backgroundColor: AppTheme.successColor),
      );
    } else if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('كود خاطئ ❌'), backgroundColor: AppTheme.accentColor),
      );
      _devTapCount = 0;
    }
  }

  Future<void> _generateApiKey() async {
    final key = UpdateService.generateApiKey();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefApiKey, key);
    setState(() => _apiKey = key);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('API Key: $key'), backgroundColor: AppTheme.successColor),
    );
  }

  Future<void> _checkUpdate() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('جاري التحقق...'), backgroundColor: AppTheme.primaryColor),
    );

    final update = await UpdateService.checkForUpdate();
    if (update != null) {
      showDialog(
        context: context,
        barrierDismissible: !update.isRequired,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.bgCard,
          title: Text('تحديث متوفر! 🎉', style: TextStyle(color: AppTheme.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الإصدار: ${update.version}', style: TextStyle(color: AppTheme.textPrimary)),
              SizedBox(height: 8),
              if (update.changelog.isNotEmpty)
                Text(update.changelog, style: TextStyle(color: AppTheme.textSecondary)),
              if (update.isRequired)
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    '⚠️ هذا تحديث إجباري',
                    style: TextStyle(color: AppTheme.warningColor, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          actions: [
            if (!update.isRequired)
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('لاحقاً'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                // Open download URL
              },
              child: Text('تحديث الآن'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('أنت على آخر إصدار ✅'), backgroundColor: AppTheme.successColor),
      );
    }
  }
}

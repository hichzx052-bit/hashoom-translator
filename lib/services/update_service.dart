import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String changelog;
  final bool isRequired;

  UpdateInfo({
    required this.version,
    required this.downloadUrl,
    this.changelog = '',
    this.isRequired = false,
  });
}

class UpdateService {
  static const String _updateDataKey = 'pending_update';
  static const String _featuresKey = 'remote_features';

  /// Check for updates from GitHub releases
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final response = await http.get(
        Uri.parse(AppConfig.updateServerUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = (data['tag_name'] ?? '').toString().replaceAll('v', '');
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;

        if (_isNewer(latestVersion, currentVersion)) {
          String downloadUrl = '';
          final assets = data['assets'] as List? ?? [];
          for (var asset in assets) {
            if (asset['name'].toString().endsWith('.apk')) {
              downloadUrl = asset['browser_download_url'] ?? '';
              break;
            }
          }

          return UpdateInfo(
            version: latestVersion,
            downloadUrl: downloadUrl,
            changelog: data['body'] ?? '',
            isRequired: (data['body'] ?? '').toString().contains('[REQUIRED]'),
          );
        }
      }
    } catch (e) {
      // Silent fail
    }
    return null;
  }

  /// Check for feature updates pushed from admin app
  static Future<Map<String, dynamic>?> checkFeatureUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_updateDataKey);
      if (data != null) {
        return json.decode(data);
      }
    } catch (e) {
      // Silent fail
    }
    return null;
  }

  /// Save feature update from admin app
  static Future<void> saveFeatureUpdate(Map<String, dynamic> features) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_featuresKey, json.encode(features));
  }

  /// Apply pending update
  static Future<void> applyPendingUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_updateDataKey);
  }

  /// Generate API key for admin app communication
  static String generateApiKey() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${AppConfig.apiKeyPrefix}-$timestamp';
  }

  /// Validate API key
  static bool validateApiKey(String key) {
    return key.startsWith(AppConfig.apiKeyPrefix);
  }

  static bool _isNewer(String latest, String current) {
    try {
      final latestParts = latest.split('.').map(int.parse).toList();
      final currentParts = current.split('.').map(int.parse).toList();
      for (int i = 0; i < 3; i++) {
        final l = i < latestParts.length ? latestParts[i] : 0;
        final c = i < currentParts.length ? currentParts[i] : 0;
        if (l > c) return true;
        if (l < c) return false;
      }
    } catch (e) {
      return false;
    }
    return false;
  }
}

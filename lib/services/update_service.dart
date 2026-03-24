import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateService {
  // GitHub releases API for hashoom-translator
  static const String _repoOwner = 'hichzx052-bit';
  static const String _repoName = 'hashoom-translator';
  static const String _githubApi = 'https://api.github.com/repos';

  String _latestVersion = '';
  String _downloadUrl = '';
  String _releaseNotes = '';

  String get latestVersion => _latestVersion;
  String get releaseNotes => _releaseNotes;

  /// Check for updates from GitHub Releases
  Future<bool> checkForUpdate() async {
    try {
      final uri = Uri.parse('$_githubApi/$_repoOwner/$_repoName/releases/latest');
      final response = await http.get(uri, headers: {
        'Accept': 'application/vnd.github.v3+json',
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _latestVersion = (data['tag_name'] ?? '').replaceAll('v', '');
        _releaseNotes = data['body'] ?? '';

        // Find APK asset
        final assets = data['assets'] as List? ?? [];
        for (final asset in assets) {
          final name = asset['name']?.toString() ?? '';
          if (name.endsWith('.apk')) {
            _downloadUrl = asset['browser_download_url'] ?? '';
            break;
          }
        }

        // Compare versions
        final packageInfo = await PackageInfo.fromPlatform();
        return _isNewerVersion(_latestVersion, packageInfo.version);
      }
    } catch (e) {
      // Check admin panel for updates
      return await _checkAdminPanelUpdate();
    }
    return false;
  }

  /// Check admin panel for remote updates
  Future<bool> _checkAdminPanelUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString('api_key') ?? '';
      if (apiKey.isEmpty) return false;

      // Admin panel update endpoint
      final updateUrl = prefs.getString('update_url') ?? '';
      if (updateUrl.isEmpty) return false;

      final response = await http.get(
        Uri.parse('$updateUrl/api/check-update'),
        headers: {'Authorization': 'Bearer $apiKey'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _latestVersion = data['version'] ?? '';
        _downloadUrl = data['download_url'] ?? '';
        _releaseNotes = data['notes'] ?? '';

        final packageInfo = await PackageInfo.fromPlatform();
        return _isNewerVersion(_latestVersion, packageInfo.version);
      }
    } catch (_) {}
    return false;
  }

  /// Download and install update
  Future<void> downloadAndInstall() async {
    if (_downloadUrl.isEmpty) return;
    final uri = Uri.parse(_downloadUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Compare version strings
  bool _isNewerVersion(String latest, String current) {
    if (latest.isEmpty || current.isEmpty) return false;
    
    final latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      final l = i < latestParts.length ? latestParts[i] : 0;
      final c = i < currentParts.length ? currentParts[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }

  /// Accept update from admin panel push
  Future<void> acceptRemoteUpdate(String version, String url) async {
    _latestVersion = version;
    _downloadUrl = url;
    await downloadAndInstall();
  }
}

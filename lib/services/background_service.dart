import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

class BackgroundTranslationService {
  static final FlutterBackgroundService _service = FlutterBackgroundService();

  static Future<void> initialize() async {
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'hashoom_translator',
        initialNotificationTitle: 'هشوم ترجمة',
        initialNotificationContent: 'يشتغل في الخلفية...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<void> _onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });
      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    // Listen for translation requests from overlay
    service.on('translate').listen((event) async {
      if (event != null) {
        String text = event['text'] ?? '';
        String from = event['from'] ?? 'auto';
        String to = event['to'] ?? 'ar';
        // Translation will be handled by the main isolate
        service.invoke('translationResult', {
          'original': text,
          'from': from,
          'to': to,
        });
      }
    });

    // Periodic heartbeat
    Timer.periodic(Duration(seconds: 5), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          service.setForegroundNotificationInfo(
            title: 'هشوم ترجمة 🪶',
            content: 'يترجم في الخلفية... اضغط الزر العائم للتحكم',
          );
        }
      }
      service.invoke('heartbeat', {'timestamp': DateTime.now().toIso8601String()});
    });
  }

  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    return true;
  }

  static Future<void> startService() async {
    await _service.startService();
  }

  static Future<void> stopService() async {
    _service.invoke('stopService');
  }

  static Stream<Map<String, dynamic>?> on(String method) {
    return _service.on(method);
  }

  static void invoke(String method, [Map<String, dynamic>? args]) {
    _service.invoke(method, args);
  }
}

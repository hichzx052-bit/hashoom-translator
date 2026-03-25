import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  static Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  static Future<bool> requestOverlay() async {
    final status = await Permission.systemAlertWindow.request();
    return status.isGranted;
  }

  static Future<bool> requestNotification() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<Map<String, bool>> requestAll() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.systemAlertWindow,
      Permission.notification,
    ].request();

    return {
      'microphone': statuses[Permission.microphone]?.isGranted ?? false,
      'overlay': statuses[Permission.systemAlertWindow]?.isGranted ?? false,
      'notification': statuses[Permission.notification]?.isGranted ?? false,
    };
  }

  static Future<bool> checkAllGranted() async {
    final mic = await Permission.microphone.isGranted;
    final overlay = await Permission.systemAlertWindow.isGranted;
    return mic && overlay;
  }
}

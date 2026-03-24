import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayService {
  /// Check if overlay permission is granted
  static Future<bool> isPermissionGranted() async {
    return await FlutterOverlayWindow.isPermissionGranted();
  }

  /// Request overlay permission
  static Future<bool> requestPermission() async {
    final granted = await FlutterOverlayWindow.isPermissionGranted();
    if (!granted) {
      await FlutterOverlayWindow.requestPermission();
      return await FlutterOverlayWindow.isPermissionGranted();
    }
    return true;
  }

  /// Show the floating overlay (hashoom button 🪶)
  static Future<void> showOverlay() async {
    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      height: 80,
      width: 80,
      alignment: OverlayAlignment.centerRight,
      positionGravity: PositionGravity.auto,
      flag: OverlayFlag.defaultFlag,
    );
  }

  /// Close overlay
  static Future<void> closeOverlay() async {
    await FlutterOverlayWindow.closeOverlay();
  }

  /// Check if overlay is active
  static Future<bool> isOverlayActive() async {
    return await FlutterOverlayWindow.isActive();
  }

  /// Share data with overlay
  static Future<void> shareData(dynamic data) async {
    await FlutterOverlayWindow.shareData(data);
  }
}

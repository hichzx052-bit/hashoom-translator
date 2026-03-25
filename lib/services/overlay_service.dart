import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayService {
  static bool _isShowing = false;

  static bool get isShowing => _isShowing;

  static Future<bool> checkPermission() async {
    return await FlutterOverlayWindow.isPermissionGranted();
  }

  static Future<void> requestPermission() async {
    await FlutterOverlayWindow.requestPermission();
  }

  static Future<void> showOverlay({
    int height = 200,
    int width = 200,
  }) async {
    if (_isShowing) return;

    final hasPermission = await checkPermission();
    if (!hasPermission) {
      await requestPermission();
      return;
    }

    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      height: height,
      width: width,
      alignment: OverlayAlignment.centerRight,
      positionGravity: PositionGravity.auto,
      flag: OverlayFlag.defaultFlag,
    );
    _isShowing = true;
  }

  static Future<void> closeOverlay() async {
    if (!_isShowing) return;
    await FlutterOverlayWindow.closeOverlay();
    _isShowing = false;
  }

  static Future<bool> isOverlayActive() async {
    return await FlutterOverlayWindow.isActive();
  }

  static Future<void> shareData(Map<String, dynamic> data) async {
    await FlutterOverlayWindow.shareData(data);
  }

  static Stream<dynamic> get overlayListener =>
      FlutterOverlayWindow.overlayListener;
}

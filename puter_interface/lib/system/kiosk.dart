import 'package:window_manager/window_manager.dart';

class KioskManager {
  static bool _initialized = false;
  static bool _fullScreen = false;

  static bool get fullScreen => _fullScreen;

  static Future<void> initialize({bool startFullScreen = true}) async {
    if (_initialized) return;

    await windowManager.ensureInitialized();

    await windowManager.waitUntilReadyToShow(
      WindowOptions(
        fullScreen: startFullScreen,
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
        await windowManager.setFullScreen(startFullScreen);
        _fullScreen = startFullScreen;
      },
    );

    _initialized = true;
  }

  static Future<void> toggleFullScreen() async {
    await setFullScreen(!_fullScreen);
  }

  static Future<void> setFullScreen(bool value) async {
    if (!_initialized) {
      throw Exception("KioskManager not initialized. Call initialize() first.");
    }

    await windowManager.setFullScreen(value);
    _fullScreen = value;
  }

  static Future<void> closeApp() async {
    await windowManager.close();
  }
}
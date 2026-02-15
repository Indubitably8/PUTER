import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

class KioskManager {
  static bool _initialized = false;
  static bool _isFullScreen = false;
  static bool _busy = false;

  static bool get isFullScreen => _isFullScreen;

  static Future<void> init({bool startFullScreen = true}) async {
    if (_initialized) return;
    await windowManager.ensureInitialized();

    await windowManager.waitUntilReadyToShow(
      WindowOptions(fullScreen: startFullScreen),
      () async {
        await windowManager.show();
        await windowManager.focus();
        await windowManager.setFullScreen(startFullScreen);
        _isFullScreen = startFullScreen;
      },
    );

    _initialized = true;
  }

  static Future<void> setFullScreen(bool value) async {
    if (!_initialized) await init(startFullScreen: value);
    if (_busy) return;

    _busy = true;
    try {
      await windowManager.setFullScreen(value);
      _isFullScreen = value;
    } finally {
      _busy = false;
    }
  }

  static Future<void> toggleFullScreen() => setFullScreen(!_isFullScreen);
}

class KioskHotkeys {
  static bool _installed = false;

  static void install() {
    if (_installed) return;
    _installed = true;

    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  static void uninstall() {
    if (!_installed) return;
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _installed = false;
  }

  static bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    if (event.logicalKey == LogicalKeyboardKey.f11) {
      Future(() async => await KioskManager.toggleFullScreen());
      return true;
    }

    return false;
  }
}
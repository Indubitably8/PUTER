import 'dart:math' as math;
import 'dart:ui';

import 'package:puter_interface/extenions.dart';

import '../arduino.dart';

class LightController {
  static const String _deviceId = 'light_controller';

  static const String _cmdCCTSet = "cct.set";
  static const String _cmdRGBWSet = 'rgbw.set';
  static const String _cmdGet = 'get';

  static const double gamma = 2.2;

  static Future<void> setCCTLight({required double t, double v = 1.0}) async {
    t = t.clamp(0, 1);
    v = v.clamp(0, 1);

    final res = await Arduino.send(
      _deviceId,
      _cmdCCTSet,
      data: {
        "w": (t * v).applyGamma(gamma).to8Bit(),
        "c": ((1-t) * v).applyGamma(gamma).to8Bit()
      },
    );

    if (res['ok'] != true) {
      throw Exception(res['error'] ?? '$_cmdCCTSet failed');
    }
  }

  static Future<void> setRGBLight({required Color color, double v = 1.0}) async {
    final double w = math.min(color.r, math.min(color.g, color.b));
    v = v.clamp(0, 1);

    await _setRgbw(
        r: ((color.r-w) * v).applyGamma(gamma).to8Bit(),
        g: ((color.g-w) * v).applyGamma(gamma).to8Bit(),
        b: ((color.b-w) * v).applyGamma(gamma).to8Bit(),
        w: (w * v).applyGamma(gamma).to8Bit());
  }

  static Future<void> _setRgbw({
    required int r,
    required int g,
    required int b,
    required int w,
  }) async {
    final res = await Arduino.send(
      _deviceId,
      _cmdRGBWSet,
      data: {
        'r': r,
        'g': g,
        'b': b,
        'w': w,
      },
    );

    if (res['ok'] != true) {
      throw Exception(res['error'] ?? '$_cmdRGBWSet failed');
    }
  }

  static Future<Map<String, dynamic>> get() {
    return Arduino.request(
      _deviceId,
      _cmdGet,
    );
  }
}

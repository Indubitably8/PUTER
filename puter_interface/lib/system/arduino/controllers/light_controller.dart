import 'dart:math' as math;

import '../arduino.dart';

class LightController {
  static const String _deviceId = 'light_controller';

  static const String _cmdSet = 'rgbw.set';
  static const String _cmdGet = 'rgbw.get';

  static Future<void> setRgbw({
    required int r,
    required int g,
    required int b,
    required int w,
    int channel = 0,
    int? fadeMs,
    double gamma = 1.0,
  }) async {
    final rr = _applyGamma(r, gamma);
    final gg = _applyGamma(g, gamma);
    final bb = _applyGamma(b, gamma);
    final ww = _applyGamma(w, gamma);

    final res = await Arduino.send(
      _deviceId,
      _cmdSet,
      data: {
        'ch': channel,
        'r': rr,
        'g': gg,
        'b': bb,
        'w': ww,
        if (fadeMs != null) 'fadeMs': fadeMs,
      },
    );

    if (res['ok'] != true) {
      throw Exception(res['error'] ?? '$_cmdSet failed');
    }
  }

  static Future<Map<String, dynamic>> get({int channel = 0}) {
    return Arduino.request(
      _deviceId,
      _cmdGet,
      data: {'ch': channel},
    );
  }

  static int _applyGamma(int v, double gamma) {
    final int x = v.clamp(0, 255);
    if (gamma == 1.0) return x;

    final double n = x / 255.0;
    final double corrected = math.pow(n, gamma).toDouble();
    return (corrected * 255.0).round().clamp(0, 255);
  }
}
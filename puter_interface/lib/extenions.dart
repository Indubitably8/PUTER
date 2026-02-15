import 'dart:math' as math;
import 'dart:ui';

extension ColorExtension on Color {
  bool equals(Color? color) {
    if (color == null) return false;
    return a == color.a && r == color.r && g == color.g && b == color.b;
  }
}

extension NumExtension on num {
  int to8Bit() => (255 * clamp(0, 1)).round();

  double applyGamma(double y) {
    final double x = clamp(0.0, 1.0).toDouble();
    if (y == 1.0) return x;
    return math.pow(x, y).toDouble();
  }
}
extension DurationExtension on Duration {
  String formatTime() {
    final minutes = inSeconds ~/ 60;
    final seconds = (inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
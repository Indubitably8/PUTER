import 'dart:ui';

extension ColorExtension on Color {
  bool equals(Color? color) {
    if (color == null) return false;
    return a == color.a && r == color.r && g == color.g && b == color.b;
  }
}

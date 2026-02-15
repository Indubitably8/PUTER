import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:puter_interface/extenions.dart';

class ColorPicker extends StatefulWidget {
  final Color selected;
  final ValueChanged<Color> onChanged;

  const ColorPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  static const double radius = 20;
  static const double spacing = 8;
  static const double padding = 12;

  static const List<Color> palette = [
    // ---- Whites / Warm Whites / Cool Whites ----
    Color(0xFFFFFFFF), Color(0xFFFFF8E1), Color(0xFFFFF3E0), Color(0xFFFFE0B2),
    Color(0xFFFFD180), Color(0xFFFFCCBC), Color(0xFFF1F8FF), Color(0xFFE3F2FD),

    // ---- Reds ----
    Color(0xFFB71C1C), Color(0xFFD32F2F), Color(0xFFFF0000),
    Color(0xFFFF1744), Color(0xFFFF5252), Color(0xFFFF6F60), Color(0xFFFF8A80),

    // ---- Magenta-Red / Hot Pink ----
    Color(0xFF880E4F), Color(0xFFC2185B),
    Color(0xFFFF2D55), Color(0xFFFF4081),

    // ---- Oranges ----
    Color(0xFFE65100), Color(0xFFFF6D00), Color(0xFFFF9100),
    Color(0xFFFFAB40), Color(0xFFFFB74D), Color(0xFFFFCC80),
    Color(0xFFFF7043),

    // ---- Yellows ----
    Color(0xFFF57F17), Color(0xFFFFC107),
    Color(0xFFFFD600), Color(0xFFFFFF00),
    Color(0xFFFFFF8D), Color(0xFFFFF59D),

    // ---- Yellow-Green ----
    Color(0xFFB9F6CA), Color(0xFF69F0AE),

    // ---- Greens ----
    Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF00C853),
    Color(0xFF00E676), Color(0xFF00FF00),

    // ---- Teals ----
    Color(0xFF004D40), Color(0xFF00796B),
    Color(0xFF00BFA5), Color(0xFF1DE9B6),
    Color(0xFF4DB6AC),

    // ---- Cyans ----
    Color(0xFF00FFFF), Color(0xFF00E5FF), Color(0xFF18FFFF),

    // ---- Blues ----
    Color(0xFF0D47A1), Color(0xFF1565C0),
    Color(0xFF2979FF), Color(0xFF448AFF),
    Color(0xFF82B1FF), Color(0xFF90CAF9), Color(0xFFBBDEFB),

    // ---- Indigos ----
    Color(0xFF1A237E), Color(0xFF283593),
    Color(0xFF3D5AFE), Color(0xFF536DFE),

    // ---- Purples ----
    Color(0xFF4A148C), Color(0xFF6A1B9A),
    Color(0xFF9575CD),

    // ---- Violet / Neon Purple ----
    Color(0xFFAA00FF), Color(0xFFD500F9),
    Color(0xFFEA80FC),

    // ---- Pinks ----
    Color(0xFFFF80AB), Color(0xFFF8BBD0),

    // ---- Pastels / Soft Ambience ----
    Color(0xFFFFCDD2), Color(0xFFFFF9C4),
    Color(0xFFC8E6C9), Color(0xFFB2DFDB),
    Color(0xFFD1C4E9), Color(0xFFF3E5F5),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final double hexW = radius * 2;
    final double hexH = radius * 2;

    final double xStep = hexW + spacing;
    final double yStep = hexH * 0.75 + spacing;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), color: colorScheme.surface),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final int cols = ((constraints.maxWidth - padding * 2) / xStep).floor().clamp(1, palette.length);
          final int rows = (palette.length / cols).ceil();

          return SizedBox(
            height: rows * yStep + hexH,
            child: Stack(
              children: [
                for (int i = 0; i < palette.length; i++)
                  _hexAt(
                    context: context,
                    color: palette[i],
                    onTap: () => widget.onChanged(palette[i]),
                    left:
                        padding + (i % cols) * xStep + (((i ~/ cols) % 2) * (xStep / 2)),
                    top: padding + (i ~/ cols) * yStep,
                    size: radius,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _hexAt({
    required BuildContext context,
    required Color color,
    required VoidCallback onTap,
    required double left,
    required double top,
    required double size,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final bool isSelected = widget.selected.equals(color);

    final Color outer = colorScheme.onSurface.withAlpha(243);
    final Color inner = Colors.white.withAlpha(141);

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: size * 2,
          height: size * 2,
          decoration: BoxDecoration(
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withAlpha(115),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: ClipPath(
            clipper: _HexClipper(),
            child: Stack(
              children: [
                Positioned.fill(child: ColoredBox(color: color)),
                if (isSelected) ...[
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _HexOutlinePainter(
                        stroke: math.max(2.0, size * 0.16), // scales with radius
                        color: outer,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _HexOutlinePainter(
                        stroke: math.max(1.2, size * 0.09),
                        color: inner,
                        inset: math.max(2.0, size * 0.12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HexClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    // pointy-top hex
    return Path()
      ..moveTo(w * 0.50, 0)
      ..lineTo(w, h * 0.25)
      ..lineTo(w, h * 0.75)
      ..lineTo(w * 0.50, h)
      ..lineTo(0, h * 0.75)
      ..lineTo(0, h * 0.25)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _HexOutlinePainter extends CustomPainter {
  final double stroke;
  final double inset;
  final Color color;

  const _HexOutlinePainter({
    required this.stroke,
    required this.color,
    this.inset = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final Path p = Path()
      ..moveTo(w * 0.50, inset)
      ..lineTo(w - inset, h * 0.25)
      ..lineTo(w - inset, h * 0.75)
      ..lineTo(w * 0.50, h - inset)
      ..lineTo(inset, h * 0.75)
      ..lineTo(inset, h * 0.25)
      ..close();

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = color;

    canvas.drawPath(p, paint);
  }

  @override
  bool shouldRepaint(covariant _HexOutlinePainter old) {
    return old.stroke != stroke || old.inset != inset || old.color != color;
  }
}

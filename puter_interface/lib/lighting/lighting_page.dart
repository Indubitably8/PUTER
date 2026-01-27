import 'package:flutter/material.dart';
import 'package:puter_interface/lighting/color_picker.dart';

class LightingPage extends StatefulWidget {
  const LightingPage({super.key});

  @override
  State<LightingPage> createState() => _LightingPageState();
}

class _LightingPageState extends State<LightingPage> {
  static const double titleTextSize = 24;
  static const double buttonTextSize = 20;

  static const double sliderHeight = 320;
  static const double sliderWidth = 10;
  static const double sliderThumbRadius = 10;

  double panelBrightness = 0.5;
  double panelWarmth = 0.5;
  double backlightBrightness = 0.5;
  Color backlightColor = const Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.tertiaryContainer,
        centerTitle: true,
        title: Text("Lighting System",
            style: TextStyle(
                fontFamily: "Audiowide",
                color: colorScheme.onSurface,
                fontSize: titleTextSize)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  const Text(
                    "Panels",
                    style: TextStyle(
                        fontFamily: "Quantico",
                        fontWeight: FontWeight.w600,
                        fontSize: titleTextSize),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _verticalSlider(
                        label: "Brightness",
                        value: panelBrightness,
                        gradient: const LinearGradient(
                          colors: [Colors.black, Colors.white],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        onChanged: (v) => setState(() => panelBrightness = v),
                      ),
                      _verticalSlider(
                        label: "Warmth",
                        value: panelWarmth,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFA000), // warm
                            Color(0xFFFFFFFF), // neutral
                            Color(0xFF64B5F6), // cool
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        onChanged: (v) => setState(() => panelWarmth = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const VerticalDivider(thickness: 2, width: 8),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  const Text(
                    "Backlight",
                    style: TextStyle(
                        fontFamily: "Quantico",
                        fontWeight: FontWeight.w600,
                        fontSize: titleTextSize),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 24),
                        _verticalSlider(
                          label: "Brightness",
                          value: backlightBrightness,
                          gradient: const LinearGradient(
                            colors: [Colors.black, Colors.white],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          onChanged: (v) =>
                              setState(() => backlightBrightness = v),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ColorPicker(
                            selected: backlightColor,
                            onChanged: (picked) {
                              setState(() => backlightColor = picked);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _verticalSlider({
    required String label,
    required double value,
    required Gradient gradient,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: sliderHeight,
          child: RotatedBox(
            quarterTurns: -1,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: sliderWidth,
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: sliderThumbRadius,
                ),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                trackShape: GradientTrackShape(gradient),
              ),
              child: Slider(
                value: value,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: "Cousine", fontSize: buttonTextSize, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class GradientTrackShape extends SliderTrackShape {
  final Gradient gradient;
  const GradientTrackShape(this.gradient);

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 4;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      paint,
    );
  }
}

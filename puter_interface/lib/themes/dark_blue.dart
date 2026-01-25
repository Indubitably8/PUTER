import 'package:flutter/material.dart';

ThemeData darkBlue() {
  const blueHint = Color(0xFF4D7CFF); // subtle accent blue
  const bg = Color(0xFF10161E);       // deep near-black
  const bg2 = Color(0xFF0B0F14);       // deeper near-black
  const surface = Color(0xFF101723);  // dark surface with cool tint
  const surface2 = Color(0xFF131C2A); // slightly brighter surface
  const outline = Color(0xFF233044);  // cool outline

  final colorScheme = const ColorScheme.dark().copyWith(
    primary: blueHint,
    secondary: blueHint,
    surface: surface,
    surfaceContainerHighest: surface2,
    primaryContainer: bg,
    secondaryContainer: bg2,
    outline: outline,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: bg,
  );

  return base.copyWith(
    // Typography
    textTheme: base.textTheme.apply(
      bodyColor: Colors.white.withAlpha(235),
      displayColor: Colors.white.withAlpha(235),
    ),

    // App chrome
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: Colors.white.withAlpha(235),
      elevation: 0,
      centerTitle: false,
    ),

    // Cards / surfaces
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: outline.withAlpha(205)),
      ),
    ),

    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: blueHint,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: blueHint,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white.withAlpha(235),
        side: BorderSide(color: outline.withAlpha(230)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),

    // Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface2,
      hintStyle: TextStyle(color: Colors.white.withAlpha(115)),
      labelStyle: TextStyle(color: Colors.white.withAlpha(180)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: outline.withAlpha(230)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: outline.withAlpha(230)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: blueHint, width: 1.3),
      ),
    ),

    // Navigation / icons
    iconTheme: IconThemeData(color: Colors.white.withAlpha(230)),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: bg,
      indicatorColor: blueHint.withAlpha(46),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(color: Colors.white.withAlpha(218), fontSize: 12),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? blueHint : Colors.white.withAlpha(192),
        );
      }),
    ),

    // Sliders (volume/progress)
    sliderTheme: base.sliderTheme.copyWith(
      activeTrackColor: blueHint.withAlpha(245),
      inactiveTrackColor: outline.withAlpha(235),
      thumbColor: blueHint,
      overlayColor: blueHint.withAlpha(20),
      trackHeight: 3.5,
    ),

    // Dividers
    dividerTheme: DividerThemeData(
      color: outline.withAlpha(230),
      thickness: 1,
      space: 1,
    ),

    // Snackbars
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surface2,
      contentTextStyle: TextStyle(color: Colors.white.withAlpha(230)),
      actionTextColor: blueHint,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

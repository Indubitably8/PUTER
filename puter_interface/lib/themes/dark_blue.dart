import 'package:flutter/material.dart';

ThemeData darkBlue() {
  const blueHint = Color(0xFF4D7CFF); // subtle accent blue
  const bg = Color(0xFF0B0F14);       // deep near-black
  const surface = Color(0xFF101723);  // dark surface with cool tint
  const surface2 = Color(0xFF131C2A); // slightly brighter surface
  const outline = Color(0xFF233044);  // cool outline

  final colorScheme = const ColorScheme.dark().copyWith(
    primary: blueHint,
    secondary: blueHint,
    background: bg,
    surface: surface,
    surfaceContainerHighest: surface2,
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
      bodyColor: Colors.white.withOpacity(0.92),
      displayColor: Colors.white.withOpacity(0.92),
    ),

    // App chrome
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: Colors.white.withOpacity(0.92),
      elevation: 0,
      centerTitle: false,
    ),

    // Cards / surfaces
    cardTheme: CardTheme(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: outline.withOpacity(0.8)),
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
        foregroundColor: Colors.white.withOpacity(0.92),
        side: BorderSide(color: outline.withOpacity(0.9)),
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
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.45)),
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: outline.withOpacity(0.9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: outline.withOpacity(0.9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: blueHint, width: 1.3),
      ),
    ),

    // Navigation / icons
    iconTheme: IconThemeData(color: Colors.white.withOpacity(0.9)),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: bg,
      indicatorColor: blueHint.withOpacity(0.18),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? blueHint : Colors.white.withOpacity(0.75),
        );
      }),
    ),

    // Sliders (volume/progress)
    sliderTheme: base.sliderTheme.copyWith(
      activeTrackColor: blueHint.withOpacity(0.95),
      inactiveTrackColor: outline.withOpacity(0.9),
      thumbColor: blueHint,
      overlayColor: blueHint.withOpacity(0.12),
      trackHeight: 3.5,
    ),

    // Dividers
    dividerTheme: DividerThemeData(
      color: outline.withOpacity(0.9),
      thickness: 1,
      space: 1,
    ),

    // Snackbars
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surface2,
      contentTextStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
      actionTextColor: blueHint,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

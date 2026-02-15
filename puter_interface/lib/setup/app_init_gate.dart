import 'dart:async';
import 'package:flutter/material.dart';
import 'package:puter_interface/setup/app_shell.dart';
import 'package:puter_interface/setup/home_page.dart';
import 'package:puter_interface/setup/tree_splash.dart';

class AppInitGate extends StatefulWidget {
  const AppInitGate({super.key, required this.init});
  final Future<void> Function() init;

  @override
  State<AppInitGate> createState() => _AppInitGateState();
}

class _AppInitGateState extends State<AppInitGate>
    with SingleTickerProviderStateMixin {
  static const Duration minSplashTime = Duration(milliseconds: 2500);
  static const double splashEnd = 0.50;
  static const double homeStart = 0.55;
  static const double splashEndSize = 0.0001;

  late final Widget _splash = const TreeSplash();
  late final Widget _home = const HomePage();

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  );

  late final Animation<double> _splashScale =
      Tween<double>(begin: 1.0, end: splashEndSize).animate(
    CurvedAnimation(
      parent: _c,
      curve: const Interval(0.0, splashEnd, curve: Curves.easeInBack),
    ),
  );

  late final Animation<double> _homeScale =
      Tween<double>(begin: 12.0, end: 1.0).animate(
    CurvedAnimation(
      parent: _c,
      curve: const Interval(homeStart, 1.0, curve: Curves.easeOutCubic),
    ),
  );

  static const double _homeFadeStart = homeStart + 0.05;

  late final Animation<double> _homeFade =
      Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: _c,
      curve: const Interval(_homeFadeStart, 1.0, curve: Curves.easeOut),
    ),
  );

  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _runInit();
  }

  Future<void> _runInit() async {
    final sw = Stopwatch()..start();

    try {
      await widget.init();
    } catch (e) {
      debugPrint("Init failed: $e");
    }
    if (!mounted) return;

    final remaining = minSplashTime - sw.elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
    if (!mounted) return;

    setState(() => _ready = true);
    await _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final showSplash = !_ready || _c.value < homeStart;

          final allowHomeInput = _ready && _c.value >= _homeFadeStart;

          return Stack(
            children: [
              if (_ready)
                IgnorePointer(
                  ignoring: !allowHomeInput,
                  child: FadeTransition(
                    opacity: _homeFade,
                    child: Transform.scale(
                      scale: _homeScale.value,
                      alignment: Alignment.center,
                      child: _home,
                    ),
                  ),
                ),
              if (showSplash)
                Transform.scale(
                  scale: _splashScale.value,
                  alignment: Alignment.center,
                  child: _splash,
                ),
            ],
          );
        },
      ),
    );
  }
}

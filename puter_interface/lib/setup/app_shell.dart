import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';
import 'package:puter_interface/system/music/music_player.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WindowListener {
  bool _cleaningUp = false;
  bool _cleanupDone = false;

  Future<void> _cleanupOnce() async {
    if (_cleanupDone || _cleaningUp) return;
    _cleaningUp = true;

    try {
      await MusicPlayer.stopSpotifyd();
    } catch (_) {}

    _cleanupDone = true;
    _cleaningUp = false;
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Future<void> onWindowClose() async {

    if (_cleaningUp) return;

    await _cleanupOnce();

    await windowManager.setPreventClose(false);
    await windowManager.close();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

import 'package:flutter/material.dart';
import 'package:puter_interface/system/command_runner.dart';
import 'package:window_manager/window_manager.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WindowListener {
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    windowManager.setPreventClose(true);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    if (_closing) return;
    _closing = true;

    try {
      CommandRunner.bash("pkill", ["spotifyd"]);
    } catch (_) {}

    await windowManager.setPreventClose(false);
    await windowManager.close();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

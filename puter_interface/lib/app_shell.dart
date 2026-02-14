import 'dart:ui' show AppExitResponse;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:puter_interface/system/kiosk.dart';
import 'package:puter_interface/system/music/music_player.dart';
import 'package:window_manager/window_manager.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  State<AppShell> createState() => _ExitCleanupState();
}

class _ExitCleanupState extends State<AppShell> with WidgetsBindingObserver {
  bool _ran = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    if (!_ran) {
      _ran = true;
      try {
        await MusicPlayer.stopSpotifyd();
      } catch (_) {}
    }
    return AppExitResponse.exit;
  }

  @override
  Widget build(BuildContext context) => Focus(
      autofocus: true,
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.f11) {
              KioskManager.toggleFullScreen();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: widget.child,
    );
}

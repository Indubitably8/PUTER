import 'dart:ui' show AppExitResponse;
import 'package:flutter/widgets.dart';
import 'package:puter_interface/system/command_runner.dart';

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
        await CommandRunner.bash("pkill", ["spotifyd"]);
      } catch (_) {
        // don't trap the user in the app because cleanup failed
      }
    }
    return AppExitResponse.exit;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

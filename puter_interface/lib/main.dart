import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:puter_interface/setup/app_init_gate.dart';
import 'package:puter_interface/system/kiosk.dart';
import 'package:puter_interface/system/music/music_player.dart';
import 'package:puter_interface/setup/themes/dark_blue.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KioskHotkeys.install();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PUTER Interface',
      debugShowCheckedModeBanner: false,
      theme: darkBlue(),
      home: AppInitGate(init: init),
    );
  }
}

Future<void> init() async {
  MusicPlayer.initSpotifyd();

  await initLocalStorage();
  await KioskManager.init();
  await windowManager.setPreventClose(true); // IMPORTANT
}
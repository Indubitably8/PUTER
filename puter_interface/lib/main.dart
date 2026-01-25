import 'package:flutter/material.dart';
import 'package:puter_interface/app_shell.dart';
import 'package:puter_interface/home_page.dart';
import 'package:puter_interface/system/music/music_player.dart';
import 'package:puter_interface/themes/dark_blue.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  MusicPlayer.initSpotifyd();

  await windowManager.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PUTER Interface',
      debugShowCheckedModeBanner: false,
      theme: darkBlue(),
      home: AppShell(child: HomePage()),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:puter_interface/app_shell.dart';
import 'package:puter_interface/home_page.dart';
import 'package:puter_interface/system/kiosk.dart';
import 'package:puter_interface/system/music/music_player.dart';
import 'package:puter_interface/themes/dark_blue.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initLocalStorage();
  await KioskManager.initialize();

  MusicPlayer.initSpotifyd();

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
      home: AppShell(child: HomePage()),
    );
  }
}
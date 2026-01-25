import 'package:flutter/material.dart';
import 'package:puter_interface/home_page.dart';
import 'package:puter_interface/system/music/music_player.dart';
import 'package:puter_interface/music/music_player_ui.dart';
import 'package:puter_interface/themes/dark_blue.dart';

void main() {
  MusicPlayer.initSpotifyd();
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
      home: HomePage(),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:puter_interface/create/create_page.dart';
import 'package:puter_interface/game/game_page.dart';
import 'package:puter_interface/music/music_page.dart';
import 'package:puter_interface/music/music_player_ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _controller = PageController(initialPage: 1);
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        children: [
          MusicPage(),
          CreatePage(),
          GamePage()
        ],
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _bottomBar() {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.secondaryContainer,
      child: Column(
        textDirection: TextDirection.rtl,
        mainAxisSize: MainAxisSize.min,
        children: [
          MusicPlayerUI(),
          Container(color: colorScheme.outline, height: 4, width: mediaQuery.size.width),
          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
            _navIcon(Icons.multitrack_audio, 0),
            _navIcon(Icons.construction, 1),
            _navIcon(Icons.videogame_asset, 2)
          ]))
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return IconButton(
        onPressed: () => _controller.animateToPage(index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut),
        icon: Icon(icon, size: 40, color: colorScheme.onSurface,));
  }
}

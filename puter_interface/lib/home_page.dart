import 'package:flutter/material.dart';
import 'package:puter_interface/create/create_page.dart';
import 'package:puter_interface/game/game_page.dart';
import 'package:puter_interface/landing/landing_page.dart';
import 'package:puter_interface/lighting/lighting_page.dart';
import 'package:puter_interface/music/music_page.dart';
import 'package:puter_interface/music/music_player_ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  static const double iconSize = 40;
  static const double navBarPadding = 12;

  final PageController _controller = PageController(initialPage: 2);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: PageView(
        controller: _controller,
        children: [
          MusicPage(),
          LightingPage(),
          LandingPage(),
          CreatePage(),
          GamePage()
        ],
      ),
      backgroundColor: colorScheme.primaryContainer,
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _bottomBar() {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.secondaryContainer,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MusicPlayerUI(),
          Container(
            color: colorScheme.outline,
            height: 4,
            width: mediaQuery.size.width,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: navBarPadding),
            child: SizedBox(
              height: iconSize + navBarPadding * 2,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const int itemCount = 5;
                  final double slotW = constraints.maxWidth / itemCount;

                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {

                      final ColorScheme cs = Theme.of(context).colorScheme;

                      final double p = _controller.hasClients
                          ? (_controller.page ??
                          _controller.initialPage.toDouble())
                          : _controller.initialPage.toDouble();

                      final double glowW =
                          iconSize + navBarPadding * 2;

                      final double left =
                          (p * slotW) + (slotW - glowW) / 2;

                      return Stack(
                        alignment: Alignment.center,
                        children: [

                          // === GLOW ===
                          Positioned(
                            left: left,
                            child: IgnorePointer(
                              child: Container(
                                width: glowW,
                                height: iconSize + navBarPadding,
                                decoration: BoxDecoration(
                                  color: cs.primary.withAlpha(46),
                                  borderRadius:
                                  BorderRadius.circular(iconSize),
                                  boxShadow: [
                                    BoxShadow(
                                      color: cs.primary.withAlpha(151),
                                      blurRadius: iconSize * 0.6,
                                      spreadRadius: iconSize * 0.05,
                                    ),
                                    BoxShadow(
                                      color: cs.primary.withAlpha(90),
                                      blurRadius: iconSize * 1.2,
                                      spreadRadius: iconSize * 0.2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // === ICONS ===
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                            children: [
                              _navIcon(Icons.library_music,
                                  Icons.library_music_outlined, 0),
                              _navIcon(Icons.lightbulb,
                                  Icons.lightbulb_outline, 1),
                              _navIcon(Icons.home,
                                  Icons.home_outlined, 2),
                              _navIcon(Icons.build_circle,
                                  Icons.build_circle_outlined, 3),
                              _navIcon(Icons.videogame_asset,
                                  Icons.videogame_asset_outlined, 4),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon1, IconData icon2, int index) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {

        final double p = _controller.hasClients
            ? (_controller.page ??
            _controller.initialPage.toDouble())
            : _controller.initialPage.toDouble();

        final bool selected = p.round() == index;

        return IconButton(
          onPressed: () => _controller.animateToPage(
            index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          ),
          icon: Icon(
            selected ? icon1 : icon2,
            size: iconSize,
            color: colorScheme.onSurface,
          ),
        );
      },
    );
  }
}
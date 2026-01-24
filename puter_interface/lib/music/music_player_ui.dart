import 'package:flutter/material.dart';
import 'package:puter_interface/music/music_player.dart';

class MusicPlayerUI extends StatefulWidget {
  const MusicPlayerUI({super.key});

  @override
  State<StatefulWidget> createState() => _MusicPlayerUIState();
}

class _MusicPlayerUIState extends State<MusicPlayerUI> {
  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size size = mediaQuery.size;

    return Container(
      width: size.width,
      height: size.height * .2,
      child: Column(
        children: [
          Row(
            children: [
              FutureBuilder(
                  future: MusicPlayer.getNowPlaying(),
                  builder: (context, snapshot) =>
                      Text((snapshot.data ?? {}).toString()))
            ],
          ),
          Row(
            children: [
              IconButton(
                  onPressed: MusicPlayer.prevTrack,
                  icon: Icon(Icons.skip_previous_outlined)),
              IconButton(
                  onPressed: MusicPlayer.togglePlay,
                  icon: Icon(Icons.play_arrow_outlined)),
              IconButton(
                  onPressed: MusicPlayer.nextTrack,
                  icon: Icon(Icons.skip_next_outlined))
            ],
          )
        ],
      ),
    );
  }
}

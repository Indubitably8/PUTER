import 'package:flutter/material.dart';
import 'package:puter_interface/music/song_tile.dart';
import 'package:puter_interface/system/music/playerctl_stream.dart';

import '../system/music/now_playing.dart';

class MusicPlayerUI extends StatefulWidget {
  const MusicPlayerUI({super.key});

  @override
  State<MusicPlayerUI> createState() => _MusicPlayerUIState();
}

class _MusicPlayerUIState extends State<MusicPlayerUI> {
  final PlayerctlStream _player = PlayerctlStream();

  @override
  void initState() {
    super.initState();
    _player.start(); // start listening when widget mounts
  }

  @override
  void dispose() {
    _player.dispose(); // stop process + close stream
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<NowPlaying>(
      stream: _player.stream,
      builder: (context, snapshot) {
        final np = snapshot.data;

        return SongTile(np: np ?? NowPlaying.npDefault);
      },
    );
  }
}

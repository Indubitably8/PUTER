import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:puter_interface/extensions/duration_extension.dart';
import 'package:puter_interface/system/music/music_player.dart';
import 'package:puter_interface/system/music/playerctl_stream.dart';
import 'package:puter_interface/system/music/position_ticker.dart';

import '../system/music/now_playing.dart';

class MusicPlayerUI extends StatefulWidget {
  const MusicPlayerUI({super.key});

  @override
  State<MusicPlayerUI> createState() => _MusicPlayerUIState();
}

class _MusicPlayerUIState extends State<MusicPlayerUI> {
  final PlayerctlStream _player = PlayerctlStream();
  final PositionTicker _ticker = PositionTicker();

  @override
  void initState() {
    super.initState();
    _player.startNPStream();
    _ticker.start();
  }

  @override
  void dispose() {
    _player.dispose();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<NowPlaying>(
      stream: _player.npStream,
      builder: (context, snapshot) {
        final np = snapshot.data;

        return _musicPlayer(np ?? NowPlaying.empty);
      },
    );
  }

  Widget _musicPlayer(NowPlaying np) {
    return Column(
      children: [
        Padding(padding: const EdgeInsets.all(8), child: _songTile(np)),
        _controlPanel(np)
      ],
    );
  }

  Widget _songTile(NowPlaying np) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double size =
        min(mediaQuery.size.width * .4, mediaQuery.size.height * .2);

    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: colorScheme.surface,
        ),
        child: Row(children: [
          _albumCover(np),
          Expanded(
              child: Container(
                  margin: const EdgeInsets.all(8),
                  height: size,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _textDisplay(Icons.music_note_sharp, np.title),
                      _textDisplay(Icons.person, np.artist),
                      _textDisplay(Icons.album_rounded, np.album),
                    ],
                  )))
        ]));
  }

  Widget _textDisplay(IconData icon, String text) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, color: colorScheme.primary, size: 32),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 24,
                    overflow: TextOverflow.ellipsis)))
      ],
    );
  }

  Widget _albumCover(NowPlaying np) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double size =
        min(mediaQuery.size.width * .4, mediaQuery.size.height * .2);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: CachedNetworkImage(
          imageUrl: np.artUrl,
          placeholder: (_, __) => Image.asset("assets/images/album.jpg"),
          errorWidget: (_, __, ___) => Image.asset("assets/images/album.jpg"),
          fadeInDuration: const Duration(milliseconds: 100),
          fadeInCurve: Curves.linear,
          width: size,
          height: size),
    );
  }

  Widget _controlPanel(NowPlaying np) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final double size = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder(
            stream: _ticker.stream,
            builder: (context, snapshot) => _positionSlider(
                np, snapshot.data ?? const Duration(milliseconds: 0))),
      ],
    );
  }

  bool _isDragging = false;
  double _dragValue = 0.0; // 0..1

  Widget _positionSlider(NowPlaying np, Duration position) {
    final Duration? dur = np.duration;

    final bool canSeek = np.canSeek && dur != null && dur.inMilliseconds > 0;

    final totalMs = dur?.inMilliseconds ?? 0;
    final posMs = totalMs == 0 ? 0 : position.inMilliseconds.clamp(0, totalMs);

    final progress = totalMs == 0 ? 0.0 : posMs / totalMs;
    final sliderValue = _isDragging ? _dragValue : progress;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        children: [
          Slider(
            value: sliderValue.clamp(0.0, 1.0),
            onChanged: canSeek
                ? (v) => setState(() {
                      _isDragging = true;
                      _dragValue = v;
                    })
                : null,
            onChangeEnd: canSeek
                ? (v) async {
                    setState(() => _isDragging = false);
                    final seekMs = (v * totalMs).round();
                    await MusicPlayer.seekTo(Duration(milliseconds: seekMs));
                  }
                : null,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(position.formatTime(),
                  style: Theme.of(context).textTheme.bodySmall),
              _playSettings(np),
              Text((dur ?? Duration.zero).formatTime(),
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _playSettings(NowPlaying np) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
            onPressed: MusicPlayer.prevTrack,
            icon: Icon(Icons.skip_previous_rounded,
                size: 32,
                color: colorScheme.onSurface
                    .withAlpha(np.canPrevious ? 256 : 128))),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IconButton(
                onPressed: MusicPlayer.togglePlay,
                highlightColor: colorScheme.primary.withAlpha(64),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surface
                ),
                icon: Icon(
                    np.isPlaying
                        ? Icons.pause
                        : np.isPaused
                            ? Icons.play_arrow
                            : Icons.cancel_outlined,
                    size: 40,
                    color: colorScheme.onSurface
                        .withAlpha(np.canPlay ? 256 : 128)))),
        IconButton(
            onPressed: MusicPlayer.nextTrack,
            icon: Icon(Icons.skip_next_rounded,
                size: 32,
                color:
                    colorScheme.onSurface.withAlpha(np.canNext ? 256 : 128))),
      ],
    );
  }
}

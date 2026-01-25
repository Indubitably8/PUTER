import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'now_playing.dart';

class PlayerctlStream {
  Process? _proc;
  StreamSubscription<String>? _sub;
  StreamSubscription<String>? _errSub;

  final StreamController<NowPlaying> _npController =
  StreamController<NowPlaying>.broadcast();
  Stream<NowPlaying> get npStream => _npController.stream;

  Future<void> startNPStream() async {
    await stop();

    const format =
        '{{status}}|{{title}}|{{artist}}|{{album}}|{{mpris:artUrl}}|{{mpris:length}}|{{shuffle}}|{{loop}}|{{volume}}|{{canplay}}|{{canpause}}|{{cannext}}|{{canprevious}}|{{canseek}}|{{xesam:url}}';

    _proc = await Process.start(
      'playerctl',
      [
        '-p',
        'spotifyd',
        'metadata',
        '--follow',
        '--format',
        format,
      ],
      mode: ProcessStartMode.normal,
    );

    _sub = _proc!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      final np = _parseNowPlayingLine(line);
      if (np != null) _npController.add(np);
    });

    _errSub = _proc!.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((e) => print('playerctl stderr: $e'));

    _proc!.exitCode.then((_) async {
      await _sub?.cancel();
      await _errSub?.cancel();
      _sub = null;
      _errSub = null;
      _proc = null;
    });
  }

  NowPlaying? _parseNowPlayingLine(String line) {
    final parts = line.split('|');

    // Must match the number of fields in `format`.
    if (parts.length < 15) return null;

    final status = _parseStatus(parts[0].trim());

    final title = parts[1].trim();
    final artist = parts[2].trim();
    final album = parts[3].trim();
    final artUrl = parts[4].trim();

    final lengthUs = int.tryParse(parts[5].trim());
    final duration =
    lengthUs == null ? null : Duration(microseconds: lengthUs);

    final shuffle = _parseBool(parts[6]);
    final loopMode = _parseLoop(parts[7]);

    final volume = double.tryParse(parts[8].trim()) ?? 1.0;

    final uri = parts[14].trim();

    return NowPlaying(
      status: status,
      title: title,
      artist: artist,
      album: album,
      artUrl: artUrl,
      duration: duration,
      shuffle: shuffle,
      loopMode: loopMode,
      volume: volume,
      uri: uri,
    );
  }

  PlaybackStatus _parseStatus(String s) {
    switch (s) {
      case 'Playing':
        return PlaybackStatus.playing;
      case 'Paused':
        return PlaybackStatus.paused;
      case 'Stopped':
      default:
        return PlaybackStatus.stopped;
    }
  }

  LoopMode _parseLoop(String s) {
    switch (s.trim()) {
      case 'Track':
        return LoopMode.track;
      case 'Playlist':
        return LoopMode.playlist;
      case 'None':
      default:
        return LoopMode.none;
    }
  }

  bool _parseBool(String s) {
    final v = s.trim().toLowerCase();
    return v == 'true' || v == '1' || v == 'yes' || v == 'on';
  }

  Future<void> stop() async {
    await _sub?.cancel();
    await _errSub?.cancel();
    _sub = null;
    _errSub = null;

    final p = _proc;
    _proc = null;
    if (p != null) {
      p.kill(ProcessSignal.sigterm);
    }
  }

  Future<void> dispose() async {
    await stop();
    await _npController.close();
  }
}

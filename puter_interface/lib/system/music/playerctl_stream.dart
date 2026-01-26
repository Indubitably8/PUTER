import 'dart:async';

import '../command.dart';
import 'now_playing.dart';

class PlayerctlStream {
  RunningCommand? _cmd;
  StreamSubscription<String>? _sub;
  StreamSubscription<String>? _errSub;

  final StreamController<NowPlaying?> _npController =
  StreamController<NowPlaying?>.broadcast();
  Stream<NowPlaying?> get npStream => _npController.stream;

  Timer? _probe;
  bool _disconnectEmitted = false;

  void _emitDisconnected() {
    if (!_npController.isClosed) _npController.add(null);
  }

  void _emitDisconnectedOnce() {
    if (_disconnectEmitted) return;
    _disconnectEmitted = true;
    _emitDisconnected();
  }

  void _markConnected() {
    _disconnectEmitted = false;
  }

  Future<void> startNPStream() async {
    await stop();

    const String format =
        '{{status}}|{{title}}|{{artist}}|{{album}}|{{mpris:artUrl}}|{{mpris:length}}|{{shuffle}}|{{loop}}|{{volume}}|{{canplay}}|{{canpause}}|{{cannext}}|{{canprevious}}|{{canseek}}|{{xesam:url}}';

    _cmd = await CommandRunner.startLines(
      'playerctl',
      args: [
        '-p',
        'spotifyd',
        'metadata',
        '--follow',
        '--format',
        format,
      ],
    );

    _probe?.cancel();
    _probe = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (_cmd == null) return;

      final CommandResult result = await CommandRunner.runResult(
        'playerctl',
        args: ['-p', 'spotifyd', 'status'],
        timeout: const Duration(seconds: 1),
      );

      if (!result.ok) {
        _emitDisconnectedOnce();
      }
    });

    _sub = _cmd!.stdoutLines.listen(
          (line) {
        _markConnected();
        final NowPlaying? np = _parseNowPlayingLine(line);
        if (np != null) _npController.add(np);
      },
      onError: (_) => _emitDisconnectedOnce(),
      onDone: _emitDisconnectedOnce,
      cancelOnError: true,
    );

    _errSub = _cmd!.stderrLines.listen((e) {
      final String s = e.toLowerCase();
      if (s.contains('no player') ||
          s.contains('no players') ||
          s.contains('not found')) {
        _emitDisconnectedOnce();
      }
    });

    _cmd!.exitCode.then((_) async {
      _emitDisconnectedOnce();

      _probe?.cancel();
      _probe = null;

      await _sub?.cancel();
      await _errSub?.cancel();
      _sub = null;
      _errSub = null;

      _cmd = null;
    });
  }

  NowPlaying? _parseNowPlayingLine(String line) {
    final List<String> parts = line.split('|');

    if (parts.length < 15) return null;

    final PlaybackStatus status = _parseStatus(parts[0].trim());

    final String title = parts[1].trim();
    final String artist = parts[2].trim();
    final String album = parts[3].trim();
    final String artUrl = parts[4].trim();

    final int? lengthUs = int.tryParse(parts[5].trim());
    final Duration? duration = lengthUs == null ? null : Duration(microseconds: lengthUs);

    final bool shuffle = _parseBool(parts[6]);
    final LoopMode loopMode = _parseLoop(parts[7]);

    final double volume = double.tryParse(parts[8].trim()) ?? 1.0;

    final String uri = parts[14].trim();

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
    _emitDisconnected();

    _probe?.cancel();
    _probe = null;
    _disconnectEmitted = false;

    await _sub?.cancel();
    await _errSub?.cancel();
    _sub = null;
    _errSub = null;

    final RunningCommand? c = _cmd;
    _cmd = null;
    if (c != null) {
      await c.stop();
    }
  }

  Future<void> dispose() async {
    await stop();
    await _npController.close();
  }
}
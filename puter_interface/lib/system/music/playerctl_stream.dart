import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'now_playing.dart';

class PlayerctlStream {
  Process? _proc;
  StreamSubscription<String>? _sub;

  final StreamController<NowPlaying> _controller = StreamController<NowPlaying>.broadcast();
  Stream<NowPlaying> get stream => _controller.stream;

  Future<void> start() async {
    await stop();

    _proc = await Process.start(
      'playerctl',
      [
        '-p', 'spotifyd',
        'metadata',
        '--follow',
        '--format',
        '{{status}}|{{title}}|{{artist}}|{{album}}|{{mpris:length}}|{{mpris:artUrl}}',
      ],
      mode: ProcessStartMode.normal,
    );

    _sub = _proc!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      final parts = line.split('|');
      if (parts.length < 6) return;

      final status = parts[0];
      final title = parts[1];
      final artist = parts[2];
      final album = parts[3];
      final lengthUs = int.tryParse(parts[4]);
      final artUrl = parts[5];

      _controller.add(NowPlaying(
        status: status,
        title: title,
        artist: artist,
        album: album,
        length: lengthUs == null ? null : Duration(microseconds: lengthUs),
        artUrl: artUrl,
      ));
    }) as StreamSubscription<String>?;

    // Optional: read stderr for debugging
    _proc!.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((e) => print('playerctl stderr: $e'));
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    if (_proc != null) {
      _proc!.kill(ProcessSignal.sigterm);
      _proc = null;
    }
  }

  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }
}
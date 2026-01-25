import 'dart:async';
import 'dart:io';

class PositionTicker {
  PositionTicker({
    this.interval = const Duration(milliseconds: 250),
  });

  final Duration interval;

  Timer? _timer;
  final _controller = StreamController<Duration>.broadcast();
  Stream<Duration> get stream => _controller.stream;

  bool _running = false;

  void start() {
    if (_running) return;
    _running = true;

    _timer = Timer.periodic(interval, (_) async {
      final pos = await _readPosition();
      if (pos != null) _controller.add(pos);
    });
  }

  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> dispose() async {
    stop();
    await _controller.close();
  }

  Future<Duration?> _readPosition() async {
    final result =
    await Process.run('playerctl', ['-p', 'spotifyd', 'position']);
    if (result.exitCode != 0) return null;

    final String raw = (result.stdout as String).trim();
    final double? seconds = double.tryParse(raw);
    if (seconds == null) return null;

    return Duration(milliseconds: (seconds * 1000).round());
  }
}

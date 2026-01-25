import 'dart:io';

import 'package:puter_interface/system/command_runner.dart';

class MusicPlayer {
  static Future<Map<String, String>> getNowPlaying() async {
    final raw = await CommandRunner.bash('playerctl', [
      '-p',
      'spotifyd',
      'metadata',
      '--format',
      '{{title}}|{{artist}}|{{album}}|{{mpris:artUrl}}'
    ]);

    final parts = raw.split('|');
    return {
      'title': parts.isNotEmpty ? parts[0] : '',
      'artist': parts.length > 1 ? parts[1] : '',
      'album': parts.length > 2 ? parts[2] : '',
      'artUrl': parts.length > 3 ? parts[3] : '',
    };
  }

  static Future<void> initSpotifyd() =>
      CommandRunner.bash('spotifyd', ['--no-daemon']);

  static Future<void> setVolumePercent(int pct) => CommandRunner.bash(
      'pactl', ['set-sink-volume', '@DEFAULT_SINK@', '$pct%']);

  static Future<void> toggleMute() => CommandRunner.bash(
      'pactl', ['set-sink-mute', '@DEFAULT_SINK@', 'toggle']);

  static Future<void> nextTrack() =>
      CommandRunner.bash('playerctl', ['-p', 'spotifyd', 'next']);

  static Future<void> prevTrack() =>
      CommandRunner.bash('playerctl', ['-p', 'spotifyd', 'previous']);

  static Future<void> playTrack() =>
      CommandRunner.bash('playerctl', ['-p', 'spotifyd', 'play']);

  static Future<void> pauseTrack() =>
      CommandRunner.bash('playerctl', ['-p', 'spotifyd', 'pause']);

  static Future<void> togglePlay() =>
      CommandRunner.bash('playerctl', ['-p', 'spotifyd', 'play-pause']);

  static Future<void> seekTo(Duration position) async {
    final double seconds = position.inMilliseconds / 1000.0;
    await Process.run(
      'playerctl',
      ['-p', 'spotifyd', 'position', seconds.toStringAsFixed(2)],
    );
  }
}

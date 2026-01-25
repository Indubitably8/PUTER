enum PlaybackStatus { playing, paused, stopped }
enum LoopMode { none, track, playlist }

class NowPlaying {
  const NowPlaying({
    required this.status,
    required this.title,
    required this.artist,
    required this.album,
    required this.artUrl,
    required this.duration,
    required this.shuffle,
    required this.loopMode,
    required this.canPlay,
    required this.canPause,
    required this.canNext,
    required this.canPrevious,
    required this.canSeek,
    required this.volume,
    required this.uri,
  });

  final PlaybackStatus status;

  final String title;
  final String artist;
  final String album;
  final String artUrl;
  final Duration? duration;
  final String uri;

  final bool shuffle;
  final LoopMode loopMode;

  final bool canPlay;
  final bool canPause;
  final bool canNext;
  final bool canPrevious;
  final bool canSeek;

  final double volume;

  bool get isPlaying => status == PlaybackStatus.playing;
  bool get isPaused => status == PlaybackStatus.paused;
  bool get isStopped => status == PlaybackStatus.stopped;

  static const NowPlaying empty = NowPlaying(
    status: PlaybackStatus.stopped,
    title: '-----',
    artist: '',
    album: '',
    artUrl: '',
    duration: null,
    shuffle: false,
    loopMode: LoopMode.none,
    canPlay: false,
    canPause: false,
    canNext: false,
    canPrevious: false,
    canSeek: false,
    volume: 1.0,
    uri: '',
  );
}

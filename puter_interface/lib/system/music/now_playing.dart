class NowPlaying {
  const NowPlaying({
    required this.status,
    required this.title,
    required this.artist,
    required this.album,
    required this.artUrl,
    required this.length,
  });

  final String status, title, artist, album, artUrl;
  final Duration? length;

  static const NowPlaying npDefault = NowPlaying(
      status: "",
      title: "",
      artist: "",
      album: "",
      artUrl: "",
      length: const Duration(milliseconds: 0));
}

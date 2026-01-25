extension DurationExtension on Duration {
  String formatTime() {
    final minutes = inSeconds ~/ 60;
    final seconds = (inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
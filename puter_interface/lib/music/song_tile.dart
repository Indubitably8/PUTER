import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:puter_interface/system/music/now_playing.dart';

class SongTile extends StatelessWidget {
  const SongTile({super.key, required this.np});

  final NowPlaying np;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _albumCover(),
        Column(
          children: [
            Text(np.title),
            Text(np.album),
            Text(np.artist),
          ],
        )
      ]
    );
  }

  Widget _albumCover(){
    return CachedNetworkImage(
      imageUrl: np.artUrl,
      placeholder: (_, __) => Image.asset("assets/images/album.jpg"),
      fadeInDuration: const Duration(milliseconds: 200),
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:puter_interface/system/music/music_player.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: ListView.builder(
        itemCount: MusicPlayer.profiles.length + 1,
        itemBuilder: (context, index) {
          if (index == MusicPlayer.profiles.length) {
            return _addProfileButton();
          }
          return _profileTile(MusicPlayer.profiles[index]);
        },
      ),
    );
  }

  Widget _profileTile(String name) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final bool isFav = name == localStorage.getItem("defaultSpotifyd");
    final bool isPlaying = name == MusicPlayer.profile;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: isPlaying ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(
            child: Text(name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colorScheme.onSurface, fontSize: 32)),
          ),
          IconButton(
            onPressed: () async {
              await MusicPlayer.startSpotifydWithProfile(name);
              if (mounted) setState(() {});
            },
            icon: Icon(
              isPlaying
                  ? CupertinoIcons.play_arrow_solid
                  : CupertinoIcons.play_arrow,
              size: 32,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                localStorage.setItem("defaultSpotifyd", name);
              });
            },
            icon: Icon(
              isFav ? CupertinoIcons.star_fill : CupertinoIcons.star,
              size: 32,
            ),
          ),
          IconButton(
            onPressed: () async {
              await MusicPlayer.deleteSpotifydProfile(name);
              await MusicPlayer.listSpotifydProfiles();
              if (mounted) setState(() {});
            },
            icon: const Icon(
              CupertinoIcons.trash,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addProfileButton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: CupertinoButton.filled(
        onPressed: _showAddProfilePopup,
        child: const Text("Add Profile"),
      ),
    );
  }

  Future<void> _showAddProfilePopup() async {
    final TextEditingController fileCtrl = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text("New Profile"),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: fileCtrl,
                  decoration: const InputDecoration(
                    labelText: "Name",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            FilledButton(
              onPressed: () async {
                final String name = fileCtrl.text.trim();

                if (name.isEmpty) return;

                final String fileName =
                    name.endsWith(".conf") ? name : "$name.conf";

                await MusicPlayer.createSpotifydProfile(
                  profileName: fileName,
                );

                await MusicPlayer.listSpotifydProfiles();

                if (mounted) setState(() {});
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }
}

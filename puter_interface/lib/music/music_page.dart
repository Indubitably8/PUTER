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
  static const double iconSize = 32;

  static const double titleTextSize = 24;
  static const double bodyTextSize = 20;
  static const double buttonTextSize = 20;
  static const double profileNameTextSize = 32;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.tertiaryContainer,
          centerTitle: true,
          title: Text("Audio System",
              style: TextStyle(
                  fontFamily: "Audiowide",
                  color: colorScheme.onSurface,
                  fontSize: titleTextSize)),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Text(
                    "Profiles",
                    style: TextStyle(
                        fontFamily: "Quantico",
                        fontWeight: FontWeight.w600,
                        fontSize: titleTextSize),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),
            ...List<Widget>.generate(MusicPlayer.profiles.length,
                    (i) => _profileTile(MusicPlayer.profiles[i])),
            _addProfileButton()
          ],
        ));
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
                style: TextStyle(
                    fontFamily: "Quantico",
                    color: colorScheme.onSurface,
                    fontSize: profileNameTextSize)),
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
              size: iconSize,
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
              size: iconSize,
            ),
          ),
          IconButton(
            onPressed: () async {
              await MusicPlayer.deleteSpotifydProfile(name);
              await MusicPlayer.listSpotifydProfiles();
              if (mounted) setState(() {});
            },
            icon: Icon(
              CupertinoIcons.trash,
              size: iconSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addProfileButton() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      width: mediaQuery.size.width,
      child: CupertinoButton.filled(
        onPressed: _showAddProfilePopup,
        child: Text("Add Profile",
            style: TextStyle(
                fontFamily: "Cousine",
                fontSize: buttonTextSize,
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w500)),
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
          title: Text("New Profile",
              style: TextStyle(
                  fontFamily: "Orbitron", fontSize: titleTextSize)),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: fileCtrl,
                  style:
                  TextStyle(fontFamily: "Cousine", fontSize: bodyTextSize),
                  decoration: InputDecoration(
                      labelText: "Name",
                      labelStyle: TextStyle(
                          fontFamily: "Cousine", fontSize: bodyTextSize)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel",
                  style: TextStyle(
                      fontFamily: "Cousine",
                      fontWeight: FontWeight.w600,
                      fontSize: bodyTextSize)),
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
              child: Text("Create",
                  style: TextStyle(
                      fontFamily: "Cousine",
                      fontWeight: FontWeight.w600,
                      fontSize: bodyTextSize)),
            ),
          ],
        );
      },
    );
  }
}
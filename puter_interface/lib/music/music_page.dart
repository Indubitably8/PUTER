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
        title: Text(
          "Audio System",
          style: TextStyle(
            fontFamily: "Audiowide",
            color: colorScheme.onSurface,
            fontSize: titleTextSize,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  "Profiles",
                  style: TextStyle(
                    fontFamily: "Quantico",
                    fontWeight: FontWeight.w600,
                    fontSize: titleTextSize,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          ...List<Widget>.generate(
            MusicPlayer.profiles.length,
            (i) => _profileTile(MusicPlayer.profiles[i]),
          ),
          _addProfileButton(),
        ],
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: "Quantico",
                color: colorScheme.onSurface,
                fontSize: profileNameTextSize,
              ),
            ),
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
            icon: const Icon(
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
        child: Text(
          "Add Profile",
          style: TextStyle(
            fontFamily: "Cousine",
            fontSize: buttonTextSize,
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _showAddProfilePopup() async {
  final TextEditingController fileCtrl = TextEditingController();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      bool isCreating = false;
      bool cancelRequested = false;
      String? errorText;

      CancelToken? token;
      Future<void>? createFuture;

      void safeSetDialog(StateSetter setDialogState, VoidCallback fn) {
        if (!dialogContext.mounted) return;
        setDialogState(fn);
      }

      Future<void> handleCreate(StateSetter setDialogState) async {
        if (isCreating) return;

        final String name = fileCtrl.text.trim();
        if (name.isEmpty) return;

        final String fileName = name.endsWith(".conf") ? name : "$name.conf";

        safeSetDialog(setDialogState, () {
          isCreating = true;
          cancelRequested = false;
          errorText = null;
          token = CancelToken();
        });

        createFuture = () async {
          await MusicPlayer.createSpotifydProfile(
            profileName: fileName,
            cancelToken: token,
          );
          await MusicPlayer.listSpotifydProfiles();
        }();

        try {
          await createFuture;

          if (mounted) setState(() {});
          if (dialogContext.mounted) Navigator.pop(dialogContext);
        } on OperationCancelled {
          // Cancel was requested; close from here (NOT from the Cancel button handler)
          if (dialogContext.mounted) Navigator.pop(dialogContext);
        } catch (e) {
          safeSetDialog(setDialogState, () {
            isCreating = false;
            cancelRequested = false;
            token = null;
            createFuture = null;
            errorText = "Failed to create profile.\n$e";
          });
        }
      }

      void handleCancel(StateSetter setDialogState) {
        // Only exit path. If not creating, just close.
        if (!isCreating) {
          Navigator.pop(dialogContext);
          return;
        }

        // If creating: request cancel but DO NOT pop the dialog here.
        if (cancelRequested) return;

        safeSetDialog(setDialogState, () {
          cancelRequested = true;
          errorText = null;
        });

        token?.cancel();
        // Do NOT await or pop here—avoid race with handleCreate.
      }

      return StatefulBuilder(
        builder: (context, setDialogState) {
          return PopScope(
            canPop: false, // no back/escape
            child: AlertDialog(
              title: Text(
                "New Profile",
                style: TextStyle(fontFamily: "Orbitron", fontSize: titleTextSize),
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: fileCtrl,
                      enabled: !isCreating, // lock editing once started
                      style: TextStyle(fontFamily: "Cousine", fontSize: bodyTextSize),
                      decoration: InputDecoration(
                        labelText: "Name",
                        labelStyle: TextStyle(fontFamily: "Cousine", fontSize: bodyTextSize),
                        errorText: errorText,
                      ),
                      onSubmitted: (_) async => handleCreate(setDialogState),
                    ),
                    if (isCreating) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            cancelRequested ? "Cancelling…" : "Creating…",
                            style: TextStyle(fontFamily: "Cousine", fontSize: bodyTextSize),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  // Cancel always available; during create it triggers cancel request
                  onPressed: () => handleCancel(setDialogState),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontFamily: "Cousine",
                      fontWeight: FontWeight.w600,
                      fontSize: bodyTextSize,
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: (isCreating) ? null : () async => handleCreate(setDialogState),
                  child: Text(
                    "Create",
                    style: TextStyle(
                      fontFamily: "Cousine",
                      fontWeight: FontWeight.w600,
                      fontSize: bodyTextSize,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

}
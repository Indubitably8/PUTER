import 'package:flutter/material.dart';

import '../system/command.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 48,
      width: MediaQuery.of(context).size.width * .5,
      child: ElevatedButton(onPressed: () => CommandRunner.runResult("emulationstation"), child: Text("Time for a break?")),
    );
  }
}
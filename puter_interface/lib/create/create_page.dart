import 'package:flutter/material.dart';
import 'package:puter_interface/system/server.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 48,
      width: MediaQuery.of(context).size.width * .5,
      child: ElevatedButton(
          onPressed: () async => print(await Server.health()),
          child: Text("Test py server")),
    );
  }
}

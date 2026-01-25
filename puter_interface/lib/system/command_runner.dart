import 'dart:io';

class CommandRunner {
  static Future<String> bash(String cmd, [List<String> args = const []]) async {
    final result = await Process.run(cmd, args);
    if (result.exitCode != 0) {
      throw Exception('Command failed: $cmd ${args.join(" ")}\n${result.stderr}');
    }
    return (result.stdout as String).trim();
  }
}
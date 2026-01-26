import 'dart:async';
import 'dart:convert';
import 'dart:io';

class CommandResult {
  final int exitCode;
  final String stdout;
  final String stderr;

  const CommandResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  bool get ok => exitCode == 0;
}

class RunningCommand {
  final Process process;
  final Stream<String> stdoutLines;
  final Stream<String> stderrLines;

  RunningCommand._(this.process, this.stdoutLines, this.stderrLines);

  Future<int> get exitCode => process.exitCode;

  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) =>
      process.kill(signal);

  Future<void> stop({
    ProcessSignal signal = ProcessSignal.sigterm,
    Duration grace = const Duration(milliseconds: 300),
    bool forceKill = true,
  }) async {
    if (process.pid == 0) return;

    kill(signal);

    try {
      await process.exitCode.timeout(grace);
      return;
    } catch (_) {}

    if (forceKill) {
      kill(ProcessSignal.sigkill);
    }
  }
}

class CommandRunner {
  static String? defaultWorkingDirectory;
  static bool verbose = false;

  static Future<CommandResult> runResult(
    String executable, {
    List<String> args = const [],
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    Duration? timeout,
    bool runInShell = false,
    Encoding stdoutEncoding = utf8,
    Encoding stderrEncoding = utf8,
  }) async {
    if (verbose) {
      stderr.writeln('[run] $executable ${args.join(" ")}');
    }

    final Future<ProcessResult> future = Process.run(
      executable,
      args,
      workingDirectory: workingDirectory ?? defaultWorkingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
      stdoutEncoding: stdoutEncoding,
      stderrEncoding: stderrEncoding,
    );

    final ProcessResult res = timeout == null
        ? await future
        : await future.timeout(timeout, onTimeout: () {
            return ProcessResult(0, 124, '', 'timeout');
          });

    final String out = res.stdout.trimRight();
    final String err = res.stderr.trimRight();

    return CommandResult(exitCode: res.exitCode, stdout: out, stderr: err);
  }

  static Future<RunningCommand> startLines(
    String executable, {
    List<String> args = const [],
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    ProcessStartMode mode = ProcessStartMode.normal,
  }) async {
    if (verbose) {
      stderr.writeln('[start] $executable ${args.join(" ")}');
    }

    final Process proc = await Process.start(
      executable,
      args,
      workingDirectory: workingDirectory ?? defaultWorkingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
      mode: mode,
    );

    final Stream<String> outLines =
        proc.stdout.transform(utf8.decoder).transform(const LineSplitter());
    final Stream<String> errLines =
        proc.stderr.transform(utf8.decoder).transform(const LineSplitter());

    return RunningCommand._(proc, outLines, errLines);
  }

  static Future<CommandResult> bashResult(
    String commandLine, {
    Duration? timeout,
    bool sudo = false,
  }) {
    final String exec = sudo ? 'sudo' : 'bash';
    final List<String> args = sudo
        ? <String>['bash', '-lc', commandLine]
        : <String>['-lc', commandLine];

    return runResult(exec, args: args, timeout: timeout);
  }
}

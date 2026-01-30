import 'dart:io';
import 'rebrand_task.dart';

class ProjectSyncTask extends RebrandTask {
  @override
  String get name => "Cleaning Up and Syncing Project";

  @override
  Future<void> execute() async {
    await _run('flutter', ['clean'], "Performing Final Cleanup");
    await _run('flutter', ['pub', 'get'], "Re-syncing Project Dependencies");

    if (Platform.isMacOS) {
      final podFile = File('ios/Podfile');
      if (podFile.existsSync()) {
        await _run('pod', ['install'], "Syncing iOS CocoaPods...", workingDirectory: 'ios');
      }
    }
  }

  Future<void> _run(String cmd, List<String> args, String desc, {String? workingDirectory}) async {
    print("   $desc");
    final result = await Process.run(
      cmd,
      args,
      workingDirectory: workingDirectory,
      runInShell: true,
    );

    if (result.exitCode != 0) {
      print("   ⚠️ Warning: Command Failed: $cmd ${args.join(' ')}");
      print("   STDOUT: ${result.stdout}");
      print("   STDERR: ${result.stderr}");
    }
  }
}

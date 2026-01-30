import 'dart:io';
import 'rebrand_task.dart';

class PackageRenameTask extends RebrandTask {
  @override
  String get name => "Renaming Package to $packageName";

  final String packageName;

  PackageRenameTask(this.packageName);

  @override
  Future<void> execute() async {
    final result = await Process.run('dart', [
      'run',
      'change_app_package_name:main',
      packageName,
    ], runInShell: true);

    if (result.exitCode != 0) {
      throw "Failed to rename package: ${result.stderr}";
    }
  }
}

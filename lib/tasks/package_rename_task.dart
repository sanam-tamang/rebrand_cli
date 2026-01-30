import 'dart:io';
import '../rebrand_config.dart';
import 'rebrand_task.dart';

class PackageRenameTask extends RebrandTask {
  final RebrandConfig config;

  PackageRenameTask(this.config);

  @override
  String get name => "Renaming Package to ${config.packageName}";

  @override
  Future<void> execute() async {
    if (!config.enableAndroid || !config.enableIOS) {
      print(
        "   ⚠️  Warning: Package renaming applies to BOTH Android and iOS. Platform flags are ignored for this step.",
      );
    }

    final result = await Process.run('dart', [
      'run',
      'change_app_package_name:main',
      config.packageName!,
    ], runInShell: true);

    if (result.exitCode != 0) {
      throw "Failed to rename package: ${result.stderr}";
    }
  }
}

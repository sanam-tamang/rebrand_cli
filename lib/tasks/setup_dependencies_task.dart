import 'dart:io';
import '../rebrand_config.dart';
import 'rebrand_task.dart';

class SetupDependenciesTask extends RebrandTask {
  final RebrandConfig config;

  SetupDependenciesTask(this.config);

  @override
  String get name => "Validating & Installing Worker Packages";

  @override
  Future<void> execute() async {
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      throw "pubspec.yaml not found. Are you in a Flutter project root?";
    }

    final pubspecContent = pubspecFile.readAsStringSync();

    final requiredWorkers = <String>[
      if (config.enablePackageRename) 'change_app_package_name',
      if (config.enableLauncherIcon) 'flutter_launcher_icons',
      if (config.enableSplash) 'flutter_native_splash',
    ];

    if (requiredWorkers.isEmpty) {
      print("   ℹ️ No worker packages needed for the selected actions.");
      return;
    }

    final missingWorkers = requiredWorkers
        .where((package) => !pubspecContent.contains(package))
        .toList();

    if (missingWorkers.isNotEmpty) {
      print("   📦 Adding missing workers: ${missingWorkers.join(', ')}...");

      final result = await Process.run('flutter', [
        'pub',
        'add',
        '--dev',
        ...missingWorkers,
      ], runInShell: true);

      if (result.exitCode != 0) {
        throw "Failed to install dependencies: ${result.stderr}";
      }
      print("   ✅ Workers installed successfully.");
    } else {
      print("   ✅ All worker packages already present.");
    }
  }
}

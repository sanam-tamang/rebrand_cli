import 'dart:io';
import 'rebrand_task.dart';

class SetupDependenciesTask extends RebrandTask {
  @override
  String get name => "Validating & Installing Worker Packages";

  @override
  Future<void> execute() async {
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      throw "pubspec.yaml not found. Are you in a Flutter project root?";
    }

    final pubspecContent = pubspecFile.readAsStringSync();

    final requiredWorkers = [
      'change_app_package_name',
      'flutter_launcher_icons',
      'flutter_native_splash',
    ];

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

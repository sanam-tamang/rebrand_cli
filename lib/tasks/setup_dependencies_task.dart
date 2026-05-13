import 'dart:io';
import '../rebrand_action.dart';
import '../rebrand_config.dart';
import 'rebrand_task.dart';

/// Ensures required worker packages are available for the selected actions.
///
/// It inspects the requested [RebrandAction] set and adds missing dev
/// dependencies such as `change_app_package_name`, `flutter_launcher_icons`,
/// or `flutter_native_splash` to the project.
class SetupDependenciesTask extends RebrandTask {
  final RebrandConfig config;
  final Set<RebrandAction> actions;

  SetupDependenciesTask(this.config, {required this.actions});

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
      if (actions.contains(RebrandAction.rename)) 'change_app_package_name',
      if (actions.contains(RebrandAction.launcher)) 'flutter_launcher_icons',
      if (actions.contains(RebrandAction.splash)) 'flutter_native_splash',
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

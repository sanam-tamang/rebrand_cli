import 'dart:io';
import '../rebrand_config.dart';
import '../utils/asset_manager.dart';
import 'rebrand_task.dart';

/// Removes splash screen assets if clearSplash flag is set.
///
/// This task runs BEFORE asset generation to handle the removal case:
/// - If clearSplash=true → Remove splash config & files
/// - If splash data is provided → Implicitly clear old before new
///
/// Other assets (icons, package name, app label) are always applied if data
/// exists, and don't have clear/removal options.
class CleanupTask extends RebrandTask {
  final RebrandConfig config;

  CleanupTask(this.config);

  @override
  String get name => "Cleaning Up Splash Screen";

  @override
  Future<void> execute() async {
    if (!config.shouldClearSplash) {
      return; 
    }

    print("  🗑️  Removing splash screen using native tool...");

    // 1. Run native removal tool (let the package handle it)
    try {
      await Process.run('dart', [
        'run',
        'flutter_native_splash:remove',
      ], runInShell: true);
    } catch (_) {}

    // 2. Remove splash config from pubspec.yaml
    await AssetManager.removeFromPubspec('flutter_native_splash');

    print("  ✓ Splash removed");
  }
}

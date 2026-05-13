import 'package:rebrand_cli/rebrand_config.dart';
import 'package:rebrand_cli/tasks/asset_generation_task.dart';
import 'package:rebrand_cli/tasks/rebrand_task.dart';

/// Generates native splash screen assets and runs the splash tool.
///
/// This task prepares splash images, optionally auto-padding them for Android 12
/// safe zones, then invokes `flutter_native_splash` with the generated YAML.
class SplashTask extends RebrandTask {
  final RebrandConfig config;

  SplashTask(this.config);

  @override
  String get name => 'Generating Splash Screens';

  @override
  Future<void> execute() async {
    if (!config.shouldGenerateSplash) {
      throw 'Splash generation requires either "splash_config" or "icon_path" in rebrand_config.json.';
    }

    final splashImagePath = AssetGenerationTask.prepareSplashImage(
      config.splashImagePath,
      'assets/rebrand/rebrand_splash_padded.png',
      config: config,
    );
    final splashDarkImagePath = AssetGenerationTask.prepareSplashImage(
      config.splashDarkImagePath,
      'assets/rebrand/rebrand_splash_dark_padded.png',
      config: config,
    );
    final android12ImagePath = AssetGenerationTask.prepareSplashImage(
      config.android12ImagePath,
      'assets/rebrand/rebrand_splash_android12_padded.png',
      config: config,
    );
    final android12DarkImagePath = AssetGenerationTask.prepareSplashImage(
      config.android12DarkImagePath,
      'assets/rebrand/rebrand_splash_android12_dark_padded.png',
      config: config,
    );

    if (splashImagePath == null || android12ImagePath == null) {
      throw 'Failed to prepare splash images. Please ensure that a valid image path exists.';
    }

    await AssetGenerationTask.writeAndRunSplash(
      config: config,
      imagePath: splashImagePath,
      darkImagePath: splashDarkImagePath,
      android12ImagePath: android12ImagePath,
      android12DarkImagePath: android12DarkImagePath,
    );
  }
}

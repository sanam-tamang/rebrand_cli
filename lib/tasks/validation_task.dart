import 'dart:io';
import '../rebrand_config.dart';
import 'rebrand_task.dart';

class ValidationTask extends RebrandTask {
  final RebrandConfig config;

  ValidationTask(this.config);

  @override
  String get name => "Validating Configuration";

  @override
  Future<void> execute() async {
    // 1. Validate Package Name
    if (config.enablePackageRename) {
      if (config.packageName == null || config.packageName!.isEmpty) {
        throw "Package name is required when 'enable_package_rename' is true.";
      }
      if (!_isValidPackageName(config.packageName!)) {
        throw "Invalid package name format: ${config.packageName}. Expected format: com.example.app (lowercase, dots, no special chars)";
      }
    }

    // 2. Validate App Name
    if (config.enableAppLabel) {
      if (config.appName == null || config.appName!.isEmpty) {
        throw "App name is required when 'enable_app_label' is true.";
      }
    }

    // 3. Validate Icon Path
    if (config.enableLauncherIcon) {
      if (config.iconPath == null || config.iconPath!.isEmpty) {
        throw "Icon path is required when 'enable_launcher_icon' is true.";
      }
      if (!File(config.iconPath!).existsSync()) {
        throw "Icon file not found at: ${config.iconPath}";
      }
    }

    // 4. Validate Splash Configuration
    if (config.enableSplash) {
      // Check splash image if provided
      final splashImage = config.splash?['image'];
      if (splashImage != null && !File(splashImage).existsSync()) {
        throw "Splash image file not found at: $splashImage";
      }

      // If splash image is not provided, it uses iconPath.
      if (splashImage == null) {
        if (config.iconPath == null || config.iconPath!.isEmpty) {
          throw "Splash generation requires either 'splash_config.image' or 'icon_path'.";
        }
        if (!File(config.iconPath!).existsSync()) {
          throw "Icon file (used for splash) not found at: ${config.iconPath}";
        }
      }

      // Check colors
      final color = config.splash?['color'];
      if (color != null && !_isValidHexColor(color)) {
        throw "Invalid splash color format: $color. Expected hex code (e.g., #FFFFFF).";
      }

      final darkColor = config.splash?['dark_color'];
      if (darkColor != null && !_isValidHexColor(darkColor)) {
        throw "Invalid splash dark_color format: $darkColor. Expected hex code (e.g., #000000).";
      }
    }
  }

  bool _isValidPackageName(String packageName) {
    // Basic validation: starts with letter, contains only lowercase letters, numbers, underscores, and dots.
    // Must have at least one dot.
    final regex = RegExp(r'^[a-z][a-z0-9_]*(\.[a-z0-9_]+)+$');
    return regex.hasMatch(packageName);
  }

  bool _isValidHexColor(String hexColor) {
    final regex = RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$');
    return regex.hasMatch(hexColor);
  }
}

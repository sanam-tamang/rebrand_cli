import 'dart:io';
import '../rebrand_action.dart';
import '../rebrand_config.dart';
import 'rebrand_task.dart';

/// Validates rebrand configuration before any changes are applied.
///
/// The validator checks required fields, file existence, color formats, and
/// platform-specific splash settings. It can validate only explicitly requested
/// actions when the CLI is invoked with `--rename`, `--label`, `--launcher`,
/// or `--splash`.
class ValidationTask extends RebrandTask {
  final RebrandConfig config;
  final Set<RebrandAction>? actions;
  final bool explicitActions;

  ValidationTask(this.config, {this.actions, this.explicitActions = false});

  @override
  String get name => "Validating Configuration";

  @override
  Future<void> execute() async {
    final effectiveActions = actions ?? _deriveDefaultActions();

    if (explicitActions && effectiveActions.isEmpty) {
      throw "No actions selected. Use --rename, --label/--app-name, --launcher, or --splash with a valid config.";
    }

    if (!explicitActions && !config.hasEnabledActions) {
      throw "Nothing to rebrand. Enable at least one action in rebrand_config.json.";
    }

    if (effectiveActions.contains(RebrandAction.rename)) {
      _validatePackageName();
    }

    if (effectiveActions.contains(RebrandAction.label)) {
      _validateAppName();
    }

    if (!explicitActions &&
        config.appName != null &&
        !effectiveActions.contains(RebrandAction.label)) {
      _validateAppName();
    }

    if (effectiveActions.contains(RebrandAction.launcher)) {
      _validateIconPath();
    }

    if (effectiveActions.contains(RebrandAction.splash)) {
      _validateSplashConfig();
    }
  }

  Set<RebrandAction> _deriveDefaultActions() {
    final defaultActions = <RebrandAction>{};
    if (config.packageName != null) {
      defaultActions.add(RebrandAction.rename);
    }
    if (config.appName != null) {
      defaultActions.add(RebrandAction.label);
    }
    if (config.iconPath != null) {
      defaultActions.add(RebrandAction.launcher);
    }
    if (config.splash != null || config.iconPath != null) {
      defaultActions.add(RebrandAction.splash);
    }
    return defaultActions;
  }

  void _validatePackageName() {
    if (config.packageName == null || config.packageName!.isEmpty) {
      throw "Package name cannot be empty.";
    }
    if (!_isValidPackageName(config.packageName!)) {
      throw "Invalid package name format: ${config.packageName}. Expected format: com.example.app (lowercase, dots, no special chars)";
    }
  }

  void _validateAppName() {
    if (config.appName == null || config.appName!.isEmpty) {
      throw "App name cannot be empty.";
    }
  }

  void _validateIconPath() {
    if (config.iconPath == null || config.iconPath!.isEmpty) {
      throw "Launcher generation requires 'icon_path' in rebrand_config.json.";
    }
    if (!File(config.iconPath!).existsSync()) {
      throw "Icon file not found at: ${config.iconPath}";
    }
  }

  void _validateSplashConfig() {
    final rawAndroid12 = config.splashConfig['android_12'];
    if (rawAndroid12 != null && rawAndroid12 is! Map) {
      throw "'splash_config.android_12' must be a JSON object.";
    }

    final splashImage = config.splashImagePath;
    if (splashImage == null || splashImage.isEmpty) {
      throw "Splash generation requires either 'splash_config.image' or 'icon_path'.";
    }

    _validateExistingFile(splashImage, 'Splash image');

    final splashDarkImage = config.splashDarkImagePath;
    if (splashDarkImage != null) {
      _validateExistingFile(splashDarkImage, 'Splash dark image');
    }

    _validateExistingFile(config.splashBranding, 'Splash branding image');
    _validateExistingFile(
      config.splashBrandingDark,
      'Splash dark branding image',
    );
    _validateExistingFile(
      config.android12Branding,
      'Android 12 branding image',
    );
    _validateExistingFile(
      config.android12BrandingDark,
      'Android 12 dark branding image',
    );

    _validateColor(config.splashColor, 'splash color');
    _validateColor(config.splashDarkColor, 'splash dark_color');
    _validateColor(config.android12Color, 'android_12 color');
    _validateColor(config.android12DarkColor, 'android_12 dark_color');
    _validateColor(
      config.android12IconBackgroundColor,
      'android_12 icon_background_color',
    );
    _validateColor(
      config.android12IconBackgroundDarkColor,
      'android_12 icon_background_color_dark',
    );

    if (config.splashAutoPad &&
        (config.splashScreenScale <= 0 || config.splashScreenScale > 1)) {
      throw "Invalid splash scaling value: ${config.splashScreenScale}. Expected a number greater than 0 and less than or equal to 1.";
    }

    if (!_isValidAndroidGravity(config.splashGravity)) {
      throw "Invalid splash gravity: ${config.splashGravity}.";
    }

    if (!_isValidIOSContentMode(config.splashIOSContentMode)) {
      throw "Invalid iOS content mode: ${config.splashIOSContentMode}.";
    }
  }

  void _validateExistingFile(String? path, String label) {
    if (path == null || path.isEmpty) {
      return;
    }

    if (!File(path).existsSync()) {
      throw "$label file not found at: $path";
    }
  }

  void _validateColor(String? color, String label) {
    if (color == null || color.isEmpty) {
      return;
    }

    if (!_isValidHexColor(color)) {
      throw "Invalid $label format: $color. Expected hex code (e.g., #FFFFFF).";
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

  bool _isValidAndroidGravity(String gravity) {
    const validValues = {
      'bottom',
      'center',
      'center_horizontal',
      'center_vertical',
      'clip_horizontal',
      'clip_vertical',
      'end',
      'fill',
      'fill_horizontal',
      'fill_vertical',
      'left',
      'right',
      'start',
      'top',
    };

    return gravity
        .split('|')
        .every((part) => validValues.contains(part.trim()));
  }

  bool _isValidIOSContentMode(String mode) {
    const validValues = {
      'scaleToFill',
      'scaleAspectFit',
      'scaleAspectFill',
      'center',
      'top',
      'bottom',
      'left',
      'right',
      'topLeft',
      'topRight',
      'bottomLeft',
      'bottomRight',
    };

    return validValues.contains(mode);
  }
}

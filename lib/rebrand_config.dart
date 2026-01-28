/// Configuration model for the Rebrand CLI tool.
///
/// This class holds all the necessary configuration data required to rebrand
/// a Flutter application, including app name, package identifier, icon assets,
/// and splash screen settings.
///
/// The configuration is typically loaded from a `rebrand_config.json` file
/// located in the root of the Flutter project.
///
/// Example JSON structure:
/// ```json
/// {
///   "app_name": "My New App",
///   "package_name": "com.newcompany.app",
///   "icon_path": "assets/logo.png",
///   "splash_config": {
///     "color": "#FFFFFF",
///     "image": "assets/logo.png",
///     "dark_color": "#111111"
///   }
/// }
/// ```
class RebrandConfig {
  /// The display name of the application.
  ///
  /// This will be used to update the app label in AndroidManifest.xml
  /// and Info.plist for iOS.
  final String appName;

  /// The unique package identifier for the application.
  ///
  /// Format: reverse domain notation (e.g., "com.company.appname")
  /// This updates the Bundle ID across Android and iOS platforms.
  final String packageName;

  /// Path to the app icon image file.
  ///
  /// Should be a high-resolution PNG image (recommended: 1024x1024px)
  /// used for generating platform-specific app icons.
  final String iconPath;

  /// Splash screen configuration settings.
  ///
  /// Contains properties like background color, image path, and optional
  /// dark mode settings for the native splash screen.
  final Map<String, dynamic> splash;

  /// Creates a new [RebrandConfig] instance.
  ///
  /// All parameters are required to ensure complete configuration.
  RebrandConfig({
    required this.appName,
    required this.packageName,
    required this.iconPath,
    required this.splash,
  });

  /// Creates a [RebrandConfig] instance from a JSON map.
  ///
  /// The JSON structure should match the expected configuration format
  /// with keys: 'app_name', 'package_name', 'icon_path', and 'splash_config'.
  ///
  /// Throws an error if required keys are missing from the JSON.
  factory RebrandConfig.fromJson(Map<String, dynamic> json) {
    return RebrandConfig(
      appName: json['app_name'],
      packageName: json['package_name'],
      iconPath: json['icon_path'],
      splash: json['splash_config'],
    );
  }
}

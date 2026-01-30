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
  final String? appName;

  /// The unique package identifier for the application.
  ///
  /// Format: reverse domain notation (e.g., "com.company.appname")
  /// This updates the Bundle ID across Android and iOS platforms.
  final String? packageName;

  /// Path to the app icon image file.
  ///
  /// Should be a high-resolution PNG image (recommended: 1024x1024px)
  /// used for generating platform-specific app icons.
  final String? iconPath;

  /// Splash screen configuration settings.
  ///
  /// Contains properties like background color, image path, and optional
  /// dark mode settings for the native splash screen.
  final Map<String, dynamic>? splash;

  /// Scale factor for the splash screen image (0.0 to 1.0).
  ///
  /// Controls how much the logo is scaled relative to the splash screen canvas.
  /// Defaults to 0.65 if not specified in the configuration.
  final double splashScreenScale;

  /// Whether to generate the splash screen.
  final bool enableSplash;

  /// Whether to generate launcher icons.
  final bool enableLauncherIcon;

  /// Whether to rename the package (Bundle ID).
  final bool enablePackageRename;

  /// Whether to update the app label (App Name).
  final bool enableAppLabel;

  /// Whether to enable rebranding for Android.
  final bool enableAndroid;

  /// Whether to enable rebranding for iOS.
  final bool enableIOS;

  /// Creates a new [RebrandConfig] instance.
  RebrandConfig({
    this.appName,
    this.packageName,
    this.iconPath,
    this.splash,
    this.splashScreenScale = 0.65,
    this.enableSplash = true,
    this.enableLauncherIcon = true,
    this.enablePackageRename = true,
    this.enableAppLabel = true,
    this.enableAndroid = true,
    this.enableIOS = true,
  });

  /// Creates a [RebrandConfig] instance from a JSON map.
  ///
  /// The JSON structure should match the expected configuration format.
  /// Optional keys: 'app_name', 'package_name', 'icon_path', 'splash_config'.
  /// Optional flags: 'enable_splash', 'enable_launcher_icon', 'enable_package_rename', 'enable_app_label', 'enable_android', 'enable_ios'.
  factory RebrandConfig.fromJson(Map<String, dynamic> json) {
    final appName = json['app_name'];
    final packageName = json['package_name'];
    final iconPath = json['icon_path'];
    final splash = json['splash_config'];

    return RebrandConfig(
      appName: appName,
      packageName: packageName,
      iconPath: iconPath,
      splash: splash,
      splashScreenScale: (splash?['scaling'] as num?)?.toDouble() ?? 0.65,
      enableSplash: json['enable_splash'] ?? (splash != null),
      enableLauncherIcon: json['enable_launcher_icon'] ?? (iconPath != null),
      enablePackageRename:
          json['enable_package_rename'] ?? (packageName != null),
      enableAppLabel: json['enable_app_label'] ?? (appName != null),
      enableAndroid: json['enable_android'] ?? true,
      enableIOS: json['enable_ios'] ?? true,
    );
  }
}

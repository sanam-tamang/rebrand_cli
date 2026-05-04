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

  /// Whether to enable rebranding for Android.
  final bool enableAndroid;

  /// Whether to enable rebranding for iOS.
  final bool enableIOS;

  /// Whether to clear/remove the splash screen (remove config & files).
  /// When true, removes splash from pubspec.yaml and deletes splash files.
  /// Note: Only clearSplash is needed because:
  /// - appName, packageName, iconPath are always applied if provided
  /// - Only splash is optional and can be removed
  final bool clearSplash;

  Map<String, dynamic> get splashConfig => splash ?? const <String, dynamic>{};

  Map<String, dynamic> get android12SplashConfig {
    final value = splashConfig['android_12'];
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return const <String, dynamic>{};
  }

  /// Check if there are any data to process or actions to take
  bool get hasActions =>
      appName != null ||
      packageName != null ||
      iconPath != null ||
      splash != null ||
      clearSplash;

  /// Alias for hasActions to maintain compatibility with legacy code
  bool get hasEnabledActions => hasActions;

  bool get splashAutoPad => _readBool(splashConfig, 'auto_pad') ?? true;

  String? get splashImagePath => _readString(splashConfig, 'image') ?? iconPath;

  String? get splashDarkImagePath =>
      _readString(splashConfig, 'dark_image') ??
      _readString(splashConfig, 'image_dark');

  String? get android12ImagePath =>
      _readString(android12SplashConfig, 'image') ?? splashImagePath;

  String? get android12DarkImagePath =>
      _readString(android12SplashConfig, 'dark_image') ??
      _readString(android12SplashConfig, 'image_dark') ??
      splashDarkImagePath;

  String get splashColor => _readString(splashConfig, 'color') ?? '#FFFFFF';

  String? get splashDarkColor =>
      _readString(splashConfig, 'dark_color') ??
      _readString(splashConfig, 'color_dark');

  String get splashGravity =>
      _readString(splashConfig, 'gravity') ??
      _readString(splashConfig, 'android_gravity') ??
      'center';

  String get splashIOSContentMode =>
      _readString(splashConfig, 'ios_content_mode') ?? 'center';

  String? get splashWebImageMode => _readString(splashConfig, 'web_image_mode');

  bool get splashFullscreen => _readBool(splashConfig, 'fullscreen') ?? false;

  String? get splashBranding => _readString(splashConfig, 'branding');

  String? get splashBrandingDark => _readString(splashConfig, 'branding_dark');

  String? get splashBrandingMode => _readString(splashConfig, 'branding_mode');

  int? get splashBrandingBottomPadding =>
      _readInt(splashConfig, 'branding_bottom_padding');

  String? get splashAndroidScreenOrientation =>
      _readString(splashConfig, 'android_screen_orientation');

  String get android12Color =>
      _readString(android12SplashConfig, 'color') ?? splashColor;

  String? get android12DarkColor =>
      _readString(android12SplashConfig, 'dark_color') ??
      _readString(android12SplashConfig, 'color_dark') ??
      splashDarkColor;

  String? get android12IconBackgroundColor =>
      _readString(android12SplashConfig, 'icon_background_color');

  String? get android12IconBackgroundDarkColor =>
      _readString(android12SplashConfig, 'icon_background_dark_color') ??
      _readString(android12SplashConfig, 'icon_background_color_dark');

  String? get android12Branding =>
      _readString(android12SplashConfig, 'branding');

  String? get android12BrandingDark =>
      _readString(android12SplashConfig, 'branding_dark');

  /// Creates a new [RebrandConfig] instance.
  ///
  /// All data fields (appName, packageName, iconPath, splash) are auto-enabled
  /// if provided. Only clearSplash can explicitly disable splash removal.
  RebrandConfig({
    this.appName,
    this.packageName,
    this.iconPath,
    this.splash,
    this.splashScreenScale = 0.65,
    this.enableAndroid = true,
    this.enableIOS = true,
    this.clearSplash = false,
  });

  /// Creates a [RebrandConfig] instance from a JSON map.
  ///
  /// Simple model: if data is provided, it's automatically enabled.
  /// Optional keys: 'app_name', 'package_name', 'icon_path', 'splash_config'.
  /// Optional flags: 'enable_android', 'enable_ios', 'clear_splash'.
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
      enableAndroid: json['enable_android'] ?? true,
      enableIOS: json['enable_ios'] ?? true,
      clearSplash: json['clear_splash'] ?? false,
    );
  }

  static String? _readString(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  static bool? _readBool(Map<String, dynamic> source, String key) {
    final value = source[key];
    return value is bool ? value : null;
  }

  static int? _readInt(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }
}

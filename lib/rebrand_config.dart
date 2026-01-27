class RebrandConfig {
  final String appName;
  final String packageName;
  final String iconPath;
  final Map<String, dynamic> splash;

  RebrandConfig({
    required this.appName,
    required this.packageName,
    required this.iconPath,
    required this.splash,
  });

  factory RebrandConfig.fromJson(Map<String, dynamic> json) {
    return RebrandConfig(
      appName: json['app_name'],
      packageName: json['package_name'],
      iconPath: json['icon_path'],
      splash: json['splash_config'],
    );
  }
}

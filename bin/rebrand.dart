import 'dart:convert';
import 'dart:io';
import 'package:rebrand_cli/rebrand_config.dart';
import 'package:rebrand_cli/rebrand_service.dart';

/// Entry point for the Rebrand CLI tool.
///
/// This CLI automates the Flutter app rebranding process by:
/// - Validating the Flutter project structure
/// - Reading configuration from `rebrand_config.json`
/// - Updating package names, app labels, and generating assets
/// - Syncing dependencies and cleaning up the project
///
/// The tool must be run from the root directory of a Flutter project
/// and requires a valid `rebrand_config.json` configuration file.
void main() async {
  // ANSI Color Codes
  const cyan = '\x1B[36m';
  const green = '\x1B[32m';
  const white = '\x1B[37m';
  const reset = '\x1B[0m';

  // 1. Welcome Banner
  print('''
$cyan+------------------------------------------+
|          🚀 REBRAND CLI v1.0.5           |
|      Automated Flutter Rebranding        |
+------------------------------------------+$reset
''');

  if (!File('pubspec.yaml').existsSync()) {
    print(
      "🚨 ${white}Error: Please run this inside a Flutter project root.$reset",
    );
    return;
  }

  final configFile = File('rebrand_config.json');
  if (!configFile.existsSync()) {
    print("🚨 ${white}Error: 'rebrand_config.json' not found.$reset");
    print("👉 Create one to get started!");
    return;
  }

  try {
    final configData = jsonDecode(configFile.readAsStringSync());
    final config = RebrandConfig.fromJson(configData);
    final service = RebrandService(config);

    print("$green▶ Target App:$reset ${config.appName}");
    print("$green▶ New ID:$reset     ${config.packageName}");
    print("$cyan------------------------------------------$reset");

    await service.execute();

    print("\n$green✨ SUCCESS: Your project is ready to launch!$reset\n");
  } catch (e) {
    print("\n❌ ${white}Critical Error: $e$reset");
  }
}

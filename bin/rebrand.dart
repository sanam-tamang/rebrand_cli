import 'dart:convert';
import 'dart:io';
import 'package:rebrand_cli/rebrand_config.dart';
import 'package:rebrand_cli/rebrand_service.dart';

void main() async {
  // ANSI Color Codes
  const cyan = '\x1B[36m';
  const green = '\x1B[32m';
  const white = '\x1B[37m';
  const reset = '\x1B[0m';

  // 1. Welcome Banner
  print('''
$cyan+------------------------------------------+
|          🚀 REBRAND CLI v1.0.0           |
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

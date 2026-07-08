import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:rebrand_cli/cli_options.dart';
import 'package:rebrand_cli/rebrand_config.dart';
import 'package:rebrand_cli/rebrand_service.dart';
import 'package:rebrand_cli/rebrand_action.dart';

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
void main(List<String> args) async {
  late final CliOptions options;
  final version = _toolVersion() ?? 'unknown';

  try {
    options = CliOptions.parse(args);
  } on CliArgumentException catch (e) {
    stderr.writeln('🚨 Argument Error: $e');
    stderr.writeln(buildHelpText(executableName: 'rebrand', version: version));
    exit(64);
  }

  if (options.showHelp) {
    print(buildHelpText(executableName: 'rebrand', version: version));
    return;
  }

  if (options.showVersion) {
    print('rebrand_cli v$version');
    return;
  }

  if (options.projectPath != null) {
    Directory.current = options.projectPath!;
  }

  if (options.initCommand) {
    await _handleInitCommand(options);
    return;
  }

  // ANSI Color Codes
  const cyan = '\x1B[36m';
  const green = '\x1B[32m';
  const white = '\x1B[37m';
  const reset = '\x1B[0m';

  // 1. Welcome Banner
  print('''
$cyan+------------------------------------------+
|          🚀 REBRAND CLI v$version           |
|      Automated Flutter Rebranding        |
+------------------------------------------+$reset
''');

  if (!File('pubspec.yaml').existsSync()) {
    print(
      "🚨 ${white}Error: Please run this inside a Flutter project root.$reset",
    );
    return;
  }

  final configFile = File(options.configPath);
  if (!configFile.existsSync()) {
    print(
      "🚨 ${white}Error: Config file not found at '${options.configPath}'.$reset",
    );
    print("👉 Create one to get started!");
    return;
  }

  try {
    final configData = jsonDecode(configFile.readAsStringSync());
    if (configData is! Map) {
      throw const FormatException(
        'Configuration file must contain a top-level JSON object.',
      );
    }

    final config = RebrandConfig.fromJson(
      Map<String, dynamic>.from(configData),
    );

    final selectedActions = <RebrandAction>{
      if (options.renameOnly) RebrandAction.rename,
      if (options.labelOnly) RebrandAction.label,
      if (options.launcherOnly) RebrandAction.launcher,
      if (options.splashOnly) RebrandAction.splash,
    };

    final service = RebrandService(
      config,
      selectedActions: selectedActions.isEmpty ? null : selectedActions,
    );

    print("$green▶ Target App:$reset ${config.appName}");
    print("$green▶ New ID:$reset     ${config.packageName}");
    print("$green▶ Config File:$reset ${configFile.path}");
    print("$cyan------------------------------------------$reset");

    await service.execute();

    print("\n$green✨ SUCCESS: Your project is ready to launch!$reset\n");
  } catch (e) {
    print("\n❌ ${white}Critical Error: $e$reset");
    exit(1);
  }
}

Future<void> _handleInitCommand(CliOptions options) async {
  final configFile = File(options.configPath);
  final targetPath = configFile.path;

  if (configFile.existsSync() && !options.forceOverwrite) {
    stderr.writeln(
      'ℹ️ Config file already exists at $targetPath. Re-run with --force to overwrite it.',
    );
    return;
  }

  if (!configFile.parent.existsSync()) {
    configFile.parent.createSync(recursive: true);
  }

  final template = options.initFull
      ? _fullConfigTemplate()
      : _minimalConfigTemplate();
  configFile.writeAsStringSync(template);

  final mode = options.initFull ? 'full' : 'minimal';
  stdout.writeln('✅ Created $mode rebrand config at $targetPath');
}

String _minimalConfigTemplate() => '''{
  "app_name": "My New App",
  "package_name": "com.example.mynewapp",
  "icon_path": "assets/logo.png",
  "splash_config": {
    "color": "#FFFFFF",
    "image": "assets/logo.png"
  }
}
''';

String _fullConfigTemplate() => '''{
  "app_name": "My New App",
  "package_name": "com.example.mynewapp",
  "icon_path": "assets/logo.png",
  "enable_android": true,
  "enable_ios": true,
  "clear_splash": false,
  "splash_config": {
    "color": "#FFFFFF",
    "dark_color": "#111111",
    "image": "assets/logo.png",
    "dark_image": "assets/logo_dark.png",
    "gravity": "center",
    "ios_content_mode": "center",
    "fullscreen": false,
    "branding": "assets/branding.png",
    "branding_dark": "assets/branding_dark.png",
    "branding_mode": "bottom",
    "branding_bottom_padding": 24,
    "scaling": 0.7,
    "auto_pad": true,
    "android_12": {
      "color": "#FFFFFF",
      "dark_color": "#111111",
      "image": "assets/logo.png",
      "dark_image": "assets/logo_dark.png",
      "icon_background_color": "#FFFFFF",
      "icon_background_color_dark": "#000000",
      "branding": "assets/branding.png",
      "branding_dark": "assets/branding_dark.png"
    }
  }
}
''';

String? _toolVersion() {
  try {
    final script = File.fromUri(Platform.script);
    final packageRoot = script.parent.parent;
    final pubspecFile = File(p.join(packageRoot.path, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      return null;
    }

    final content = pubspecFile.readAsStringSync();
    final match = RegExp(
      r'^version:\s*([\d\.\-\+]+)',
      multiLine: true,
    ).firstMatch(content);
    return match?.group(1);
  } catch (_) {
    return null;
  }
}

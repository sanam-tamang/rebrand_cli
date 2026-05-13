/// Thrown when the CLI receives invalid or malformed arguments.
class CliArgumentException implements Exception {
  final String message;

  const CliArgumentException(this.message);

  @override
  String toString() => message;
}

/// Parsed command-line options for the Rebrand CLI.
///
/// Includes path selection, config file path, help/version flags, and explicit
/// action flags such as `--rename`, `--label`, `--launcher`, and `--splash`.
class CliOptions {
  final String? projectPath;
  final String configPath;
  final bool showHelp;
  final bool showVersion;
  final bool renameOnly;
  final bool labelOnly;
  final bool launcherOnly;
  final bool splashOnly;

  const CliOptions({
    this.projectPath,
    this.configPath = 'rebrand_config.json',
    this.showHelp = false,
    this.showVersion = false,
    this.renameOnly = false,
    this.labelOnly = false,
    this.launcherOnly = false,
    this.splashOnly = false,
  });

  factory CliOptions.parse(List<String> args) {
    String? projectPath;
    var configPath = 'rebrand_config.json';
    var showHelp = false;
    var showVersion = false;
    var renameOnly = false;
    var labelOnly = false;
    var launcherOnly = false;
    var splashOnly = false;

    for (var i = 0; i < args.length; i++) {
      final arg = args[i];

      if (arg == '-h' || arg == '--help') {
        showHelp = true;
        continue;
      }

      if (arg == '-v' || arg == '--version') {
        showVersion = true;
        continue;
      }

      if (arg == '--rename') {
        renameOnly = true;
        continue;
      }

      if (arg == '--label' || arg == '--app-name') {
        labelOnly = true;
        continue;
      }

      if (arg == '--launcher') {
        launcherOnly = true;
        continue;
      }

      if (arg == '--splash') {
        splashOnly = true;
        continue;
      }

      if (arg == '-p' || arg == '--project') {
        if (i + 1 >= args.length) {
          throw const CliArgumentException('Missing value for --project.');
        }
        projectPath = _assignProjectPath(projectPath, args[++i]);
        continue;
      }

      if (arg.startsWith('--project=')) {
        final value = arg.substring('--project='.length);
        if (value.isEmpty) {
          throw const CliArgumentException('Missing value for --project.');
        }
        projectPath = _assignProjectPath(projectPath, value);
        continue;
      }

      if (arg == '-c' || arg == '--config') {
        if (i + 1 >= args.length) {
          throw const CliArgumentException('Missing value for --config.');
        }
        configPath = args[++i];
        continue;
      }

      if (arg.startsWith('--config=')) {
        final value = arg.substring('--config='.length);
        if (value.isEmpty) {
          throw const CliArgumentException('Missing value for --config.');
        }
        configPath = value;
        continue;
      }

      if (arg.startsWith('-')) {
        throw CliArgumentException('Unknown option: $arg');
      }

      projectPath = _assignProjectPath(projectPath, arg);
    }

    return CliOptions(
      projectPath: projectPath,
      configPath: configPath,
      showHelp: showHelp,
      showVersion: showVersion,
      renameOnly: renameOnly,
      labelOnly: labelOnly,
      launcherOnly: launcherOnly,
      splashOnly: splashOnly,
    );
  }

  static String _assignProjectPath(String? currentValue, String nextValue) {
    if (currentValue != null) {
      throw const CliArgumentException(
        'Project path was provided more than once.',
      );
    }

    return nextValue;
  }
}

String buildHelpText({
  required String executableName,
  required String version,
}) {
  return '''
Rebrand CLI v$version

Usage:
  $executableName [project_path]
  $executableName --project <path> [--config <path>]

Options:
  -h, --help
      Show usage information and full descriptions for each command.
  -v, --version
      Print the CLI package version.
  -p, --project <path>
      Path to the Flutter project root to update.
  -c, --config <path>
      Load a custom JSON config file instead of the default rebrand_config.json.
  --rename
      Rename the Android/iOS package identifier only. Uses package_name from the config.
  --label, --app-name
      Update the app display name only. Uses app_name from the config.
  --launcher
      Generate launcher icon assets only. Uses icon_path from the config.
  --splash
      Generate native splash screens only. Uses splash_config or icon_path from the config.

Notes:
  If no explicit action flags are passed, the CLI will perform all actions available in the config.
  If explicit flags are provided, only the requested task(s) will run.

Examples:
  $executableName
  $executableName .
  $executableName --project ./example --config ./example/rebrand_config.json
''';
}

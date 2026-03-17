class CliArgumentException implements Exception {
  final String message;

  const CliArgumentException(this.message);

  @override
  String toString() => message;
}

class CliOptions {
  final String? projectPath;
  final String configPath;
  final bool showHelp;
  final bool showVersion;

  const CliOptions({
    this.projectPath,
    this.configPath = 'rebrand_config.json',
    this.showHelp = false,
    this.showVersion = false,
  });

  factory CliOptions.parse(List<String> args) {
    String? projectPath;
    var configPath = 'rebrand_config.json';
    var showHelp = false;
    var showVersion = false;

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

      if (arg == '-p' || arg == '--project') {
        if (i + 1 >= args.length) {
          throw const CliArgumentException(
            'Missing value for --project.',
          );
        }
        projectPath = _assignProjectPath(projectPath, args[++i]);
        continue;
      }

      if (arg.startsWith('--project=')) {
        final value = arg.substring('--project='.length);
        if (value.isEmpty) {
          throw const CliArgumentException(
            'Missing value for --project.',
          );
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

String buildHelpText({required String executableName, required String version}) {
  return '''
Rebrand CLI v$version

Usage:
  $executableName [project_path]
  $executableName --project <path> [--config <path>]

Options:
  -h, --help       Show usage information.
  -v, --version    Show the CLI version.
  -p, --project    Flutter project root to rebrand.
  -c, --config     Path to the JSON config file.

Examples:
  $executableName
  $executableName .
  $executableName --project ./example --config ./example/rebrand_config.json
''';
}
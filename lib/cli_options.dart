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
  final bool initCommand;
  final bool initFull;
  final bool forceOverwrite;

  const CliOptions({
    this.projectPath,
    this.configPath = 'rebrand_config.json',
    this.showHelp = false,
    this.showVersion = false,
    this.renameOnly = false,
    this.labelOnly = false,
    this.launcherOnly = false,
    this.splashOnly = false,
    this.initCommand = false,
    this.initFull = false,
    this.forceOverwrite = false,
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
    var initCommand = false;
    var initFull = false;
    var forceOverwrite = false;

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

      if (arg == 'init') {
        initCommand = true;
        continue;
      }

      if (arg == '--full') {
        initFull = true;
        continue;
      }

      if (arg == '--force') {
        forceOverwrite = true;
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
        throw CliArgumentException(_suggestOption(arg));
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
      initCommand: initCommand,
      initFull: initFull,
      forceOverwrite: forceOverwrite,
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

  static String _suggestOption(String arg) {
    final suggestions = <String, String>{
      '--appname': '--app-name (or --label)',
      '--app_name': '--app-name (or --label)',
      '-appname': '--app-name (or --label)',
      '--label-name': '--app-name (or --label)',
      '--app': '--app-name (or --label)',
      '--icon': '--launcher',
      '--icons': '--launcher',
      '--icon-only': '--launcher',
      '--screen': '--splash',
      '--splash-only': '--splash',
      '--package': '--rename',
      '--package-only': '--rename',
      '--rename-only': '--rename',
      '--rename-package': '--rename',
      '--version-only': '--version',
      '-version': '--version',
      '--h': '-h (or --help)',
      '-help': '-h (or --help)',
      '--v': '-v (or --version)',
      '-proj': '-p (or --project)',
      '--proj': '--project',
      '-cfg': '-c (or --config)',
      '--cfg': '--config',
    };

    if (suggestions.containsKey(arg)) {
      return 'Unknown option: $arg\n💡 Did you mean: ${suggestions[arg]}?';
    }

    // Fuzzy match against known flags
    final known = [
      '-h',
      '--help',
      '-v',
      '--version',
      '-p',
      '--project',
      '-c',
      '--config',
      '--rename',
      '--label',
      '--app-name',
      '--launcher',
      '--splash',
      'init',
      '--full',
      '--force',
    ];

    final similar = _findSimilarFlags(arg, known);
    if (similar.isNotEmpty) {
      return 'Unknown option: $arg\n💡 Did you mean: ${similar.join(' or ')}?';
    }

    return 'Unknown option: $arg';
  }

  static List<String> _findSimilarFlags(String input, List<String> known) {
    final matches = <String>[];
    final normalized = input.toLowerCase();

    for (final flag in known) {
      // Exact substring match
      if (flag.contains(normalized) || normalized.contains(flag)) {
        matches.add(flag);
        continue;
      }

      // Levenshtein-like: if removed or added 1-2 chars would match
      if (_isSimilar(normalized, flag.toLowerCase())) {
        matches.add(flag);
      }
    }

    return matches.take(2).toList(); // Return up to 2 best matches
  }

  static bool _isSimilar(String a, String b) {
    // Remove common prefixes/suffixes and check similarity
    final aClean = a.replaceAll(RegExp(r'[-_]'), '');
    final bClean = b.replaceAll(RegExp(r'[-_]'), '');

    if (aClean.isEmpty || bClean.isEmpty) return false;

    // Check if one is a prefix or suffix of the other (off by 1-2 chars)
    final maxLen = aClean.length > bClean.length
        ? aClean.length
        : bClean.length;
    final minLen = aClean.length < bClean.length
        ? aClean.length
        : bClean.length;
    final diff = maxLen - minLen;

    if (diff > 2) return false;

    final overlapLen = minLen - diff;
    if (overlapLen <= 0) return false;

    return aClean.startsWith(bClean.substring(0, overlapLen)) ||
        bClean.startsWith(aClean.substring(0, overlapLen));
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
  init
      Create a starter rebrand_config.json template. Uses a minimal example by default.
  --full
      Generate the full example config template when used with init.
  --force
      Overwrite an existing config file when used with init.
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
  $executableName init
  $executableName init --full
  $executableName init --force
  $executableName --project ./example --config ./example/rebrand_config.json
''';
}

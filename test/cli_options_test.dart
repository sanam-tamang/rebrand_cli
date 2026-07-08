import 'package:rebrand_cli/cli_options.dart';
import 'package:test/test.dart';

void main() {
  group('CliOptions.parse', () {
    test('supports positional project path', () {
      final options = CliOptions.parse(['./example']);

      expect(options.projectPath, './example');
      expect(options.configPath, 'rebrand_config.json');
    });

    test('supports named project and config options', () {
      final options = CliOptions.parse([
        '--project',
        './example',
        '--config',
        './example/rebrand_config.json',
      ]);

      expect(options.projectPath, './example');
      expect(options.configPath, './example/rebrand_config.json');
    });

    test('throws on unknown flag', () {
      expect(
        () => CliOptions.parse(['--wat']),
        throwsA(isA<CliArgumentException>()),
      );
    });

    test('supports explicit action flags', () {
      final options = CliOptions.parse([
        '--rename',
        '--label',
        '--launcher',
        '--splash',
      ]);

      expect(options.renameOnly, isTrue);
      expect(options.labelOnly, isTrue);
      expect(options.launcherOnly, isTrue);
      expect(options.splashOnly, isTrue);
    });

    test('supports --app-name alias for label-only', () {
      final options = CliOptions.parse(['--app-name']);

      expect(options.labelOnly, isTrue);
    });

    test('supports init subcommand with full and force flags', () {
      final options = CliOptions.parse(['init', '--full', '--force']);

      expect(options.initCommand, isTrue);
      expect(options.initFull, isTrue);
      expect(options.forceOverwrite, isTrue);
    });
  });
}

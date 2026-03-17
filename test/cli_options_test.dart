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
  });
}
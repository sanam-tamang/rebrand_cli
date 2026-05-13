import 'dart:io';

import 'package:rebrand_cli/rebrand_action.dart';
import 'package:rebrand_cli/rebrand_config.dart';
import 'package:rebrand_cli/tasks/validation_task.dart';
import 'package:test/test.dart';

void main() {
  group('ValidationTask', () {
    late Directory testDir;
    late String splashPath;
    late String darkSplashPath;
    late String brandingPath;

    setUp(() {
      testDir = Directory.systemTemp.createTempSync('rebrand_validation_test_');
      splashPath = '${testDir.path}/splash.png';
      darkSplashPath = '${testDir.path}/dark_splash.png';
      brandingPath = '${testDir.path}/branding.png';

      if (testDir.existsSync()) {
        testDir.deleteSync(recursive: true);
      }
      testDir.createSync(recursive: true);

      File(splashPath).writeAsBytesSync([0, 1, 2]);
      File(darkSplashPath).writeAsBytesSync([0, 1, 2]);
      File(brandingPath).writeAsBytesSync([0, 1, 2]);
    });

    tearDown(() {
      if (testDir.existsSync()) {
        testDir.deleteSync(recursive: true);
      }
    });

    test('fails when no actions are provided', () async {
      final config = RebrandConfig();

      final task = ValidationTask(config);

      expect(task.execute(), throwsA(isA<String>()));
    });

    test('allows splash-only configuration', () async {
      final config = RebrandConfig(
        splash: {
          'image': splashPath,
          'dark_image': darkSplashPath,
          'branding': brandingPath,
          'color': '#FFFFFF',
          'dark_color': '#111111',
          'gravity': 'center',
          'ios_content_mode': 'center',
        },
      );

      await ValidationTask(config).execute();
    });

    test(
      'allows rename-only validation with unrelated icon path missing',
      () async {
        final config = RebrandConfig(packageName: 'com.example.app');

        await ValidationTask(
          config,
          actions: {RebrandAction.rename},
          explicitActions: true,
        ).execute();
      },
    );

    test('allows label-only validation with explicit app-name flag', () async {
      final config = RebrandConfig(appName: 'My App');

      await ValidationTask(
        config,
        actions: {RebrandAction.label},
        explicitActions: true,
      ).execute();
    });

    test(
      'fails on invalid splash scaling when auto padding is enabled',
      () async {
        final config = RebrandConfig(
          splashScreenScale: 2,
          splash: {'image': splashPath},
        );

        expect(ValidationTask(config).execute(), throwsA(isA<String>()));
      },
    );
  });
}

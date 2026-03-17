import 'dart:io';

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

    test('fails when no actions are enabled', () async {
      final config = RebrandConfig(
        enableSplash: false,
        enableLauncherIcon: false,
        enablePackageRename: false,
        enableAppLabel: false,
      );

      final task = ValidationTask(config);

      expect(task.execute(), throwsA(isA<String>()));
    });

    test('allows splash-only configuration without icon_path', () async {
      final config = RebrandConfig(
        enableSplash: true,
        enableLauncherIcon: false,
        enablePackageRename: false,
        enableAppLabel: false,
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
      'fails on invalid splash scaling when auto padding is enabled',
      () async {
        final config = RebrandConfig(
          splashScreenScale: 2,
          enableSplash: true,
          enableLauncherIcon: false,
          enablePackageRename: false,
          enableAppLabel: false,
          splash: {'image': splashPath},
        );

        expect(ValidationTask(config).execute(), throwsA(isA<String>()));
      },
    );
  });
}

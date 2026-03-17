import 'dart:io';
import 'package:image/image.dart';
import 'package:rebrand_cli/rebrand_config.dart';
import 'package:rebrand_cli/tasks/asset_generation_task.dart';
import 'package:test/test.dart';

void main() {
  group('AssetGenerationTask', () {
    late Directory testDir;
    late String iconPath;

    setUp(() {
      testDir = Directory.systemTemp.createTempSync('rebrand_asset_test_');
      iconPath = '${testDir.path}/logo.png';

      if (testDir.existsSync()) {
        testDir.deleteSync(recursive: true);
      }
      testDir.createSync(recursive: true);

      // Create a dummy 1024x1024 icon
      final image = Image(width: 1024, height: 1024);
      fillRect(
        image,
        x1: 0,
        y1: 0,
        x2: 1023,
        y2: 1023,
        color: ColorRgb8(255, 0, 0),
      );
      File(iconPath).writeAsBytesSync(encodePng(image));
    });

    tearDown(() {
      if (testDir.existsSync()) {
        testDir.deleteSync(recursive: true);
      }
    });

    test('processImage should return a correctly padded and resized image', () {
      final processedImage = AssetGenerationTask.processImage(iconPath);

      expect(processedImage, isNotNull);
      expect(processedImage.width, 1152);
      expect(processedImage.height, 1152);

      // Optional: More advanced check to ensure the original image is centered.
      // We can check a corner pixel to see if it's transparent.
      final cornerPixel = processedImage.getPixel(0, 0);
      expect(cornerPixel.a, 0);
    });

    test('buildSplashYaml should include custom splash options', () {
      final config = RebrandConfig(
        iconPath: iconPath,
        splash: {
          'color': '#FFFFFF',
          'dark_color': '#111111',
          'gravity': 'bottom',
          'ios_content_mode': 'scaleAspectFit',
          'fullscreen': true,
          'branding': 'assets/branding.png',
          'branding_mode': 'bottom',
          'branding_bottom_padding': 24,
          'android_12': {
            'color': '#EEEEEE',
            'dark_color': '#000000',
            'icon_background_color': '#123456',
          },
        },
      );

      final yaml = AssetGenerationTask.buildSplashYaml(
        config,
        imagePath: 'processed/light.png',
        darkImagePath: 'processed/dark.png',
        android12ImagePath: 'processed/android12.png',
        android12DarkImagePath: 'processed/android12_dark.png',
      );

      expect(yaml, contains('image: "processed/light.png"'));
      expect(yaml, contains('color_dark: "#111111"'));
      expect(yaml, contains('android_gravity: "bottom"'));
      expect(yaml, contains('ios_content_mode: "scaleAspectFit"'));
      expect(yaml, contains('fullscreen: true'));
      expect(yaml, contains('branding: "assets/branding.png"'));
      expect(yaml, contains('branding_bottom_padding: 24'));
      expect(yaml, contains('android_12:'));
      expect(yaml, contains('icon_background_color: "#123456"'));
    });
  });
}

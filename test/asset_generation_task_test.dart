import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart';
import 'package:rebrand_cli/tasks/asset_generation_task.dart';
import 'package:test/test.dart';

void main() {
  group('AssetGenerationTask', () {
    final testDir = Directory('test/output');
    final iconPath = '${testDir.path}/logo.png';

    setUp(() {
      if (testDir.existsSync()) {
        testDir.deleteSync(recursive: true);
      }
      testDir.createSync(recursive: true);

      // Create a dummy 1024x1024 icon
      final image = Image(width: 1024, height: 1024);
      fillRect(image, x1: 0, y1: 0, x2: 1023, y2: 1023, color: ColorRgb8(255, 0, 0));
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
  });
}

import 'dart:io';
import 'package:image/image.dart' as img;
import '../rebrand_config.dart';
import 'rebrand_task.dart';

class AssetGenerationTask extends RebrandTask {
  final RebrandConfig config;

  AssetGenerationTask(this.config);

  @override
  String get name => "Generating Icons & Splash (with Safe-Zone Logic)";

  static img.Image processImage(String iconPath, {double scaling = 0.65}) {
    final bytes = File(iconPath).readAsBytesSync();
    final original = img.decodeImage(bytes);

    if (original == null) {
      throw "Could not decode splash image.";
    }

    // LOGIC: Create a 1152x1152 canvas (Android 12 requirement)
    // We scale the logo to the requested percentage (default 65%) of the canvas
    // to ensure it's inside the 'Safe Zone' circle.
    final canvasSize = 1152;
    final targetLogoSize = (canvasSize * scaling).toInt();

    final resizedLogo = img.copyResize(
      original,
      width: targetLogoSize,
      height: targetLogoSize,
    );
    final canvas = img.Image(
      width: canvasSize,
      height: canvasSize,
      numChannels: 4,
    );

    // Center the logo on the transparent canvas
    final offset = (canvasSize - targetLogoSize) ~/ 2;
    img.compositeImage(canvas, resizedLogo, dstX: offset, dstY: offset);

    return canvas;
  }

  @override
  Future<void> execute() async {
    // Extract scaling from config, default to 0.65 if not present
    final double scaling =
        (config.splash['scaling'] as num?)?.toDouble() ?? 0.65;

    final processedImage = processImage(config.iconPath, scaling: scaling);

    // Save the processed image for the native generators to use
    final processedPath = 'rebrand_processed_asset.png';
    File(processedPath).writeAsBytesSync(img.encodePng(processedImage));

    // Generate the splash using the perfectly padded image
    await _writeAndRunSplash(processedPath);

    // Cleanup the temporary processed image
    if (File(processedPath).existsSync()) {
      File(processedPath).deleteSync();
    }
  }

  Future<void> _writeAndRunSplash(String imagePath) async {
    final tempYaml = File('rebrand_temp.yaml');
    final color = config.splash['color'] ?? "#FFFFFF";

    tempYaml.writeAsStringSync('''
flutter_native_splash:
  color: "$color"
  image: "$imagePath"
  android_gravity: center
  ios_content_mode: center
  android: true
  ios: true
  android_12:
    image: "$imagePath"
    color: "$color"
''');

    final result = await Process.run('dart', [
      'run',
      'flutter_native_splash:create',
      '--path=rebrand_temp.yaml',
    ], runInShell: true);
    if (result.exitCode != 0) {
      throw "Failed to generate splash screen: ${result.stderr}";
    }

    tempYaml.deleteSync();
  }
}

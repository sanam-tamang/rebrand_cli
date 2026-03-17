import 'dart:io';
import 'package:image/image.dart' as img;
import '../rebrand_config.dart';
import 'rebrand_task.dart';

class AssetGenerationTask extends RebrandTask {
  final RebrandConfig config;

  AssetGenerationTask(this.config);

  @override
  String get name => "Generating Icons & Splash (with Safe-Zone Logic)";

  static String buildLauncherIconYaml(RebrandConfig config, String imagePath) {
    final lines = <String>['flutter_launcher_icons:'];

    _addYamlLine(
      lines,
      'android',
      config.enableAndroid ? 'launcher_icon' : false,
      indent: 2,
    );
    _addYamlLine(lines, 'ios', config.enableIOS, indent: 2);
    _addYamlLine(lines, 'image_path', imagePath, indent: 2);
    _addYamlLine(lines, 'min_sdk_android', 21, indent: 2);
    _addYamlLine(
      lines,
      'adaptive_icon_background',
      config.splashColor,
      indent: 2,
    );
    _addYamlLine(lines, 'adaptive_icon_foreground', imagePath, indent: 2);

    return '${lines.join('\n')}\n';
  }

  static String buildSplashYaml(
    RebrandConfig config, {
    required String imagePath,
    String? darkImagePath,
    required String android12ImagePath,
    String? android12DarkImagePath,
  }) {
    final lines = <String>['flutter_native_splash:'];

    _addYamlLine(lines, 'color', config.splashColor, indent: 2);
    _addYamlLine(lines, 'image', imagePath, indent: 2);
    _addYamlLine(lines, 'android_gravity', config.splashGravity, indent: 2);
    _addYamlLine(
      lines,
      'ios_content_mode',
      config.splashIOSContentMode,
      indent: 2,
    );
    _addYamlLine(lines, 'android', config.enableAndroid, indent: 2);
    _addYamlLine(lines, 'ios', config.enableIOS, indent: 2);
    _addYamlLine(lines, 'fullscreen', config.splashFullscreen, indent: 2);

    if (config.splashDarkColor != null) {
      _addYamlLine(lines, 'color_dark', config.splashDarkColor!, indent: 2);
    }
    if (darkImagePath != null) {
      _addYamlLine(lines, 'image_dark', darkImagePath, indent: 2);
    }
    if (config.splashWebImageMode != null) {
      _addYamlLine(
        lines,
        'web_image_mode',
        config.splashWebImageMode!,
        indent: 2,
      );
    }
    if (config.splashBranding != null) {
      _addYamlLine(lines, 'branding', config.splashBranding!, indent: 2);
    }
    if (config.splashBrandingDark != null) {
      _addYamlLine(
        lines,
        'branding_dark',
        config.splashBrandingDark!,
        indent: 2,
      );
    }
    if (config.splashBrandingMode != null) {
      _addYamlLine(
        lines,
        'branding_mode',
        config.splashBrandingMode!,
        indent: 2,
      );
    }
    if (config.splashBrandingBottomPadding != null) {
      _addYamlLine(
        lines,
        'branding_bottom_padding',
        config.splashBrandingBottomPadding!,
        indent: 2,
      );
    }
    if (config.splashAndroidScreenOrientation != null) {
      _addYamlLine(
        lines,
        'android_screen_orientation',
        config.splashAndroidScreenOrientation!,
        indent: 2,
      );
    }

    if (config.enableAndroid) {
      lines.add('  android_12:');
      _addYamlLine(lines, 'color', config.android12Color, indent: 4);
      _addYamlLine(lines, 'image', android12ImagePath, indent: 4);

      if (config.android12DarkColor != null) {
        _addYamlLine(
          lines,
          'color_dark',
          config.android12DarkColor!,
          indent: 4,
        );
      }
      if (android12DarkImagePath != null) {
        _addYamlLine(lines, 'image_dark', android12DarkImagePath, indent: 4);
      }
      if (config.android12IconBackgroundColor != null) {
        _addYamlLine(
          lines,
          'icon_background_color',
          config.android12IconBackgroundColor!,
          indent: 4,
        );
      }
      if (config.android12IconBackgroundDarkColor != null) {
        _addYamlLine(
          lines,
          'icon_background_color_dark',
          config.android12IconBackgroundDarkColor!,
          indent: 4,
        );
      }
      if (config.android12Branding != null) {
        _addYamlLine(lines, 'branding', config.android12Branding!, indent: 4);
      }
      if (config.android12BrandingDark != null) {
        _addYamlLine(
          lines,
          'branding_dark',
          config.android12BrandingDark!,
          indent: 4,
        );
      }
    }

    return '${lines.join('\n')}\n';
  }

  static void _addYamlLine(
    List<String> lines,
    String key,
    Object value, {
    required int indent,
  }) {
    final padding = ' ' * indent;
    if (value is num || value is bool) {
      lines.add('$padding$key: $value');
      return;
    }

    final escapedValue = value.toString().replaceAll('"', '\\"');
    lines.add('$padding$key: "$escapedValue"');
  }

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
    final tempFiles = <String>[];

    try {
      if (config.enableSplash) {
        final splashImagePath = _prepareSplashImage(
          config.splashImagePath,
          'rebrand_processed_splash.png',
          tempFiles,
        );
        final splashDarkImagePath = _prepareSplashImage(
          config.splashDarkImagePath,
          'rebrand_processed_splash_dark.png',
          tempFiles,
        );
        final android12ImagePath = _prepareSplashImage(
          config.android12ImagePath,
          'rebrand_processed_android12_splash.png',
          tempFiles,
        );
        final android12DarkImagePath = _prepareSplashImage(
          config.android12DarkImagePath,
          'rebrand_processed_android12_splash_dark.png',
          tempFiles,
        );

        if (splashImagePath != null && android12ImagePath != null) {
          await _writeAndRunSplash(
            imagePath: splashImagePath,
            darkImagePath: splashDarkImagePath,
            android12ImagePath: android12ImagePath,
            android12DarkImagePath: android12DarkImagePath,
          );
        }
      }

      if (config.enableLauncherIcon && config.iconPath != null) {
        await _writeAndRunIcons(config.iconPath!);
      }
    } finally {
      for (final path in tempFiles) {
        final file = File(path);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
    }
  }

  String? _prepareSplashImage(
    String? sourcePath,
    String outputPath,
    List<String> tempFiles,
  ) {
    if (sourcePath == null) {
      return null;
    }

    if (!config.splashAutoPad) {
      return sourcePath;
    }

    final processedImage = processImage(
      sourcePath,
      scaling: config.splashScreenScale,
    );
    File(outputPath).writeAsBytesSync(img.encodePng(processedImage));
    tempFiles.add(outputPath);
    return outputPath;
  }

  Future<void> _writeAndRunIcons(String imagePath) async {
    final tempYaml = File('rebrand_icons_temp.yaml');
    tempYaml.writeAsStringSync(buildLauncherIconYaml(config, imagePath));

    final result = await Process.run('dart', [
      'run',
      'flutter_launcher_icons',
      '-f',
      'rebrand_icons_temp.yaml',
    ], runInShell: true);

    if (result.exitCode != 0) {
      throw "Failed to generate launcher icons: ${result.stderr}";
    }

    tempYaml.deleteSync();
  }

  Future<void> _writeAndRunSplash({
    required String imagePath,
    String? darkImagePath,
    required String android12ImagePath,
    String? android12DarkImagePath,
  }) async {
    final tempYaml = File('rebrand_temp.yaml');
    tempYaml.writeAsStringSync(
      buildSplashYaml(
        config,
        imagePath: imagePath,
        darkImagePath: darkImagePath,
        android12ImagePath: android12ImagePath,
        android12DarkImagePath: android12DarkImagePath,
      ),
    );

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

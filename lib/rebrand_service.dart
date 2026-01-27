import 'dart:io';
import 'rebrand_config.dart';

class RebrandService {
  final RebrandConfig config;

  RebrandService(this.config);

  Future<void> execute() async {
    // 1. Setup Environment & Workers
    await _setupDependencies();

    // 2. Change Package ID (Native Bundle IDs)
    await _run(
      'dart run change_app_package_name:main ${config.packageName}',
      "Updating Package ID",
    );

    // 3. Update Android Labels
    _updateAndroidName(config.appName);

    // 4. Update iOS Labels
    _updateIosName(config.appName);

    // 5. Generate Assets (Icons & Splash)
    await _generateAssets();

    // 6. Project Cleanup
    await _run('flutter clean', "Performing Final Cleanup");

    // 7. Sync Dependencies (Fixes the 'red squiggly lines' in IDE)
    await _run('flutter pub get', "Re-syncing Project Dependencies");

    // 8. iOS Pod Sync (Only runs on Mac)
    if (Platform.isMacOS) {
      final podFile = File('ios/Podfile');
      if (podFile.existsSync()) {
        await _runPodInstall();
      }
    }

    print("\n✅ Project is synced and ready!");
  }

  // Specialized helper for iOS Pods
  Future<void> _runPodInstall() async {
    print("🔹 Syncing iOS CocoaPods...");
    // We use Directory changes because Process.run starts from the root
    final result = await Process.run(
      'pod',
      ['install'],
      workingDirectory: 'ios',
      runInShell: true,
    );

    if (result.exitCode != 0) {
      print(
        "⚠️ Warning: CocoaPods sync failed. You may need to run 'pod install' manually.",
      );
    } else {
      print("✅ iOS Pods synced.");
    }
  }

  Future<void> _setupDependencies() async {
    print("📦 Validating Worker Packages...");
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final workers = [
      'change_app_package_name',
      'flutter_launcher_icons',
      'flutter_native_splash',
    ];

    final missing = workers.where((w) => !pubspec.contains(w)).toList();
    if (missing.isNotEmpty) {
      print("🔹 Auto-installing: ${missing.join(', ')}");
      await Process.run('flutter', [
        'pub',
        'add',
        '--dev',
        ...missing,
      ], runInShell: true);
    }
  }

  void _updateAndroidName(String name) {
    print("🤖 Updating Android App Label...");
    final manifest = File('android/app/src/main/AndroidManifest.xml');
    if (manifest.existsSync()) {
      var content = manifest.readAsStringSync();
      // Replace hardcoded label or string reference
      content = content.replaceAll(
        RegExp(r'android:label="[^"]*"'),
        'android:label="$name"',
      );
      manifest.writeAsStringSync(content);
    }
  }

  void _updateIosName(String name) {
    print("🍎 Updating iOS App Name...");
    final plist = File('ios/Runner/Info.plist');
    if (plist.existsSync()) {
      var content = plist.readAsStringSync();
      // Update CFBundleName
      content = content.replaceAll(
        RegExp(r'<key>CFBundleName</key>\s*<string>[^<]*</string>'),
        '<key>CFBundleName</key>\n\t<string>$name</string>',
      );
      // Update CFBundleDisplayName
      content = content.replaceAll(
        RegExp(r'<key>CFBundleDisplayName</key>\s*<string>[^<]*</string>'),
        '<key>CFBundleDisplayName</key>\n\t<string>$name</string>',
      );
      plist.writeAsStringSync(content);
    }
  }

  Future<void> _generateAssets() async {
    final tempYaml = File('rebrand_temp.yaml');

    // 1. VALIDATE IMAGE PATH
    final imageFile = File(config.iconPath);
    if (!imageFile.existsSync()) {
      print("❌ Error: Splash image not found at ${config.iconPath}");
      exit(1);
    }

    // 2. EXTRACT COLORS WITH FALLBACKS
    final splashColor = config.splash['color'] ?? "#FFFFFF";
    final splashImage = config.splash['image'] ?? config.iconPath;

    print("🔹 Creating temp configuration...");
    tempYaml.writeAsStringSync('''
flutter_native_splash:
  color: "$splashColor"
  image: "$splashImage"
  android: true
  ios: true
  # Android 12 support (Crucial for modern phones)
  android_12:
    color: "$splashColor"
    image: "$splashImage"
''');

    // 3. RUN WITH ERROR CAPTURING
    await _run(
      'dart run flutter_native_splash:create --path=rebrand_temp.yaml',
      "Generating Splash Screens",
    );

    if (tempYaml.existsSync()) tempYaml.deleteSync();
  }

  Future<void> _run(String cmd, String desc) async {
    print("🔹 $desc...");
    final parts = cmd.split(' ');
    final result = await Process.run(
      parts[0],
      parts.sublist(1),
      runInShell: true,
    );

    if (result.exitCode != 0) {
      print("❌ Command Failed: $cmd");
      print("STDOUT: ${result.stdout}"); // See normal output
      print("STDERR: ${result.stderr}"); // SEE THE ACTUAL ERROR HERE
      exit(1);
    }
  }
}

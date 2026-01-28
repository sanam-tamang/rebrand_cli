import 'dart:io';
import 'rebrand_config.dart';

/// Service class responsible for orchestrating the Flutter app rebranding process.
///
/// This service handles the complete rebranding workflow including:
/// - Installing required dependencies
/// - Updating package names and bundle IDs
/// - Modifying native app labels for Android and iOS
/// - Generating app icons and splash screens
/// - Syncing project dependencies and CocoaPods
///
/// The service operates on a [RebrandConfig] instance that contains all
/// necessary configuration data for the rebranding process.
class RebrandService {
  /// The configuration object containing rebranding parameters.
  final RebrandConfig config;

  /// Creates a new [RebrandService] with the given [config].
  RebrandService(this.config);

  /// Executes the complete rebranding workflow.
  ///
  /// This method orchestrates all rebranding steps in the correct order:
  /// 1. Sets up required dependencies
  /// 2. Changes package ID (Bundle IDs)
  /// 3. Updates Android app labels
  /// 4. Updates iOS app labels
  /// 5. Generates app icons and splash screens
  /// 6. Performs project cleanup
  /// 7. Syncs project dependencies
  /// 8. Syncs iOS CocoaPods (macOS only)
  ///
  /// Throws an exception if any critical step fails.
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

  /// Syncs iOS CocoaPods dependencies.
  ///
  /// This method runs `pod install` in the iOS directory to ensure
  /// all native iOS dependencies are properly installed and configured.
  ///
  /// Only executes on macOS platforms. Prints a warning if the sync fails
  /// but does not throw an exception, allowing the rebranding process to continue.
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

  /// Validates and installs required worker packages.
  ///
  /// Checks if the following packages are present in pubspec.yaml:
  /// - change_app_package_name
  /// - flutter_launcher_icons
  /// - flutter_native_splash
  ///
  /// If any packages are missing, they are automatically installed as
  /// dev dependencies using `flutter pub add --dev`.
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

  /// Updates the Android app label in AndroidManifest.xml.
  ///
  /// Modifies the `android:label` attribute in the manifest file to reflect
  /// the new app name. This changes the name displayed on the Android home screen.
  ///
  /// [name] The new app name to set.
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

  /// Updates the iOS app name in Info.plist.
  ///
  /// Modifies both `CFBundleName` and `CFBundleDisplayName` keys in the
  /// Info.plist file to reflect the new app name. This changes the name
  /// displayed on the iOS home screen.
  ///
  /// [name] The new app name to set.
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

  /// Generates app icons and splash screens.
  ///
  /// Creates a temporary YAML configuration file and uses flutter_native_splash
  /// to generate platform-specific splash screens for Android (including Android 12)
  /// and iOS.
  ///
  /// The method:
  /// 1. Validates that the icon image exists
  /// 2. Extracts splash configuration with fallback defaults
  /// 3. Creates a temporary configuration file
  /// 4. Runs the splash screen generator
  /// 5. Cleans up the temporary file
  ///
  /// Exits with code 1 if the icon image is not found.
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

  /// Executes a shell command and handles errors.
  ///
  /// Runs the specified command using [Process.run] and prints progress
  /// information. If the command fails (non-zero exit code), prints
  /// detailed error information and exits the process.
  ///
  /// [cmd] The command string to execute (space-separated).
  /// [desc] A human-readable description of what the command does.
  ///
  /// Exits with code 1 if the command fails.
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

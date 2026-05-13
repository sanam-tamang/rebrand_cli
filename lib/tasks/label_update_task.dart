import 'dart:io';
import '../rebrand_config.dart';
import 'rebrand_task.dart';

/// Updates the native Android and iOS application labels.
///
/// This task writes the configured `app_name` into Android `AndroidManifest.xml`
/// and iOS `Info.plist` so the app displays the correct name on the launcher.
class LabelUpdateTask extends RebrandTask {
  @override
  String get name => "Updating App Name to '${config.appName}'";

  final RebrandConfig config;

  LabelUpdateTask(this.config);

  @override
  Future<void> execute() async {
    if (config.enableAndroid) {
      print("🤖 Updating Android App Label...");
      final manifest = File('android/app/src/main/AndroidManifest.xml');
      if (manifest.existsSync()) {
        var content = manifest.readAsStringSync();
        content = content.replaceAll(
          RegExp(r'android:label="[^"]*"'),
          'android:label="${config.appName}"',
        );
        manifest.writeAsStringSync(content);
      }
    }

    if (config.enableIOS) {
      print("🍎 Updating iOS App Name...");
      final plist = File('ios/Runner/Info.plist');
      if (plist.existsSync()) {
        var content = plist.readAsStringSync();
        content = content.replaceAll(
          RegExp(r'<key>CFBundleName</key>\s*<string>[^<]*</string>'),
          '<key>CFBundleName</key>\n\t<string>${config.appName}</string>',
        );
        content = content.replaceAll(
          RegExp(r'<key>CFBundleDisplayName</key>\s*<string>[^<]*</string>'),
          '<key>CFBundleDisplayName</key>\n\t<string>${config.appName}</string>',
        );
        plist.writeAsStringSync(content);
      }
    }
  }
}

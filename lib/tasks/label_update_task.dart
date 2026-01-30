import 'dart:io';
import 'rebrand_task.dart';

class LabelUpdateTask extends RebrandTask {
  @override
  String get name => "Updating App Name to '$appName'";

  final String appName;

  LabelUpdateTask(this.appName);

  @override
  Future<void> execute() async {
    print("🤖 Updating Android App Label...");
    final manifest = File('android/app/src/main/AndroidManifest.xml');
    if (manifest.existsSync()) {
      var content = manifest.readAsStringSync();
      content = content.replaceAll(
        RegExp(r'android:label="[^"]*"'),
        'android:label="$appName"',
      );
      manifest.writeAsStringSync(content);
    }

    print("🍎 Updating iOS App Name...");
    final plist = File('ios/Runner/Info.plist');
    if (plist.existsSync()) {
      var content = plist.readAsStringSync();
      content = content.replaceAll(
        RegExp(r'<key>CFBundleName</key>\s*<string>[^<]*</string>'),
        '<key>CFBundleName</key>\n\t<string>$appName</string>',
      );
      content = content.replaceAll(
        RegExp(r'<key>CFBundleDisplayName</key>\s*<string>[^<]*</string>'),
        '<key>CFBundleDisplayName</key>\n\t<string>$appName</string>',
      );
      plist.writeAsStringSync(content);
    }
  }
}

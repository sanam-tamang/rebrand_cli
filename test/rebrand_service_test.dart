import 'dart:io';
import 'package:rebrand_cli/rebrand_config.dart';
import 'package:rebrand_cli/rebrand_service.dart';
import 'package:rebrand_cli/tasks/backup_task.dart';
import 'package:rebrand_cli/tasks/rebrand_task.dart';
import 'package:test/test.dart';

// Mock task that always fails
class MockFailingTask extends RebrandTask {
  @override
  String get name => "Mock Failing Task";

  @override
  Future<void> execute() async {
    // Simulate a change made by a task
    File('pubspec.yaml').writeAsStringSync('name: modified_project');
    throw "This task is designed to fail.";
  }
}

void main() {
  group('RebrandService Integration Test', () {
    final testProjectDir = Directory('test/dummy_project');
    final originalCwd = Directory.current;

    setUp(() {
      if (testProjectDir.existsSync()) {
        testProjectDir.deleteSync(recursive: true);
      }
      testProjectDir.createSync(recursive: true);

      // Create a dummy project structure
      File('${testProjectDir.path}/pubspec.yaml').writeAsStringSync('name: dummy_project');
      Directory('${testProjectDir.path}/android').createSync();
      File('${testProjectDir.path}/android/dummy_file.txt').writeAsStringSync('android content');
      Directory('${testProjectDir.path}/ios').createSync();
      File('${testProjectDir.path}/ios/dummy_file.txt').writeAsStringSync('ios content');

      Directory.current = testProjectDir;
    });

    tearDown(() {
      Directory.current = originalCwd;
      if (testProjectDir.existsSync()) {
        testProjectDir.deleteSync(recursive: true);
      }
    });

    test('should rollback the project if a task fails', () async {
      final originalPubspecContent = File('pubspec.yaml').readAsStringSync();

      final config = RebrandConfig(
        appName: 'Test App',
        packageName: 'com.test.app',
        iconPath: 'logo.png', // Dummy path
        splash: {'color': '#FFFFFF'},
      );

      final tasks = [
        BackupTask(),
        MockFailingTask(),
      ];

      final service = RebrandService(config, tasks: tasks);

      try {
        await service.execute();
      } catch (e) {
        // The service will call exit(1), so we catch the error here to allow the test to continue.
      }

      final restoredPubspecContent = File('pubspec.yaml').readAsStringSync();
      expect(restoredPubspecContent, originalPubspecContent);
    });
  });
}

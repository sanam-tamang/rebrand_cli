import 'dart:io';
import 'package:path/path.dart' as p;
import 'rebrand_task.dart';

class BackupTask extends RebrandTask {
  @override
  String get name => "Creating Project Backup";

  @override
  Future<void> execute() async {
    final backupDir = Directory('.rebrand_backup');
    if (backupDir.existsSync()) {
      backupDir.deleteSync(recursive: true);
    }
    backupDir.createSync();

    print("   📂 Backing up native configurations...");

    final targets = ['pubspec.yaml', 'android', 'ios'];

    for (var target in targets) {
      final targetExists =
          await FileSystemEntity.type(target) != FileSystemEntityType.notFound;
      if (!targetExists) {
        print('Skipping backup of $target as it does not exist.');
        continue;
      }

      if (await FileSystemEntity.isDirectory(target)) {
        await _copyDirectory(
          Directory(target),
          Directory(p.join(backupDir.path, target)),
        );
      } else if (await FileSystemEntity.isFile(target)) {
        await File(target).copy(p.join(backupDir.path, target));
      }
    }
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create(recursive: true);
    await for (var entity in source.list(recursive: false)) {
      final newPath = p.join(destination.path, p.basename(entity.path));
      if (entity is Directory) {
        await _copyDirectory(entity, Directory(newPath));
      } else if (entity is File) {
        await entity.copy(newPath);
      }
    }
  }
}

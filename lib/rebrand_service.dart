import 'dart:io';
import 'package:path/path.dart' as p;
import 'rebrand_config.dart';
import 'tasks/asset_generation_task.dart';
import 'tasks/backup_task.dart';
import 'tasks/cleanup_task.dart';
import 'tasks/label_update_task.dart';
import 'tasks/package_rename_task.dart';
import 'tasks/project_sync_task.dart';
import 'tasks/rebrand_task.dart';
import 'tasks/setup_dependencies_task.dart';
import 'tasks/validation_task.dart';

class RebrandService {
  final RebrandConfig config;

  final List<RebrandTask>? tasks;

  RebrandService(this.config, {this.tasks});

  Future<void> execute() async {
    final List<RebrandTask> tasksToRun = tasks ?? [];

    if (tasks == null) {
      tasksToRun.add(ValidationTask(config));
      tasksToRun.add(BackupTask());
      tasksToRun.add(SetupDependenciesTask(config));

      // Clear splash if requested
      if (config.shouldClearSplash) {
        tasksToRun.add(CleanupTask(config));
      }

      // Auto-enable if data provided
      if (config.packageName != null) {
        tasksToRun.add(PackageRenameTask(config));
      }

      if (config.appName != null) {
        tasksToRun.add(LabelUpdateTask(config));
      }

      if (config.splash != null || config.iconPath != null) {
        tasksToRun.add(AssetGenerationTask(config));
      }

      tasksToRun.add(ProjectSyncTask(config));
    }

    print("🚀 Rebrand Orchestrator Started...");

    try {
      for (var task in tasksToRun) {
        print("🔹 ${task.name}...");
        await task.execute();
      }

      _cleanupBackup();
      print("\n✅ Rebranding successful! Backup cleared.");
    } catch (e) {
      print("\n❌ CRITICAL ERROR: $e");
      await _performRollback();
    }
  }

  Future<void> _performRollback() async {
    print("⚠️  ROLLING BACK project to original state...");
    final backupDir = Directory('.rebrand_backup');

    if (!backupDir.existsSync()) {
      print("❌ Error: No backup found to restore from.");
      return;
    }

    final targets = ['pubspec.yaml', 'android', 'ios'];
    for (var target in targets) {
      final backupSourcePath = p.join(backupDir.path, target);
      final backupSource = await FileSystemEntity.isDirectory(backupSourcePath)
          ? Directory(backupSourcePath)
          : File(backupSourcePath);

      if (!await backupSource.exists()) continue;

      if (backupSource is Directory) {
        final destination = Directory(target);
        if (await destination.exists()) {
          await destination.delete(recursive: true);
        }
        await _copyDirectory(backupSource, destination);
      } else if (backupSource is File) {
        await backupSource.copy(target);
      }
    }

    _cleanupBackup();
    print("✅ Project restored. Please fix the error and try again.");
    throw "Rebranding failed and project was rolled back.";
  }

  void _cleanupBackup() {
    final backupDir = Directory('.rebrand_backup');
    if (backupDir.existsSync()) {
      backupDir.deleteSync(recursive: true);
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

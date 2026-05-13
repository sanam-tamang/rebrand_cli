import 'dart:io';
import 'package:path/path.dart' as p;
import 'rebrand_action.dart';
import 'rebrand_config.dart';
import 'tasks/asset_generation_task.dart';
import 'tasks/backup_task.dart';
import 'tasks/label_update_task.dart';
import 'tasks/launcher_task.dart';
import 'tasks/package_rename_task.dart';
import 'tasks/project_sync_task.dart';
import 'tasks/rebrand_task.dart';
import 'tasks/setup_dependencies_task.dart';
import 'tasks/splash_task.dart';
import 'tasks/validation_task.dart';

/// Orchestrates rebranding tasks for a loaded [RebrandConfig].
///
/// This service builds a task pipeline based on either explicit selected actions
/// from CLI flags or the data present in the config. It handles validation,
/// backup creation, dependency setup, task execution, rollback, and cleanup.
class RebrandService {
  final RebrandConfig config;
  final Set<RebrandAction>? selectedActions;
  final List<RebrandTask>? tasks;

  RebrandService(this.config, {this.selectedActions, this.tasks});

  Future<void> execute() async {
    final List<RebrandTask> tasksToRun = tasks ?? [];

    if (tasks == null) {
      final hasExplicitActions =
          selectedActions != null && selectedActions!.isNotEmpty;
      final actions = selectedActions ?? _deriveActionsFromConfig();

      tasksToRun.add(
        ValidationTask(
          config,
          actions: actions,
          explicitActions: hasExplicitActions,
        ),
      );
      tasksToRun.add(BackupTask());
      tasksToRun.add(SetupDependenciesTask(config, actions: actions));

      if (hasExplicitActions) {
        if (actions.contains(RebrandAction.rename)) {
          tasksToRun.add(PackageRenameTask(config));
        }
        if (actions.contains(RebrandAction.label)) {
          tasksToRun.add(LabelUpdateTask(config));
        }
        if (actions.contains(RebrandAction.launcher)) {
          tasksToRun.add(LauncherTask(config));
        }
        if (actions.contains(RebrandAction.splash)) {
          tasksToRun.add(SplashTask(config));
        }
      } else {
        if (config.packageName != null) {
          tasksToRun.add(PackageRenameTask(config));
        }
        if (config.appName != null) {
          tasksToRun.add(LabelUpdateTask(config));
        }
        if (config.splash != null || config.iconPath != null) {
          tasksToRun.add(AssetGenerationTask(config));
        }
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

  Set<RebrandAction> _deriveActionsFromConfig() {
    final actions = <RebrandAction>{};
    if (config.packageName != null) {
      actions.add(RebrandAction.rename);
    }
    if (config.appName != null) {
      actions.add(RebrandAction.label);
    }
    if (config.iconPath != null) {
      actions.add(RebrandAction.launcher);
    }
    if (config.splash != null || config.iconPath != null) {
      actions.add(RebrandAction.splash);
    }
    return actions;
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

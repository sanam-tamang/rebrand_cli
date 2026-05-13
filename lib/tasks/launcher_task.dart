import 'package:rebrand_cli/rebrand_config.dart';
import 'package:rebrand_cli/tasks/asset_generation_task.dart';
import 'package:rebrand_cli/tasks/rebrand_task.dart';

/// Generates launcher icon assets using `flutter_launcher_icons`.
///
/// This task writes a temporary launcher configuration and invokes the icon
/// generator based on [RebrandConfig.iconPath].
class LauncherTask extends RebrandTask {
  final RebrandConfig config;

  LauncherTask(this.config);

  @override
  String get name => 'Generating Launcher Icons';

  @override
  Future<void> execute() async {
    if (config.iconPath == null || config.iconPath!.trim().isEmpty) {
      throw 'Launcher generation requires "icon_path" in rebrand_config.json.';
    }

    await AssetGenerationTask.writeAndRunIcons(config, config.iconPath!);
  }
}

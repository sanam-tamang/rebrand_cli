/// Enumerates the explicit rebrand actions supported by the CLI.
///
/// These actions are used for the `--rename`, `--label`, `--launcher`, and
/// `--splash` flags to limit execution to a specific workflow.
enum RebrandAction { rename, label, launcher, splash }

extension RebrandActionExtension on RebrandAction {
  String get bannerName {
    switch (this) {
      case RebrandAction.rename:
        return 'Rename';
      case RebrandAction.label:
        return 'Label';
      case RebrandAction.launcher:
        return 'Launcher';
      case RebrandAction.splash:
        return 'Splash';
    }
  }
}

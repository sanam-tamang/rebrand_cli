## 2.0.0

- **New: Auto-Padding Engine for Splash Screens:** Prevents image cropping on Android 12+ by automatically adding padding to the splash screen image.
- **New: Task-Based Architecture:** The entire rebranding process is now more robust, scalable, and easier to maintain.
- **New: Automatic Project Backup & Rollback:** Your project is now automatically backed up before rebranding and restored if any step fails, preventing project corruption.
- **Improved: Enhanced Modularity:** The `RebrandService` is now more modular, making it easier to add new features in the future.
- **Improved: Robust Error Handling:** The new rollback system ensures that your project is left in a clean state even if an error occurs.

## 1.0.5
- Added documentation for running the tool directly with `dart pub global run` syntax.
- Enhanced README with clear instructions for both `rebrand` and `dart pub global run rebrand_cli:rebrand` commands.
- Improved CHANGELOG documentation for all versions.

## 1.0.3
- Documentation improvements and enhancements.

## 1.0.2
- Documentation improvements and enhancements.

## 1.0.1
- Updated documentation and README instructions.

## 1.0.0

- Initial release.
- Support for automated Package ID renaming (Android & iOS).
- Support for Native App Name updates in AndroidManifest and Info.plist.
- Automated asset generation for Launcher Icons and Splash Screens.
- Zero-setup dependency management (auto-adds worker packages to target projects).
## 3.1.0
- **New: Persistent Configuration**: Worker YAML files (`rebrand_splash.yaml`, `rebrand_launcher.yaml`, `rebrand_rename.yaml`) are now saved in the project root for manual control.
- **Improved**: Removed all manual cleanup logic. All asset management is now left to the worker packages or the user.
- **Improved**: Padded splash assets are now saved as persistent files (e.g., `rebrand_splash_padded.png`) when `auto_pad` is enabled.

## 3.0.1
- **Fix**: Removed explicit file deletion that caused `PathNotFoundException` during splash generation.
- **Improved**: Let `flutter_native_splash` handle all asset updates automatically.

## 3.0.0
- **BREAKING: Simplified Configuration**: Removed redundant `enable_*` flags. Intent is now inferred from data presence.
- **Improved Splash Logic**: `clear_splash` is now implicitly `true` when `splash_config` is provided, ensuring a clean state.
- **New AssetManager**: Added utility for tracking and removing assets, improving cleanup reliability.
- **Refined Branding**: Improved handling of branding logos and their removal.
- **Fixed Syntax Errors**: Resolved multiple compilation errors and broken tests.

## 2.2.0
- Added a more robust CLI interface with `--help`, `--version`, `--project`, and `--config` options.
- Fixed splash-only workflows so `splash_config.image` works even when `icon_path` is not provided.
- Added expanded splash customization support including dark assets, branding, fullscreen mode, iOS content mode, and Android 12 options.
- Added stronger validation for colors, image paths, gravity/content-mode values, and empty no-op configurations.
- Improved worker package installation so only the required helper packages are added.
- Expanded tests and refreshed README/example configuration for publishing.

## 2.1.0
- **New: Optional Configuration:** All fields in `rebrand_config.json` are now optional.
- **New: Feature Flags:** Added `enable_splash`, `enable_launcher_icon`, `enable_package_rename`, `enable_app_label` to control specific features.
- **New: Platform Selection:** Added `enable_android` and `enable_ios` to control platform-specific rebranding.
- **New: Splash Screen Scaling:** Added `scaling` option to `splash_config` to control logo size.
- **New: Input Validation:** Added validation for configuration values (paths, package name format, colors).
- **Improved:** `AssetGenerationTask` now scales only the splash screen image, preserving the original image for launcher icons.

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
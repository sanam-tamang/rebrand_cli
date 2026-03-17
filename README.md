# 🚀 Rebrand CLI

Rebrand Flutter apps from one CLI. Update the app name, package name / bundle ID, launcher icons, and native splash screens for Android and iOS with a single command.

## Why use it?

- Rename Android and iOS app identifiers from one config file
- Update the app label shown on the home screen
- Generate launcher icons
- Generate native splash screens with Android 12 support
- Auto-pad splash assets to avoid logo cropping on Android 12+
- Roll back changes automatically if a task fails
- Add only the helper packages actually required by the selected actions

## Install

```bash
dart pub global activate rebrand_cli
```

If `rebrand` is not found, add Dart pub cache to your `PATH`.

### macOS / Linux

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```

### Windows PowerShell

```powershell
$env:Path += ";$env:LOCALAPPDATA\Pub\Cache\bin"
```

### Run without changing PATH

```bash
dart pub global run rebrand_cli:rebrand --help
```

## Command reference

```bash
rebrand
rebrand .
rebrand --project ./my_app
rebrand --project ./my_app --config ./my_app/rebrand_config.json
rebrand --help
rebrand --version
```

### Available options

- `-h, --help` Show CLI help
- `-v, --version` Show package version
- `-p, --project <path>` Target Flutter project root
- `-c, --config <path>` Custom config file path

## Quick start

1. Go to your Flutter project root
2. Create `rebrand_config.json`
3. Run `rebrand`

### Minimal example

```json
{
  "app_name": "My New App",
  "package_name": "com.example.mynewapp",
  "icon_path": "assets/logo.png",
  "splash_config": {
    "color": "#FFFFFF",
    "image": "assets/logo.png"
  }
}
```

### Full example

```json
{
  "app_name": "My New App",
  "package_name": "com.example.mynewapp",
  "icon_path": "assets/logo.png",
  "enable_splash": true,
  "enable_launcher_icon": true,
  "enable_package_rename": true,
  "enable_app_label": true,
  "enable_android": true,
  "enable_ios": true,
  "splash_config": {
    "color": "#FFFFFF",
    "dark_color": "#111111",
    "image": "assets/logo.png",
    "dark_image": "assets/logo_dark.png",
    "gravity": "center",
    "ios_content_mode": "center",
    "fullscreen": false,
    "branding": "assets/branding.png",
    "branding_dark": "assets/branding_dark.png",
    "branding_mode": "bottom",
    "branding_bottom_padding": 24,
    "scaling": 0.7,
    "auto_pad": true,
    "android_12": {
      "color": "#FFFFFF",
      "dark_color": "#111111",
      "image": "assets/logo.png",
      "dark_image": "assets/logo_dark.png",
      "icon_background_color": "#FFFFFF",
      "icon_background_color_dark": "#000000",
      "branding": "assets/branding.png",
      "branding_dark": "assets/branding_dark.png"
    }
  }
}
```

## Configuration

### Top-level fields

- `app_name` App display name
- `package_name` New Android/iOS identifier like `com.company.app`
- `icon_path` Source image for launcher icon generation
- `enable_splash` Enable splash generation
- `enable_launcher_icon` Enable launcher icon generation
- `enable_package_rename` Enable package / bundle ID rename
- `enable_app_label` Enable app label update
- `enable_android` Apply supported changes on Android
- `enable_ios` Apply supported changes on iOS

At least one action must be enabled, either explicitly or by providing the related config values.

### `splash_config` fields

- `color` Light-mode splash background color
- `dark_color` Dark-mode splash background color
- `image` Splash image path; falls back to `icon_path`
- `dark_image` Dark-mode splash image path
- `gravity` Android gravity like `center`, `bottom`, `fill`
- `ios_content_mode` iOS content mode like `center`, `scaleAspectFit`, `scaleAspectFill`
- `fullscreen` Hide Android status bar during splash
- `branding` Optional branding image
- `branding_dark` Optional dark branding image
- `branding_mode` Branding position, typically `bottom`
- `branding_bottom_padding` Bottom padding for branding image
- `scaling` Auto-padding scale factor from `0 < value <= 1`
- `auto_pad` Auto-pad splash images before generation; defaults to `true`
- `android_12` Android 12 specific overrides

### `splash_config.android_12` fields

- `color`
- `dark_color`
- `image`
- `dark_image`
- `icon_background_color`
- `icon_background_color_dark`
- `branding`
- `branding_dark`

## How splash works

Rebrand CLI does not render a splash screen itself at runtime. Instead, it generates a temporary `flutter_native_splash` configuration and runs the native splash generator for the target Flutter app.

That means the splash is shown by the platform's native launch screen system:

- **Android:** generated drawables / Android 12 splash resources
- **iOS:** generated launch storyboard assets

By default, Rebrand CLI auto-pads the splash image so Android 12's circular mask is less likely to crop the important part of your logo. If you want to supply a fully prepared asset yourself, set:

```json
{
  "splash_config": {
    "auto_pad": false
  }
}
```

## What the CLI does during a run

When you run `rebrand`, it can:

1. Validate the config
2. Create a backup of key project files
3. Add helper packages if they are missing
4. Rename package / bundle IDs
5. Update app labels
6. Generate icons and splash assets
7. Run cleanup and dependency sync steps
8. Roll back automatically if something fails

## Helper packages used internally

Rebrand CLI orchestrates these packages when needed:

- `change_app_package_name`
- `flutter_launcher_icons`
- `flutter_native_splash`

## Notes and limitations

- Splash appearance on Android 12 can vary by launcher
- Native splash screens appear before Flutter renders its first frame
- iOS launch screen caching may require uninstall/reinstall when testing repeated changes
- Package renaming is handled as a project-level change and is not split per platform

## Example project

See `example/rebrand_config.json` for a working sample config.

## License

MIT


# 🚀 Rebrand CLI

Rebrand a Flutter app in seconds. Change the app name, package ID, launcher icon, and native splash screen with one command.

## Install

Add the package to your Flutter app as a dev dependency:

```bash
flutter pub add dev:rebrand_cli
```

Then run it from your Flutter app root:

```bash
flutter pub run rebrand_cli:rebrand init
```

> This works best when you run the commands inside your app project, because the tool expects a Flutter project with a `pubspec.yaml` file in the current directory.

---

## ⚡ 30-second beginner path

1. Open your Flutter project root.
2. Generate a starter config:

```bash
flutter pub run rebrand_cli:rebrand init
```

3. Edit the generated `rebrand_config.json` with your values.
4. Run:

```bash
flutter pub run rebrand_cli:rebrand
```

That is the minimal flow for most users.

If you want a more complete starter config, use:

```bash
flutter pub run rebrand_cli:rebrand init --full
```

> If `rebrand_config.json` already exists, the initializer will not overwrite it unless you add `--force`.

---

## ✨ Minimal example

Copy this into `rebrand_config.json`:

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

Then run:

```bash
flutter pub run rebrand_cli:rebrand
```

This is the best starting point for a first-time user.

---

## 🧠 How it works

Rebrand CLI reads your config and automatically applies the matching actions:

- `app_name` → updates the app label
- `package_name` → renames the Android/iOS package ID
- `icon_path` → generates launcher icons
- `splash_config` → generates native splash screens

No `enable_*` flags are required when you supply the data directly.

---

## 🛠️ Full features (advanced)

Use this section when you want richer splash, branding, and platform-specific options.

```json
{
  "app_name": "My New App",
  "package_name": "com.example.mynewapp",
  "icon_path": "assets/logo.png",
  "enable_android": true,
  "enable_ios": true,
  "clear_splash": false,
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

---

## 🔧 Common options

### Top-level fields

- `app_name` → app display name
- `package_name` → new Android/iOS identifier, such as `com.company.app`
- `icon_path` → source image for launcher icon generation
- `splash_config` → splash screen configuration
- `clear_splash` → remove existing splash config and files
- `enable_android` → apply changes to Android
- `enable_ios` → apply changes to iOS

### Splash fields

- `color` / `dark_color` → background colors
- `image` / `dark_image` → splash images
- `gravity` → Android positioning
- `ios_content_mode` → iOS positioning
- `fullscreen` → hide the Android status bar during splash
- `branding` / `branding_dark` → optional branding images
- `auto_pad` → automatically pad splash images for Android 12

---

## 🧹 Remove splash screens

To remove an existing splash screen completely:

```json
{
  "clear_splash": true,
  "splash_config": null
}
```

This removes splash config and restores the default Flutter splash behavior.

---

## 🧪 What the CLI does during a run

When you run `rebrand`, it can:

1. Validate the config
2. Create a backup of key project files
3. Add helper packages if needed
4. Rename package IDs
5. Update app labels
6. Generate icons and splash assets
7. Clean up and sync dependencies
8. Roll back automatically if something fails

---

## 📦 Helper packages used internally

Rebrand CLI uses these packages when needed:

- `change_app_package_name`
- `flutter_launcher_icons`
- `flutter_native_splash`

---

## 🧭 Example project

See `example/rebrand_config.json` for a working sample configuration.

---

## License

MIT

# 🚀 Rebrand CLI

A powerful, zero-setup CLI tool for Flutter developers to fully rebrand an application in seconds. It automates the tedious parts of renaming package IDs, updating native labels, and generating icons/splash screens for both **Android** and **iOS**.

---

## ✨ Features

* **Zero Manual Setup:** Automatically adds worker dependencies (`flutter_launcher_icons`, `flutter_native_splash`, and `change_app_package_name`) to the target project.
* **Deep Rename:** Updates Package Name (Bundle ID) across Android and iOS source files.
* **Native Label Update:** Changes the "Home Screen" app name in `AndroidManifest.xml` and `Info.plist`.
* **Asset Generation:** One-click generation for Icons and Splash screens using a single config file.
* **Clean & Safe:** Uses temporary configurations to keep your `pubspec.yaml` clean.

---

## 🛠 Installation

Activate the package globally using Dart:

```bash
dart pub global activate rebrand_cli
```

---

## 🚀 Usage

Follow these simple steps to rebrand your Flutter app:

### Step 1: Prepare Your Assets

Create an `assets` folder in your Flutter project root (if it doesn't exist) and add your app logo/icon image:

```
your_flutter_project/
├── assets/
│   └── logo.png          # Your app icon (recommended: 1024x1024 PNG)
├── lib/
├── android/
├── ios/
└── pubspec.yaml
```

### Step 2: Create Configuration File

In the **root directory** of your Flutter project, create a file named `rebrand_config.json`:

```json
{
    "app_name": "My New App",
    "package_name": "com.newcompany.app",
    "icon_path": "assets/logo.png",
    "splash_config": {
        "color": "#FFFFFF",
        "image": "assets/logo.png",
        "dark_color": "#111111"
    }
}
```

**Configuration Options:**
- `app_name`: The display name of your app (shown on home screen)
- `package_name`: Your new package/bundle identifier (e.g., `com.yourcompany.appname`)
- `icon_path`: Path to your app icon image
- `splash_config`: 
  - `color`: Background color for splash screen (light mode)
  - `image`: Path to splash screen image
  - `dark_color`: Background color for splash screen (dark mode) - optional

### Step 3: Run the Tool

Open your terminal, navigate to your Flutter project root, and run:

```bash
rebrand
```

That's it! The tool will automatically:
- ✅ Install required dependencies
- ✅ Update package names across Android and iOS
- ✅ Change app display names
- ✅ Generate app icons for all platforms
- ✅ Create splash screens (including Android 12 support)
- ✅ Clean and sync your project

---

## 📦 What It Modifies

- **Android:** Updates `build.gradle`, `AndroidManifest.xml`, and reorganizes package folder structures.
- **iOS:** Updates `project.pbxproj`, `Info.plist`, and Bundle Identifiers.
- **Assets:** Generates platform-specific app icons and native splash screens.

---

## 🤝 Contributing

Feel free to open issues or pull requests to improve the automation logic!

---

## 📄 License

This project is licensed under the MIT License.


# 🚀 Rebrand CLI

A powerful, zero-setup CLI tool for Flutter developers to fully rebrand an application in seconds. It automates the tedious parts of renaming package IDs, updating native labels, and generating icons/splash screens for both **Android** and **iOS**.



## ✨ Features

* **Zero Manual Setup:** Automatically adds worker dependencies (`flutter_launcher_icons, flutter_native_splash and change_app_package_name`) to the target project.
* **Deep Rename:** Updates Package Name (Bundle ID) across Android and iOS source files.
* **Native Label Update:** Changes the "Home Screen" app name in `AndroidManifest.xml` and `Info.plist`.
* **Asset Generation:** One-click generation for Icons and Splash screens using a single config file.
* **Clean & Safe:** Uses temporary configurations to keep your `pubspec.yaml` clean.

---

## 🛠 Installation

Activate the package globally using Dart:

```bash
dart pub global activate rebrand_cli


🚀 Usage
1. Create a Configuration
In the root of your Flutter project, create a file named rebrand_config.json:

JSON
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
2. Run the Tool
Ensure your logo is in the specified path, then run:

Bash
rebrand
📦 What it modifies
Android: Updates build.gradle, AndroidManifest.xml, and moves folder structures.
iOS: Updates project.pbxproj, Info.plist, and Bundle Identifiers.
Assets: Replaces AppIcon sets and generates native splash screens.
🤝 Contributing
Feel free to open issues or pull requests to improve the automation logic!

📜 License
MIT
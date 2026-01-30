# 🚀 Rebrand CLI

A powerful, zero-setup CLI tool for Flutter developers to fully rebrand an application in seconds. It automates the tedious parts of renaming package IDs, updating native labels, and generating icons/splash screens for both **Android** and **iOS**.

**Version 2.0.0 is a major upgrade that introduces a professional-grade architecture for safer, more reliable rebranding.**

---

## ✨ Features

* **Auto-Padding Engine:** Automatically processes your splash screen image to prevent cropping on modern Android and iOS devices. No more manual padding in Photoshop!
* **Task-Based & Fail-Safe:** The entire process is now broken down into modular tasks. If a step fails, the tool automatically rolls back your project to its original state, preventing corruption.
* **Zero Manual Setup:** Automatically adds worker dependencies (`flutter_launcher_icons`, `flutter_native_splash`, and `change_app_package_name`) to the target project.
* **Deep Rename:** Updates Package Name (Bundle ID) across Android and iOS source files.
* **Native Label Update:** Changes the "Home Screen" app name in `AndroidManifest.xml` and `Info.plist`.
* **Asset Generation:** One-click generation for Icons and Splash screens using a single config file.
* **Clean & Safe:** Uses temporary configurations to keep your `pubspec.yaml` clean, and creates a backup of your project during rebranding.

---

## 🛠 Installation

### Step 1: Install the Package

Activate the package globally using Dart:

```bash
dart pub global activate rebrand_cli
```

### Step 2: Add to PATH (if `rebrand` command not found)

After installation, if you get "command not found: rebrand", you need to add the Dart pub cache bin directory to your system PATH.

#### macOS / Linux

Add the following line to your shell configuration file (`~/.zshrc`, `~/.bashrc`, or `~/.bash_profile`):

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```

Then reload your shell:

```bash
source ~/.zshrc  # or source ~/.bashrc
```

#### Windows (PowerShell)

Add to your PowerShell profile or run:

```powershell
$env:Path += ";$env:LOCALAPPDATA\Pub\Cache\bin"
```

To make it permanent, add to your system environment variables:
1. Press `Win + X` → Select "System"
2. Click "Advanced system settings" → "Environment Variables"
3. Under "User variables", find `Path` and click "Edit"
4. Add: `%LOCALAPPDATA%\Pub\Cache\bin`
5. Click "OK" and restart your terminal

#### Windows (Command Prompt)

```cmd
set PATH=%PATH%;%LOCALAPPDATA%\Pub\Cache\bin
```

### Verify Installation

```bash
rebrand
```

**Alternative: Run directly without adding to PATH**

If you don't want to modify your PATH, you can run the tool directly:

```bash
dart pub global run rebrand_cli:rebrand
```

You should see the Rebrand CLI banner if installed correctly.

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

In the **root directory** of your Flutter project, create a file named `rebrand_config.json`. All fields are optional, but you must provide at least one action.

```json
{
    "app_name": "My New App",
    "package_name": "com.newcompany.app",
    "icon_path": "assets/logo.png",
    "enable_splash": true,
    "enable_launcher_icon": true,
    "enable_package_rename": true,
    "enable_app_label": true,
    "splash_config": {
        "color": "#FFFFFF",
        "image": "assets/logo.png",
        "dark_color": "#111111",
        "gravity": "center",
        "scaling": 0.8
    }
}
```

**Configuration Options:**
- `app_name`: (Optional) The display name of your app (shown on home screen).
- `package_name`: (Optional) Your new package/bundle identifier (e.g., `com.yourcompany.appname`).
- `icon_path`: (Optional) Path to your app icon image.
- `enable_splash`: (Optional) Enable/disable splash screen generation. Defaults to `true` if `splash_config` is present.
- `enable_launcher_icon`: (Optional) Enable/disable launcher icon generation. Defaults to `true` if `icon_path` is present.
- `enable_package_rename`: (Optional) Enable/disable package renaming. Defaults to `true` if `package_name` is present.
- `enable_app_label`: (Optional) Enable/disable app label update. Defaults to `true` if `app_name` is present.
- `enable_android`: (Optional) Enable/disable rebranding for Android. Defaults to `true`.
- `enable_ios`: (Optional) Enable/disable rebranding for iOS. Defaults to `true`.
- `splash_config`: (Optional)
  - `color`: Background color for splash screen (light mode)
  - `image`: Path to splash screen image. The tool will automatically use the `icon_path` if this is not provided.
  - `dark_color`: Background color for splash screen (dark mode) - optional.
  - `gravity`: (Optional) The gravity of the splash screen image. Can be `center`, `fill`, `bottom`, `top`, `left`, `right`. Defaults to `center`. **Note:** The new Auto-Padding Engine will process your image to fit a safe zone, so `center` is recommended.
  - `scaling`: (Optional) Scale factor for the logo within the splash screen safe zone (0.0 to 1.0). Defaults to `0.65` (65%). 
    > **Why scaling?** Android 12+ introduces a splash screen API that masks the icon in a circle. If your logo touches the edges, it will be cropped. Scaling ensures it fits safely within the circle.

### Step 3: Run the Tool

Open your terminal, navigate to your Flutter project root, and run:

```bash
rebrand
```

**Alternative: Run directly without adding to PATH**

```bash
dart pub global run rebrand_cli:rebrand
```

That's it! The tool will automatically:
- ✅ **Back up your project**
- ✅ Install required dependencies
- ✅ Update package names across Android and iOS
- ✅ Change app display names
- ✅ Generate app icons for all platforms
- ✅ **Create a perfectly padded splash screen (including Android 12 support)**
- ✅ Clean and sync your project
- ✅ **Restore your project if any step fails**

---

## 🌟 Why Version 2.0.0 is a Game Changer

This is more than just a script. It's now a smart tool that understands the pitfalls of rebranding.

- **Padding Independence:** You no longer need to worry about the "safe zone" for Android 12+ splash screens. The Auto-Padding Engine scales your logo to fit perfectly.
- **Error Isolation & Rollback:** If a step fails, the tool stops and immediately restores your project from a backup, so you're never left with a broken project.
- **Scalability:** The new task-based architecture makes it easy to add new features in the future, like "rebrand web" or "change fonts".

---

## 📦 What It Modifies

- **Android:** Updates `build.gradle`, `AndroidManifest.xml`, and reorganizes package folder structures.
- **iOS:** Updates `project.pbxproj`, `Info.plist`, and Bundle Identifiers.
- **Assets:** Generates platform-specific app icons and native splash screens.
- **`.rebrand_backup`:** A temporary directory created at the start of the process to ensure your project can be restored if anything goes wrong. This is deleted on success.

---

## 🤝 Contributing

Feel free to open issues or pull requests to improve the automation logic!

---

## 📄 License

This project is licensed under the MIT License.

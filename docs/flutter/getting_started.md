# Getting Started with Flutter

This guide explains how to set up Flutter locally on macOS or Windows.

---

## Prerequisites

- macOS (Intel/Apple Silicon) or Windows 10+
- ~2.5 GB free disk space
- Git installed ([https://git-scm.com/downloads](https://git-scm.com/downloads))

Verify Git:

```bash
git --version
```

## 1. Install Flutter SDK

### MacOS

```bash
mkdir -p ~/dev
cd ~/dev
git clone https://github.com/flutter/flutter.git -b stable
echo 'export PATH="$PATH:$HOME/dev/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

### Windows

1. Download the Flutter SDK from https://docs.flutter.dev/install/manual
2. Extract it to C:\src\flutter.
3. Add C:\src\flutter\bin to your system PATH via:
   - Control Panel → System → Advanced system settings → Environment Variables.

## 2. Verify Installation

```bash
flutter doctor
```

This command checks for any missing dependencies

## 3. Setup code editors

1. Install VScode at https://code.visualstudio.com/
2. Add the flutter and dart extensions
3. Install Android Studio for android development and virtual devices at https://developer.android.com/studio

## 4. Set Up a device emulator

### Android

- Open Android Studio → AVD Manager → Create Virtual Device.
- Choose a system image and launch the emulator.

### iOS (macOS only)

- Install Xcode from the App Store.
- Accept the license:

```bash
sudo xcodebuild -license accept
```

- Install Cocoapods

```bash
sudo gem install cocoapods
```

## 5. Verify Everything

```bash
flutter doctor -v
```

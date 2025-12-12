# Localization

We use `easy_localization` for handling multi-language support (Arabic and English). This approach is simple, requires no code generation, and uses standard JSON files.

## Setup

1.  **Configuration**: Initialized in `main.dart` and `app.dart`.
2.  **Assets**: Translation files are located in `frontend/assets/translations/`.

## Translation Files

*   `ar.json`: Arabic translations (Default)
*   `en.json`: English translations

## Usage

To translate a string in the code, simply use the `tr()` extension method on the string key.

```dart
import 'package:easy_localization/easy_localization.dart';

// Simple text
Text('home_title'.tr())

// With arguments
Text('home_filter'.tr(args: [currentLevel]))
```

## Adding New Strings

1.  Open `frontend/assets/translations/en.json` and add your key-value pair.
2.  Open `frontend/assets/translations/ar.json` and add the Arabic translation.
3.  Use the key in your Dart code.

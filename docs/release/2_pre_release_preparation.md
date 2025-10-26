## Pre-Release Preparation

### Update pubspec.yaml

```yaml
version: 1.0.0+1
# Format: versionName+versionCode
# versionName: 1.0.0 (shown to users)
# versionCode: 1 (internal version number)
```

### Configure Android Manifest

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.yourapp.package">

    <uses-permission android:name="android.permission.INTERNET" />

    <application
        android:label="Your App Name"
        android:icon="@mipmap/ic_launcher"
        android:theme="@style/AppTheme">
    </application>
</manifest>
```

## Generate App Bundle (Recommended)

```bash
# Clean project
flutter clean

# Build app bundle
flutter build appbundle

# For APK (if needed for testing)
flutter build apk --release
```

## Configure build.gradle

```gradle
android {
    compileSdkVersion 33

    defaultConfig {
        applicationId "com.yourapp.package"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0.0"
    }

    signingConfigs {
        release {
            storeFile file("your-upload-key.keystore")
            storePassword "your-password"
            keyAlias "your-alias"
            keyPassword "your-password"
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

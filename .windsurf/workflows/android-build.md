---
description: Purpose: Build Android APK/BUNDLE.
---

# /android-build

Purpose: Build Android APK/BUNDLE.

## Prereqs
- Android SDK + emulator or device.
- For release signing, configure `android/key.properties` (optional).

## Steps (PowerShell)
```powershell
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Play Store bundle (optional)
flutter build appbundle --release
```

## Artifacts
- `build\app\outputs\flutter-apk\app-debug.apk`
- `build\app\outputs\flutter-apk\app-release.apk`
- `build\app\outputs\bundle\release\app-release.aab`

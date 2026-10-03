# Android release builds

Signed release builds use an upload keystore that stays on the release machine. `frontend/android/.gitignore` already excludes `key.properties`, `*.jks`, and `*.keystore`. Do not commit those files or paste passwords into chat, tickets, or this document.

If `frontend/android/key.properties` is missing, Gradle still configures the release variant, but it signs that variant with the debug key and prints a warning. Debug-signed output cannot be uploaded to Google Play. `flutter run` does not need the upload keystore.

## One-time keystore setup

From `frontend/android`, create the upload key (PKCS12). Use a password manager to store the store password, key password, and alias. Validity of 10000 days matches Flutter's release guidance.

```powershell
keytool -genkeypair -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

`keytool` ships with the JDK (`C:\Program Files\Java\jdk-21*\bin\keytool.exe` on a typical Windows install).

Copy the example properties file and fill in the real values:

```powershell
copy key.properties.example key.properties
```

`key.properties` fields:

| Field | Meaning |
|---|---|
| `storePassword` | Keystore password |
| `keyPassword` | Key password (can match the store password) |
| `keyAlias` | Alias used at creation time (`upload`) |
| `storeFile` | Path relative to `frontend/android/app`. `../upload-keystore.jks` points at `frontend/android/upload-keystore.jks` |

Back up `upload-keystore.jks` and both passwords in a password manager. Losing them means you cannot ship updates with the same signing identity. Share the keystore only with people who publish the app, through that password manager, not through git.

## What the release variant does

`frontend/android/app/build.gradle.kts` reads `key.properties` when it exists and applies `signingConfigs.release`. The release build type also turns on R8 (`isMinifyEnabled`) and resource shrinking (`isShrinkResources`), using `proguard-rules.pro`.

Version name and version code come from `frontend/pubspec.yaml` (`version: <name>+<code>`). Bump both before each store upload. Example: `1.0.1+2` is version name `1.0.1` and version code `2`.

## Build

From `frontend`:

```powershell
flutter pub get
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

`--obfuscate` renames Dart symbols. `--split-debug-info` writes the symbol maps under `frontend/build/debug-info`, which is gitignored. Keep those maps with the matching release so crash reports can be deobfuscated.

Outputs:

| Artifact | Path |
|---|---|
| Android App Bundle | `frontend/build/app/outputs/bundle/release/app-release.aab` |
| APK | `frontend/build/app/outputs/flutter-apk/app-release.apk` |

Play Store uploads use the AAB. The APK is for sideload checks.

## Verify

Use the Android SDK build-tools (`%LOCALAPPDATA%\Android\Sdk\build-tools\<version>`).

```powershell
apksigner verify --verbose --print-certs frontend\build\app\outputs\flutter-apk\app-release.apk
jarsigner -verify -verbose -certs frontend\build\app\outputs\bundle\release\app-release.aab
aapt dump badging frontend\build\app\outputs\flutter-apk\app-release.apk
```

Confirm:

- `apksigner` reports the APK verifies, and the certificate subject is the upload key (`CN=FitFlow`), not `CN=Android Debug`.
- `jarsigner` reports `jar verified`.
- `aapt dump badging` shows the expected `versionCode`, `versionName`, `sdkVersion` (min), and `targetSdkVersion`.
- The APK and AAB are the release artifacts above, and `build/debug-info` exists for that same build.

`jarsigner` also warns that the certificate is self-signed and that the PKIX path cannot be built. That is expected for this upload key. It is not issued by a public certificate authority. `jar verified` is the line that matters. Google Play accepts this key when you enroll in Play App Signing.

`minSdk`, `targetSdk`, and `compileSdk` follow the installed Flutter SDK (`flutter.minSdkVersion`, `flutter.targetSdkVersion`, `flutter.compileSdkVersion` in `build.gradle.kts`). The release built with the current SDK targets minSdk 24, targetSdk 36, and compileSdk 36. Check the badging output again after each Flutter upgrade before uploading.

The APK is a universal package (arm64-v8a, armeabi-v7a, and x86_64), so it is larger than what a user downloads from Play. Upload the AAB; Play serves one ABI per device.

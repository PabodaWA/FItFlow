# iOS release builds

App Store and TestFlight builds are archived on a Mac with Xcode. Flutter on Windows cannot produce an IPA. The Apple Developer account that owns the app holds the distribution certificate. Do not commit certificates, profiles, or App Store Connect API keys.

Bundle ID `com.fitflow.fitflow` is already set on the Runner target. Version name and build number come from `frontend/pubspec.yaml` (`version: <name>+<code>`). `1.0.1+2` is short version `1.0.1` and build `2`, which App Store Connect shows as `1.0.1 (2)`.

## One-time signing setup

On the Mac, open `frontend/ios/Runner.xcworkspace` in Xcode.

1. Select the Runner target, then **Signing & Capabilities**.
2. Turn on **Automatically manage signing**.
3. Choose the Team for the FitFlow Apple Developer Program membership. Xcode writes `DEVELOPMENT_TEAM` for that machine.
4. In [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list), register the explicit App ID `com.fitflow.fitflow` if it is not there yet. Enable no extra capabilities. This version does not use HealthKit, push notifications, or iCloud.

`frontend/ios/ExportOptions.plist` exports with method `app-store-connect` and leaves the version numbers from the archive alone.

## What the release binary already declares

`frontend/ios/Runner/Info.plist`:

| Key | Value | Why |
|---|---|---|
| `CFBundleDisplayName` | FitFlow | Name under the icon. It matches the Android label. |
| `ITSAppUsesNonExemptEncryption` | false | The app uses only standard operating-system encryption and HTTPS-capable networking. Each upload then skips the export-compliance question. |
| `NSAllowsLocalNetworking` | true | A debug build can reach an account service on the local network. |

`frontend/ios/Runner/PrivacyInfo.xcprivacy` is included in the Runner resources. It reports name, email address, and user ID as collected, linked to the user, and used for app functionality. Tracking is off. That file is the binary side of the privacy nutrition label in [App Store Connect](app-store-connect.md).

The deployment target is iOS 13.0. The target device family is iPhone and iPad (`TARGETED_DEVICE_FAMILY = 1,2`).

## Build

From `frontend` on the Mac:

```sh
flutter pub get
flutter build ipa --release --obfuscate --split-debug-info=build/debug-info --export-options-plist=ios/ExportOptions.plist
```

`--obfuscate` renames Dart symbols. `--split-debug-info` writes the symbol maps under `frontend/build/debug-info`, which is gitignored. Keep those maps with the matching release so crash reports can be deobfuscated.

The IPA is written under `frontend/build/ios/ipa/`. Confirm the archive’s short version is `1.0.1` and the build number is `2` before you upload.

A TestFlight phone cannot sign in to `http://localhost:3000`. That address is the phone itself. Point a release build at an HTTPS account service the testers can reach before you send the build outside the team that can reach the developer machine.

## Upload

Sign in to the [Transporter](https://apps.apple.com/app/transporter/id1450874784) app with an Apple ID that has the App Manager or Admin role, and deliver the IPA. After processing, the build appears under **TestFlight** for `1.0.1`. Processing often takes several minutes and can take longer the first time.

The store listing, privacy nutrition label, TestFlight groups, screenshots, and review notes are in [App Store Connect and TestFlight](app-store-connect.md). Who receives build 2, what they run, and when an external group may be added are in [Internal testing](internal-testing.md).

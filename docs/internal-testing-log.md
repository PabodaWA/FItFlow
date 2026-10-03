# Internal testing log

Record for the internal track. Procedure: [Internal testing](internal-testing.md).

## Build 1.0.1 (2)

| Field | Value |
|---|---|
| Version | 1.0.1 (build 2), from `frontend/pubspec.yaml` |
| Date opened | 3 October 2026 |
| Android artifact | `frontend/build/app/outputs/bundle/release/app-release.aab` |
| iOS artifact | `frontend/build/ios/ipa/` |
| Play track | Internal testing, release name `1.0.1 (2)`, email list `FitFlow internal` |
| TestFlight group | FitFlow team only |
| Symbol maps | `frontend/build/debug-info` kept with this build, not committed |

Console rollout is done by the account owner. This repository cannot upload to Play Console or App Store Connect.

### Known before the first session

These rows are already true of the binary. They stay open until a later build changes them.

| ID | Severity | Finding | Promotion |
|---|---|---|---|
| K1 | Critical | Sign-in calls `http://10.0.2.2:3000` on Android and `http://localhost:3000` on iOS. A physical phone on the internal track cannot create an account. | Blocks a passed session A on device, and blocks external beta and production. |
| K2 | Critical for promotion | Play pre-launch Security will flag cleartext HTTP. Same cause as K1. | Blocks promotion. Expected on this build. |
| K3 | Critical for promotion | Account deletion is by email to privacy@fitflow.app. There is no delete control inside the app. | Does not block the Play internal track or the TestFlight FitFlow team group. Blocks Beta App Review, closed testing review, and production. |

### Session results

Fill one line per ID after the session. Use pass, fail, or no device.

| ID | Android | iOS | Notes |
|---|---|---|---|
| A1–A10 | | | Blocked on a physical device by K1. Emulator and simulator can run A while the core service is on port 3000. |
| B1–B4 | | | |
| C1–C3 | | | |
| D1 | | | |
| D2 | | | |
| D3 | | | |
| D4 | | | |
| D5 | | | |

### Reports

| Source | Checked on | Result |
|---|---|---|
| Play pre-launch report | | |
| Android vitals | | |
| TestFlight crashes | | |
| GitHub internal-test issues | | |

### Approval

External beta and production: **withheld**.

K1, K2, and K3 are open. Sessions A through D have not been recorded. The Play internal track and the TestFlight FitFlow team group are the only places build 2 may be installed.

| Role | Name | Date | Decision |
|---|---|---|---|
| Session lead | | | |
| Counter-signature | | | |

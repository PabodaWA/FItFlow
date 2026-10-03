# Internal testing

How FitFlow 1.0.1 (build 2) reaches internal testers, how those sessions are run, and what has to be true before the same build is offered to an external beta or to production.

Package `com.fitflow.fitflow`. The Android artifact is the signed bundle from [Android release builds](android-release.md). The iOS artifact is the IPA from [iOS release builds](ios-release.md). Store listing text, the internal-track release notes, and the TestFlight “What to Test” line already live in [Google Play Console](play-console.md) and [App Store Connect and TestFlight](app-store-connect.md). This page is the deployment, the sessions, the feedback path, and the approval gate.

Outcomes for the current build are recorded in [Internal testing log](internal-testing-log.md).

## Who tests this build

Internal only. Leave the Play closed, open, and production tracks empty. Leave the TestFlight groups Friends and family and Public beta without this build.

| Track | Who | Limit | How they install |
|---|---|---|---|
| Play internal testing | Google accounts on the email list `FitFlow internal` | 100 | Opt-in link, then the Play Store |
| TestFlight group `FitFlow team` | App Store Connect users with Admin, App Manager, Developer, or Marketing. The Account Holder can test. Finance and Sales cannot. | 100 | TestFlight app, automatic distribution |

Share the Play opt-in link only with addresses on that list. Share TestFlight invites only with people who already have a role on the app. A public link, a social post, or an external email list is an external beta and waits for the approval gate at the bottom of this page.

## Deploy the signed builds

### Play internal testing

Build and check the bundle the way [Android release builds](android-release.md) describes. Upload `frontend/build/app/outputs/bundle/release/app-release.aab` only after `apksigner` shows the upload certificate (`CN=FitFlow`) and `aapt dump badging` shows version name `1.0.1` and version code `2`.

In [Google Play Console](https://play.google.com/console), open **Test and release → Internal testing**.

1. Open the **Testers** tab. Create an email list named `FitFlow internal` and add the Gmail addresses of the people on the team. Save the list.
2. Copy the opt-in URL the testers tab shows. Send it only to those addresses.
3. Create a new release on the internal track. Upload the AAB. Release name: `1.0.1 (2)`. Release notes are the en-US note already written in [Google Play Console](play-console.md).
4. Confirm the console shows version name `1.0.1` and version code `2`. Start the rollout to internal testing.
5. Each tester opens the opt-in URL while signed into the Play Store with the same Google account, accepts the invitation, and installs FitFlow from the store link on that page.

The internal track does not go through store review. The pre-launch report starts once the release finishes processing. Play App Signing enrolls on this first upload, as [Google Play Console](play-console.md) describes.

A tester who is not on the list sees no store listing. Removing an address from the list ends that person’s access.

### TestFlight internal group

Archive and upload the IPA the way [iOS release builds](ios-release.md) describes. After processing, under **TestFlight → iOS → 1.0.1**:

1. Confirm version `1.0.1` and build `2`.
2. Answer the export question only if it still appears. The binary already sets `ITSAppUsesNonExemptEncryption` to false.
3. Keep the build on the **FitFlow team** group with automatic distribution. Internal testing does not wait for Beta App Review.
4. Testers install the TestFlight app, accept the email invite, and install FitFlow.

Groups, feedback email, “What to Test”, and the 90-day expiration are in [App Store Connect and TestFlight](app-store-connect.md). Do not submit build 2 for Beta App Review from this page.

## Account service before a phone session

Sign-in is required. Onboarding opens the login screen, and the home tabs stay behind a successful sign-in.

The release binary calls `http://10.0.2.2:3000` on Android and `http://localhost:3000` on iOS (`frontend/lib/core/api_config_io.dart`). On a physical phone those addresses are the phone itself. A Play or TestFlight install cannot create an account until that build is pointed at an HTTPS core service the tester can reach, and the binary is rebuilt.

Until that host exists:

- Upload the current bundle so Play can produce the pre-launch report. Expect the crawl to stop at sign-in, and expect a cleartext finding. Both match this binary.
- Run the feature script below on an Android emulator (it can reach `10.0.2.2`) or an iOS simulator (it can reach `localhost`), with the core service listening on port 3000.
- Treat any failed sign-in on a physical internal-test install as the known host gap, and still file it if the message is a crash rather than a connection error.

Closing the app drops the session token and the in-memory workouts, meals, progress, settings, and community posts. Signing in again on the next launch is expected. A crash, a stuck spinner, or a store of that data on disk is not.

## Structured sessions

One person runs all four sessions and writes the result in [Internal testing log](internal-testing-log.md). A second person repeats session A on the other platform. Use build `1.0.1 (2)` and a fresh account per platform (`tester-android@` and `tester-ios@` on a domain the team controls).

Pass means the row’s expected result happened, with no crash and no spinner that never ends. Fail means anything else. File a fail the same day.

### Session A — new features

About 40 minutes. Core service running for emulator and simulator runs.

| ID | Do this | Expected |
|---|---|---|
| A1 | Create an account, then sign out and sign in again | Home opens. The password is not shown back. Sign-out returns to the login screen. |
| A2 | Read Home | A session and a suggested workout are visible. |
| A3 | Open a workout, read the exercises, start the session | The session screen stays up for the length of the workout you start. |
| A4 | Draft a session from a goal, level, time, and one equipment choice, then leave the draft | A list of exercises appears. Ignoring it returns you to the previous screen. |
| A5 | Log one food under breakfast and add one glass of water | Calories and water change on the nutrition screen. |
| A6 | Open the week view and switch kilograms off and on | Workouts, calories, duration, weight, and streak are on screen. The unit label follows the switch. |
| A7 | Publish a post, comment on it, and like it | The post is visible in this session. |
| A8 | Edit the profile name and set a goal. Open achievements. | The new name and goal show on the profile. |
| A9 | In Settings, open Privacy Policy and Release notes, and the support row | Both documents open. Support shows `privacy@fitflow.app`. The footer says FitFlow is a fitness tool, not medical advice. |
| A10 | Force-close the app and open it again | Login is shown again. The meal, post, and draft from this session are gone. |

### Session B — performance

About 15 minutes, after a force-close so the start is cold. Release or profile mode, not a debug build.

| ID | Do this | Expected |
|---|---|---|
| B1 | Cold start to the login screen, three times | Each start reaches a usable login screen. No multi-second blank frame after the splash, and no ANR dialog. |
| B2 | Sign in, then switch Home, Workouts, Nutrition, Community, and Profile, twice | Each tab paints on the first tap. |
| B3 | Scroll the workout list, the meal list, and the community feed to the end | Scrolling stays even. No dropped-frame stutter you can see while reading a row. |
| B4 | Open a workout and start the session, then leave it | The transition completes. The session does not freeze the tab bar. |

On Android, compare B1–B3 with the **Performance** tab of the pre-launch report once it exists. A Test Lab cold-start warning becomes a fail for B1.

### Session C — battery

About 30 minutes of wall clock. Start from a charge above 50 percent, screen timeout left at the phone default, no charger.

| ID | Do this | Expected |
|---|---|---|
| C1 | Note the battery percent. Sign in and spend 15 minutes on A3, A5, and moving between tabs. | The app stays in the foreground and does not ask for battery-unrestricted mode. |
| C2 | Send the app to the background for 15 minutes. Do not open it. Then note the battery percent again. | Drop over the half hour is in the same range as leaving the phone on the home screen for that long. A drop of more than about 10 points in that idle window is a fail. |
| C3 | Open the app again | Login is shown, because the process was free to be stopped. The app does not keep a notification, a workout timer, or a location prompt running while backgrounded. |

The manifest requests `INTERNET` only. There is no background service and no wake lock. A battery fail here means something in this build is still working after C2, or the idle drop is large enough to notice.

### Session D — other devices

Repeat A1, A3, A5, A6, and A9 once on each row you have. Skip a row you do not have, and write “no device” in the log. Do not mark a skipped row as a pass.

| ID | Device | Why this one |
|---|---|---|
| D1 | Android phone on API 24, 25, or 26 | Oldest versions the bundle still allows (`minSdk` 24). |
| D2 | Android phone on API 34, 35, or 36 | Current target (`targetSdk` 36). |
| D3 | Android tablet, or a phone wider than 720 dp | Settings and the home tabs cap their content width. Confirm the tabs are still reachable and text is not clipped. |
| D4 | Small iPhone (SE size or similar) | Login, a workout, and Settings at a short height. |
| D5 | iPad | The binary includes iPad (`TARGETED_DEVICE_FAMILY` 1 and 2). Confirm the same five checks on the tablet layout. |

A crash on one row excludes that device from the track only when the crash is specific to it. A crash on every row is a build failure, not a device exclusion. Device exclusions are saved under **Device catalog → Manage devices**, after the pre-launch report, as [Google Play Console](play-console.md) describes.

## Bug reports, crashes, and feedback

Three store reports cover crashes and performance for this track:

| Source | Where | What it is for |
|---|---|---|
| Play pre-launch report | **Test and release → Internal testing → Pre-launch report** | Firebase Test Lab runs the bundle on a device lab. Read Crashes, Performance, Accessibility, Security, and Screenshots before any promotion. The Security tab is expected to flag cleartext HTTP. |
| Android vitals | **Monitor and improve → Android vitals**, after at least one tester install | Crash rate and ANRs from the internal track. |
| TestFlight crashes | The build page for `1.0.1 (2)`, Crashes | Crash logs from the FitFlow team group. Screenshot feedback is for the external groups and stays off while those groups have no build. |

Tester notes go to GitHub with the [internal test report](../.github/ISSUE_TEMPLATE/internal-test-report.md) template: version, device, session ID, and what happened. Anything that includes an account email or a password goes to privacy@fitflow.app instead of GitHub. The feedback address on the TestFlight page is that same mailbox.

Keep the symbol maps in `frontend/build/debug-info` next to the AAB or IPA they were built with. Crash stacks from an obfuscated release are readable only with those maps.

This version does not embed the Firebase Crashlytics SDK or the App Center SDK. The privacy policy states that this version does not use an analytics vendor, and both the Play data safety form and the App Privacy label leave Diagnostics unselected. Crash collection for the internal track is the Play pre-launch report, Android vitals, and TestFlight. A later release that adds either SDK updates the privacy policy, the data safety form, and the nutrition label in that same binary.

## Read the results and ship the next build

Severity, applied to every failed row and every crash:

| Severity | Meaning | What happens to the track |
|---|---|---|
| Critical | Crash on launch, crash during A1–A10, sign-in broken on a build whose host is reachable, a medical claim on screen, or a session that writes meals, weight, or posts to disk or to a server | The internal track stays up so testers can confirm the fix. No external group and no production release. |
| High | A failed B or C row, or a D row that crashes on every device of that class | Fix before promotion. The internal track can stay on the current build while the fix is in progress. |
| Low | A copy error, a clipped label on one size, or a confusing empty state that still lets the task finish | Record it. It can ship to the next internal build and does not by itself block promotion. |

For a critical or high fix:

1. Fix it on a branch and re-run the failed session IDs.
2. Set `frontend/pubspec.yaml` to `1.0.1+3` so the version name stays `1.0.1` and the build number becomes `3`. Play rejects an upload whose version code is not higher than `2`. TestFlight rejects an upload whose build number is not higher than `2`.
3. Rebuild the AAB and the IPA with `--obfuscate` and a fresh `--split-debug-info` directory. Archive the new maps with build 3.
4. Upload to the same Play internal release track and to the FitFlow team group. Use release name `1.0.1 (3)` and say which session IDs the build fixes.
5. Re-run every failed ID plus A1 and A10. Update the log. The previous build’s Play listing is replaced by this rollout. The previous TestFlight build expires on its own date and can stay installed until testers move.

## Approval before an external beta or production

Promotion means adding the build to Play closed testing, or to the TestFlight group Friends and family, or starting a production rollout. All of the following are true before that happens. The person who ran the sessions signs the log. A second person on the FitFlow team countersigns.

- Build number in the log matches the build on both consoles.
- Session A passed on Android and on iOS, on a binary whose account host the tester can reach over HTTPS.
- Sessions B and C passed on at least one phone per platform.
- Every session D row was either a pass or marked “no device”. No critical crash is still open.
- The Play pre-launch report has been read. Crashes are resolved or the device is excluded. The cleartext finding is gone, because the release build uses HTTPS.
- Android vitals and TestFlight crashes for this build show no open critical crash.
- In-app account deletion exists. Email-only deletion is enough for the privacy policy and is not enough for Beta App Review or App Review. See [App Store Connect and TestFlight](app-store-connect.md).
- The Play app-access instructions include a demo account on that HTTPS host.
- The log’s approval line is signed. Until that line is signed, the external groups and the production track stay empty.

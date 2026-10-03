# App Store Connect and TestFlight

Store setup for FitFlow 1.0.1 (build 2). Bundle ID `com.fitflow.fitflow`. The IPA to upload is the one [iOS release](ios-release.md) builds. App Store Connect has to be completed in the Apple Developer account that owns the app. This page is the listing, the privacy answers, the TestFlight setup, and the review notes to enter there. It matches the app as it ships in 1.0.1.

## Create the app record

In [App Store Connect](https://appstoreconnect.apple.com) open **Apps → New App**.

| Field | Value |
|---|---|
| Platforms | iOS |
| Name | FitFlow: Workouts & Meals |
| Primary language | English (U.S.) |
| Bundle ID | com.fitflow.fitflow |
| SKU | FITFLOW001 |
| User access | Full access |

The name is 25 characters (limit 30). The name under the icon is FitFlow (`CFBundleDisplayName` in `frontend/ios/Runner/Info.plist`).

## Metadata and keywords

Open the iOS app version **1.0.1**.

| Field | Value |
|---|---|
| Subtitle | Workouts, meals, and your week |
| Promotional text | Plan workouts, log meals and water, and see your week in one free app. FitFlow is a training companion, not medical advice. |
| Keywords | workout,exercise,fitness,nutrition,calories,meal,training,gym,streak,water,habit,strength |
| Support URL | https://github.com/PabodaWA/FItFlow/issues |
| Marketing URL | https://github.com/PabodaWA/FItFlow |
| Privacy Policy URL | https://cdn.jsdelivr.net/gh/PabodaWA/FItFlow@main/docs/site/privacy/index.html |
| Copyright | 2026 FitFlow |
| Primary category | Health & Fitness |
| Secondary category | Food & Drink |
| Price | Free |
| Availability | All countries and regions |
| In-app purchases | None |
| Content rights | This app does not contain, show, or access third-party content |
| Mac and Apple Vision | Leave those platforms off. The app has no UI for them. |

Subtitle is 30 characters (limit 30). Promotional text is 123 characters (limit 170) and can be changed later without a new review. Keywords are 89 characters (limit 100), with no spaces and without the app name.

Description (plain text, paste as a single block):

```
FitFlow is a free fitness companion for planning workouts, logging meals, and seeing how your week is going.

Train
Follow a workout, read the exercises, and start the session. Home points you at a session and a suggested workout. You can draft another session on your phone from your goal, level, time, and the equipment you have. That draft stays on your device, and you can ignore it.

Eat
Log breakfast, lunch, dinner, and snacks. Watch calories, protein, carbs, and fat, and add water a glass at a time.

Your week
See workouts, calories, duration, weight, and streak. Switch between kilograms and pounds.

Community
Write a post or an achievement, comment, and like. In this version that feed stays on your phone.

Account
Create an account and sign in. Your password is stored as a hash. Edit your name, set a goal, and choose reminders, a weekly summary, and units.

FitFlow is a training companion. It is not a medical device and it does not diagnose, treat, or give medical advice. Talk with a qualified clinician before you change exercise or diet, especially if you are pregnant, injured, or managing a health condition.

FitFlow is not directed at anyone under 16.

Privacy policy: https://cdn.jsdelivr.net/gh/PabodaWA/FItFlow@main/docs/site/privacy/index.html
Support: privacy@fitflow.app
```

What’s New in this version (en-US):

```
Sign in, follow a workout, and draft a session on your phone. Log meals and water, and see your week: workouts, calories, duration, weight, and streak. Privacy policy and release notes are in Settings.
```

That note is 201 characters (limit 4000).

Age rating questionnaire, from what version 1.0.1 actually does:

| Topic | Answer |
|---|---|
| Violence, sexual content, profanity, horror, alcohol, tobacco, drugs, gambling | None |
| Contests | None |
| Unrestricted web access | No |
| Advertising | No |
| Messaging and chat | No |
| User-generated content shared with other people | No. Posts, comments, and likes stay in the app session and are not sent to other people. |
| Medical or treatment information | None. The app tracks workouts and meals the user types. It does not diagnose or prescribe. |
| Made for Kids | No |

The calculated rating from those answers is 4+. The privacy policy says the app is not directed at anyone under 16, and that sentence stays in the description. Leave Made for Kids off.

## Privacy nutrition labels

Open **App Privacy**. “Collected” means sent off the device. Workouts, meals, weight, settings, and community posts are not uploaded in 1.0.1, so they are not collected. The same three types are declared in `frontend/ios/Runner/PrivacyInfo.xcprivacy`.

| Data type | Collected | Linked to the user | Tracking | Purpose |
|---|---|---|---|---|
| Contact Info → Name | Yes | Yes | No | App Functionality |
| Contact Info → Email Address | Yes | Yes | No | App Functionality |
| Identifiers → User ID | Yes | Yes | No | App Functionality |

Leave Health & Fitness, Location, Photos, Contacts, Sensitive Info, User Content, Purchases, and Diagnostics unselected. Do not declare the password. It is used only to authenticate and is stored as a bcrypt hash.

| Question | Answer |
|---|---|
| Do you or your third-party partners collect data from this app? | Yes. The first-party account service stores name, email, and user ID. |
| Do you track users? | No. There is no advertising and no data broker. |
| Data used to track you | None |

When a later version syncs workouts, meals, or weight, add Health & Fitness to this label and ship the updated `PrivacyInfo.xcprivacy` in that same binary.

## Upload the build and turn on TestFlight

Build and deliver the IPA the way [iOS release](ios-release.md) describes. `ITSAppUsesNonExemptEncryption` is already false, so App Store Connect does not ask the export question again. The binary uses standard system encryption only.

After the build finishes processing under **TestFlight → iOS → 1.0.1**:

1. Confirm the build shows version `1.0.1` and build `2`.
2. If a compliance prompt still appears, answer that the app uses encryption and qualifies for the exemption for encryption that is part of the operating system. Then check that `ITSAppUsesNonExemptEncryption` is in the uploaded Info.plist.
3. Add the build to the internal group as soon as processing completes. Internal testing does not wait for Beta App Review.
4. Add the same build to the external group only after the approval gate in [Internal testing](internal-testing.md) is signed, and only when you submit it for Beta App Review.

Test Information, used for both groups:

| Field | Value |
|---|---|
| Beta App Description | Plan workouts, log meals, and see your week. FitFlow is a training companion, not medical advice. |
| Feedback Email | privacy@fitflow.app |
| What to Test | Sign in, follow a workout, and draft a session on your phone. Log meals and water, and see your week: workouts, calories, duration, weight, and streak. This build is a training companion, not medical advice. Privacy policy and release notes are in Settings. |
| Sign-in required | Yes |
| Contact | privacy@fitflow.app |

Marketing URL on the TestFlight page can stay the GitHub URL from the listing table.

## Testers, groups, and expiration

Create these groups under **TestFlight → Testers and Groups**.

| Group | Type | Who | How builds arrive |
|---|---|---|---|
| FitFlow team | Internal | App Store Connect users with Admin, App Manager, Developer, or Marketing. Account Holder can test. Finance and Sales cannot. Limit 100. | Automatic distribution, so each processed build is offered to the group. |
| Friends and family | External | People invited by email. | Manual. Submit build 2 for Beta App Review, then enable the group. |
| Public beta | External | Anyone with the public link. | Leave the public link off until the checks below pass. Limit 10,000 across external testers. |

Turn on screenshot feedback for both external groups.

Internal testers can install as soon as processing finishes. External testers wait for Beta App Review the first time a version is sent outside the team. Later builds of 1.0.1 can skip a new review when you answer that the changes do not need one, which is only true when the binary’s behavior matches the notes already approved.

Build expiration:

| Build | Uploaded | Expires | Next action |
|---|---|---|---|
| 1.0.1 (2) | The date TestFlight shows after processing | The expiration date TestFlight shows on that build (90 days after upload) | 14 days before that date, archive build 3 if testing is still going |

Use the date on the build page. A TestFlight build expires 90 days after it is uploaded. Testers cannot open an expired build, including one they already installed. Upload the replacement and attach it to FitFlow team and to Friends and family before that date. The next archive uses `1.0.1+3` in `frontend/pubspec.yaml` so the build number increases and the short version stays 1.0.1.

Removing a person from a group ends their access the same day. It does not change the expiration date for everyone else. An invitation that has not been accepted can be revoked from the same group page.

Before you enable the public link, install build 2 from the Friends and family group and confirm:

- Create account and sign in
- Open a workout and start the session
- Draft a session on the device
- Log a meal and a glass of water
- Open the week view, including weight
- Open Settings and read the line that FitFlow is a fitness tool, not medical advice

## Screenshots and app preview videos

The binary supports iPhone and iPad, so both displays need artwork. Capture on a Mac simulator. Android screenshots are the wrong size and the wrong chrome.

| Display | Accepted portrait sizes | Simulator |
|---|---|---|
| iPhone 6.9-inch (required) | 1320×2868, 1290×2796, or 1260×2736 | iPhone 16 Pro Max |
| iPad 13-inch (required) | 2064×2752, or 2048×2732 | iPad Pro 13-inch |

Apple scales a 6.9-inch set down to smaller iPhones, and a 13-inch set down to smaller iPads, when those smaller sizes are left empty. Upload portrait PNG or JPEG files, RGB, with no transparency. Leave the status bar clean. Do not add a device frame, a hand, or a caption burned into the pixels. Six screenshots per display, in this order (limit 10):

| File | Screen |
|---|---|
| 01-home | Home, with the session and the suggested workout |
| 02-workout | A workout and its exercises |
| 03-draft | The on-device session draft |
| 04-nutrition | A meal log with calories and water |
| 05-progress | The week: workouts, calories, duration, weight, streak |
| 06-profile | Profile or Settings, including the medical-disclaimer line |

Save them under `docs/app-store/iphone-6.9/` and `docs/app-store/ipad-13/`. On the Mac, with the simulator in the foreground:

```sh
xcrun simctl io booted screenshot docs/app-store/iphone-6.9/01-home.png
```

Repeat for each screen, then switch the simulator to the iPad and capture the same six. The iPad captures must be the iPad layout. A scaled-up iPhone image will be rejected for the wrong dimensions and will misrepresent the app.

App preview, one video per display (limit 3):

| Setting | Value |
|---|---|
| Length | 15 to 30 seconds |
| Size | The same pixel size as that display’s screenshots |
| Format | .mov or .mp4, H.264, 30 fps |
| Audio | None, unless the sound is produced by the app |
| Poster frame | 01-home |

Record this sequence, then trim to about 25 seconds:

| Seconds | On screen |
|---|---|
| 0–5 | Home |
| 5–12 | Open a workout and start the session |
| 12–20 | Log a meal and add water |
| 20–25 | The week view |
| 25–28 | Settings, holding on “FitFlow is a fitness tool, not medical advice.” |

Put the files in `docs/app-store/previews/` as `iphone-6.9.mov` and `ipad-13.mov`.

## Apple review, including health data

Use **Manual release**. Finish TestFlight before you submit 1.0.1 for App Review.

App Review Information:

| Field | Value |
|---|---|
| Sign-in required | Yes |
| Contact | privacy@fitflow.app |
| Notes | The block below |
| Demo account | A reachable HTTPS account. The account service in this build defaults to `http://localhost:3000` (`frontend/lib/core/api_config_io.dart`). A reviewer cannot reach a machine on the developer network. Put the demo email, password, and HTTPS host in these notes before Beta App Review or App Review. |

Notes to paste:

```
FitFlow 1.0.1 is a consumer fitness and nutrition tracker. It is not a medical device and does not diagnose, treat, or give medical advice. Settings shows: "FitFlow is a fitness tool, not medical advice." The same idea is on the public privacy policy.

The app does not use HealthKit, Clinical Health Records, CareKit, or ResearchKit. Info.plist has no health usage strings. Body weight, workouts, meals, and water are typed by the user and kept in the app session. They are not sent to FitFlow servers.

The only data sent off the device is the account: name, email, and a password that the server stores as a bcrypt hash, plus a bearer session token.

Community posts, comments, and likes stay in the app session and are not uploaded. Users cannot see other people's posts in this build.

The workout draft runs on the device from a fixed exercise catalog. It is optional and it is not a prescription.

Privacy policy: https://cdn.jsdelivr.net/gh/PabodaWA/FItFlow@main/docs/site/privacy/index.html
```

How this build lines up with the guidelines that cover a health and fitness app:

| Guideline | What to rely on |
|---|---|
| 1.4.1 Physical harm | The listing, the screenshots, and the app say FitFlow is a training companion and not a medical device. They do not promise weight loss, diagnosis, or treatment. The workout draft is a list of exercises the user can ignore. |
| 1.4.1 Citations | Medical citations are for apps that give medical advice. This one does not. Keep clinical claims out of the subtitle, keywords, and preview. |
| 5.1.1 Privacy policy | The privacy policy URL is on the app record and inside the app (sign-in, create account, and Settings). |
| 5.1.3 Health and health research | HealthKit is not linked. Health data is not used for advertising and is not written to iCloud. In this version it stays in the app session and is not uploaded. Do not add `NSHealthShareUsageDescription` or `NSHealthUpdateUsageDescription` until a version actually reads or writes HealthKit, and update the privacy policy and the nutrition label in that same release. |
| 2.3.1 Accurate metadata | The description lists workouts, meals, the week, the in-app community, and account sign-in. Keywords stay on those features. |
| 5.1.1(v) Account deletion | People can ask for deletion by emailing privacy@fitflow.app. That matches the privacy policy. Apple also requires a delete control inside any app that lets someone create an account. Add that control before you submit build 2 for Beta App Review or for the App Store. Internal TestFlight does not go through that review, so the FitFlow team group can install this build while the control is still missing. |

Do not write “HIPAA compliant” on the store page. The privacy policy describes ordinary personal use as outside HIPAA because FitFlow is not a covered entity or a business associate. Apple review does not certify that.

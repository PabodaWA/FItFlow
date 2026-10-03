# Google Play Console

Store setup for FitFlow 1.0.1 (version code 2). Package name `com.fitflow.fitflow`. The signed bundle to upload is `frontend/build/app/outputs/bundle/release/app-release.aab`, built the way [Android release signing](android-release.md) describes.

Play Console has to be completed in the developer account that owns the app. This page is the listing, the questionnaire answers, and the settings to enter there. It matches the app as it ships in 1.0.1.

## Create the app

In [Google Play Console](https://play.google.com/console):

1. Create app.
2. App name: `FitFlow`.
3. Default language: English (United States) – en-US.
4. App or game: App.
5. Free or paid: Free.
6. Accept the Developer Program Policies and the US export laws declaration.

The name under the launcher icon is FitFlow (`android:label` in `frontend/android/app/src/main/AndroidManifest.xml`).

## Store listing

Open **Grow users → Store presence → Main store listing**. Category and the text below go on that page. Contact details go under **Store settings**.

| Field | Value |
|---|---|
| App name | FitFlow: Workouts & Meals |
| Short description | Plan workouts, log meals, and track your week in one free app. |
| Category | Health & Fitness |
| Tags | Exercise, Nutrition, Healthy living (pick the closest tags the console offers) |
| Email | privacy@fitflow.app |
| Privacy policy | https://cdn.jsdelivr.net/gh/PabodaWA/FItFlow@main/docs/site/privacy/index.html |
| Website | https://github.com/PabodaWA/FItFlow |

App name is 25 characters (limit 30). Short description is 62 characters (limit 80).

Full description (plain text, paste as a single block):

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

Graphics the listing still needs from a phone build of this version:

| Asset | Spec | What to capture |
|---|---|---|
| App icon | 512×512 PNG, 32-bit | The launcher icon |
| Feature graphic | 1024×500 PNG or JPEG | FitFlow name on the green used in the app (`#1B7F4E`), with a short line such as “Workouts, meals, and your week” |
| Phone screenshots | 2 to 8 images, 16:9 or 9:16, each side between 320 px and 3840 px | Home, a workout, the on-device session draft, nutrition, progress, profile |
| Tablet screenshots | Optional | Skip until a tablet layout is checked |

## Upload the signed bundle

Use **Test and release → Internal testing** for the first upload. Pre-launch reports are generated from a testing track.

1. Create a new release.
2. Upload `frontend/build/app/outputs/bundle/release/app-release.aab`.
3. Release name: `1.0.1 (2)`.
4. Release notes (en-US):

```
Sign in, follow a workout, and draft a session on your phone. Log meals and water, and see your week: workouts, calories, duration, weight, and streak. Privacy policy and release notes are in Settings.
```

That note is 201 characters (limit 500).

Confirm the console shows version name `1.0.1` and version code `2` before you start the rollout to internal testers. Add the tester accounts, then roll out.

## Content rating

Open **Policy → App content → Content rating**, start the questionnaire, and use the contact email `privacy@fitflow.app`. Category for the questionnaire: **All Other App Types** (this is not a game).

Answer from what version 1.0.1 actually does.

| Topic | Answer |
|---|---|
| Violence, blood, fear, or scary content | No |
| Sexual content or nudity | No |
| Profanity or crude humor | No |
| Alcohol, tobacco, or drugs | No |
| Gambling, including simulated gambling | No |
| Users can interact or exchange content with other users | No. Posts, comments, and likes stay on the device. The sample feed is stored in the app and is not sent to other people. |
| The app shares the user’s physical location with other users | No. The app does not request location. |
| The app lets users buy digital goods | No |
| The app is a browser or lets users freely navigate the web | No |
| The app shares personal information publicly | No, in this version |

Apply the rating the questionnaire returns. Save the certificate and the email confirmation. When a later version sends community posts to other people, answer the user-interaction question **Yes**, add in-app report and block controls, and submit the questionnaire again before that release.

## Pricing, countries, and devices

**Monetize → Products** stays empty. There are no in-app products and no subscriptions.

On the release or under **Test and release → Production → Countries / regions** (the same country list can be set on the internal track):

| Setting | Choice |
|---|---|
| Price | Free |
| Ads | No. Declare this under **Policy → App content → Ads**. |
| Countries and regions | All countries and regions Play offers |
| Device types | Phones and tablets |
| Wear OS, Android TV, Android Auto, or ChromeOS-only | Leave those form factors off. The app has no UI for them. |
| Manual device exclusions | None at upload time |

Android 7.0 (API 24) is already the minimum in the bundle, so older phones never see the store page. After the pre-launch report, exclude a specific device only if that report shows a crash on it. **Device catalog → Manage devices** is where that exclusion is saved.

## Play App Signing

The first bundle upload is what enrolls the app. On **Test and release → App integrity → App signing**, choose **Use Play App Signing** so Google holds the app signing key.

The bundle is already signed with the upload key from [Android release signing](android-release.md) (`CN=FitFlow`, alias `upload`). Keep `upload-keystore.jks` and its passwords in the password manager. Play uses that upload key to verify the files you send, then re-signs the installs with the app signing key.

After enrollment, open App signing and record both certificates:

- App signing key certificate
- Upload key certificate

Register the app signing certificate with any later API that requires it (for example Google Sign-In). The upload keystore stays the key the release machine uses. It is not the key users’ devices see.

## Pre-launch report

After the internal release finishes processing, open **Test and release → Internal testing → Pre-launch report**. Review each tab before promoting the release.

| Tab | What to check for this build |
|---|---|
| Crashes | Stability issues on the Firebase Test Lab devices. Exclude a device only if the crash is specific to it. |
| Performance | Cold start and any serious jank on the home tabs. |
| Accessibility | Missing labels or contrast on sign-in, home, and settings. |
| Security | Cleartext traffic. `AndroidManifest.xml` sets `usesCleartextTraffic="true"`, and the client calls `http://10.0.2.2:3000` on Android (`frontend/lib/core/api_config_io.dart`). A security finding here is expected until a release build uses HTTPS. |
| Screenshots | The report’s crawl of sign-in and the tabs. |

Also finish **Policy → App content** or the release stays blocked:

| Form | What to enter |
|---|---|
| Privacy policy | The URL in the store listing table |
| Ads | No |
| App access | All functionality is restricted. Instructions for the reviewer: open the app, create an account or sign in, then the home tabs are available. The account service in this build is a machine on the developer network, so a Play reviewer cannot reach it. Put a reachable HTTPS demo account in these instructions before you submit for review. |
| Target audience | Ages 16–17 and 18 and over. The app is not designed for children. |
| News app | No |
| COVID-19 contact tracing or status | No |
| Data safety | See the next section |
| Government, financial features, health | Not a government app and not a financial app. If a health declaration is shown: fitness and nutrition tracking, not a medical device. |

### Data safety

**Policy → App content → Data safety.** “Collected” means sent off the device. Workouts, meals, weight, settings, and community posts stay on the device in 1.0.1, so they are not collected.

| Data type | Collected | Shared | Purpose | Optional |
|---|---|---|---|---|
| Personal info → Name | Yes | No | Account management | Required |
| Personal info → Email address | Yes | No | Account management | Required |
| Personal info → User IDs | Yes | No | Account management | Required |

Leave Health and fitness, Location, Photos, Contacts, and Financial info unselected. Do not declare the password. It is used only to authenticate and is stored as a bcrypt hash.

| Question | Answer |
|---|---|
| Is all collected user data encrypted in transit? | No, for this build. The client uses HTTP. Switch this to Yes only after the release build talks to the account service over HTTPS. |
| Can users request that their data be deleted? | Yes. They email privacy@fitflow.app. The privacy policy URL is the link to provide. |
| Committed to the Families Policy? | No. Target audience does not include children. |

## Store listing experiments

Play runs one experiment at a time on a store listing, and only after that listing is saved on a track that has a store page. Open **Grow users → Store presence → Store listing experiments**. Primary metric for both tests: retained installers (people who still have the app the day after they install). Split traffic 50/50. Leave every other asset unchanged while a test is running. End the test when the console marks the result conclusive, apply the winner, then start the next one.

### Experiment 1 — short description

Name: `Short description: week vs streak`.

Hypothesis: naming the three jobs (workouts, meals, the week) and that the app is free produces more retained installs than a line about building a session and a streak.

| Arm | Short description | Characters |
|---|---|---|
| Control (current listing) | Plan workouts, log meals, and track your week in one free app. | 62 |
| Variant | Build a session, log meals and water, and keep your streak. | 59 |

### Experiment 2 — full description

Run this after experiment 1. Name: `Full description: week first`.

Hypothesis: opening on “your week” holds more of the people who install than opening on “free fitness companion”, because the listing then leads with the outcome.

Variant (replace only the first paragraph; keep the rest of the full description):

```
See your week in one place: workouts, meals, water, and streak. FitFlow is free.
```

That paragraph is 80 characters. The control is the full description already on the listing.

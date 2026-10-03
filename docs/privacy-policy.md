# FitFlow Privacy Policy

Last updated 3 October 2026 · Version 1.0

Public page: https://cdn.jsdelivr.net/gh/PabodaWA/FItFlow@main/docs/site/privacy/index.html

Support: privacy@fitflow.app

This policy describes FitFlow 1.0.1 (build 2). It matches the app. It is not a substitute for advice from your own lawyer.

## Who we are

FitFlow is a fitness companion for planning workouts, logging meals, tracking progress, and sharing training with other members. The project is published at https://github.com/PabodaWA/FItFlow.

## What this policy covers

It covers the FitFlow apps (iOS, Android, and web) and the FitFlow services that support them: the core account service, the nutrition service, and the AI suggestion service.

In version 1.0.1, your account is stored by the core service. Workout plans, nutrition logs, progress, profile choices, reminders, and community posts stay in the app for that session. They are not uploaded, and this version does not write them to storage on the phone, so they reset when you close the app. Those screens are built so they can later sync to FitFlow services. If that sync is turned on, the categories below are what those services would receive. We will update this policy before we start collecting a new category of information.

## Information we collect

- **Account.** Name, email address, and a password. The password is stored only as a bcrypt hash. The core service also stores a sign-in session (a bearer token and its expiry). The app keeps that token in memory for the current run and does not save it on the phone. Closing the app means you sign in again. Logging out ends the server session.
- **Profile and training.** Display name, fitness goal, streak, workouts completed, and calories burned.
- **Workout preferences used to draft a session.** Goal, experience level, session length, and equipment.
- **Nutrition you choose to log.** Food name, meal, calories, protein, carbs, fat, and water.
- **Progress you choose to record.** Body weight, weekly workouts, calories, duration, and streak. Weight can be shown in kilograms or pounds.
- **Settings.** Workout reminders, weekly summary, and unit choice.
- **Community, when you use it.** Profile name, handle, bio, posts, achievement posts, comments, and likes. In this version that feed stays in the app session and is not sent to other members. If community later syncs, anything you publish would be visible to other FitFlow members, and we will update this policy first.

We do not ask for government ID, payment card numbers, precise GPS, contacts, photos from your camera roll, or advertising identifiers.

## How we use information

We use account data to create your login, keep the session secure, and tell the app which member is signed in. We use fitness, nutrition, and progress information to show your dashboard, plans, meals, and charts, and to honor settings such as reminders and units. We use community content to show the feed you chose to join.

We do not sell personal information. We do not share it with data brokers or use it for third-party advertising.

## AI processing

The in-app workout generator runs on your device. It reads the goal, level, duration, and equipment you select and drafts a session from a fixed exercise catalog. It does not send that form to a server in this version.

A separate FitFlow AI service can accept a goal (for example strength or endurance) and return a short list of workout and meal suggestions from that same kind of catalog. It does not receive your name, email, weight, or community posts. The shipping app does not call that service yet.

Suggestions are optional. You can ignore them and pick another workout. They are not decisions that produce a legal effect or a similarly significant effect. We do not use your information to train third-party models, and we do not sell model inputs.

You can use the rest of FitFlow without generating a workout.

## Social features

The community screens let you publish posts and achievements, comment, and like. In this version that activity stays in the app session. Other members do not receive it.

Do not post another person’s private health details. The screens are built so that, once posts sync, your name, handle, bio, and the text you publish would be visible to other members, along with likes and comments. We will update this policy before that sync starts. You can use training, nutrition, and progress without posting.

## Legal bases under the GDPR

If you are in the European Economic Area, the United Kingdom, or Switzerland, FitFlow is the controller for the account data the core service stores, and for any later sync of the categories in this policy.

- Account data and the features you ask for: contract, Article 6(1)(b).
- Session security: legitimate interests, Article 6(1)(f).
- Reminders and the weekly summary: your choice in Settings, Article 6(1)(a). You can turn them off.
- Weight, diet, and fitness goals: processed only because you enter them for tracking, Article 9(2)(a). In this version those entries stay in the app session and are cleared when you close the app. They are not stored on the core service.

You have the right to access, rectify, erase, restrict, and port your personal data, to object to processing based on legitimate interests, and to withdraw consent. You can also complain to your local supervisory authority. We aim to reply within one month.

Nothing in the AI features is a solely automated decision with a legal or similarly significant effect (Article 22).

## Health data and HIPAA

FitFlow is a consumer wellness app. It is not a hospital, physician practice, health plan, or healthcare clearinghouse, and it is not acting as a business associate of one. We do not bill insurance, accept clinic charts, or offer a Business Associate Agreement.

Body weight, workouts, and meals you enter for your own training are wellness information. In ordinary personal use they are not protected health information under HIPAA.

Do not use FitFlow to store someone else’s medical record or to meet a HIPAA duty. We do not claim to be HIPAA certified.

## Who we share information with

Other FitFlow members see community content you publish. We do not give them your email or password. The person running the FitFlow server you sign in to can access account records as needed to operate and protect the service. Passwords are stored as hashes.

We may disclose information if the law requires it. This version does not use an advertising or analytics vendor.

## How long we keep it

Account records stay on the core service until you ask us to delete the account. A server session ends when you log out or it expires. The token on the phone exists only in memory, so closing the app drops it there even if the server session has not expired yet.

Workouts, meals, progress, settings, and community posts in this version exist only while the app is open. Closing the app clears them. They are not uploaded.

## How we protect it

Passwords are hashed with bcrypt before they are saved. Sign-in uses a bearer token that is removed when you log out. Use a unique password, and reach production servers over HTTPS.

## Children

FitFlow is not directed at anyone under 16. If you believe a child has given us personal information, email privacy@fitflow.app and we will delete the account.

## International transfers

The account service may run outside your country. Where a transfer needs a safeguard, we will use an appropriate mechanism such as standard contractual clauses. You can ask for a summary at privacy@fitflow.app.

## Medical disclaimer

FitFlow is a general fitness and nutrition tracker. It is not a medical device and it does not provide medical advice, diagnosis, or treatment. Talk with a qualified clinician before you change exercise or diet, especially if you are pregnant, injured, or managing a health condition.

## Changes and update history

| Date | Version | Change |
| --- | --- | --- |
| 3 October 2026 | 1.0 | First publication. Account data, session-only fitness and nutrition logs, AI suggestions, community posts, GDPR rights, and HIPAA scope. Same-day correction: workouts, meals, progress, settings, and community posts are not saved on the phone and are not sent to other members in this version. |

## Contact

Email privacy@fitflow.app for access, correction, deletion, or any other privacy request. Include the email on the account. You can also open a request at https://github.com/PabodaWA/FItFlow/issues. Do not include your password or a detailed medical history in an issue.

## Review note

Reviewed on 3 October 2026 against FitFlow 1.0.1: account fields and bcrypt hashing in the core service, a bearer session stored on that service, the in-app token held only in memory, session-only workouts, nutrition, progress, and community, and the on-device AI workout generator. HIPAA is described as out of scope for ordinary personal use because FitFlow is not a covered entity or business associate. This document is not a certification.

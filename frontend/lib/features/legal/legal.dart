import 'package:url_launcher/url_launcher.dart';

/// Version name and build from `frontend/pubspec.yaml` (`1.0.1+2`).
const fitFlowVersionName = '1.0.1';
const fitFlowBuildNumber = '2';
const fitFlowVersionLabel = '$fitFlowVersionName (build $fitFlowBuildNumber)';

const fitFlowSupportEmail = 'privacy@fitflow.app';
const fitFlowIssuesUrl = 'https://github.com/PabodaWA/FItFlow/issues';

/// Canonical public pages. GitHub Pages serves `docs/site`.
const fitFlowPrivacyPolicyUrl = 'https://pabodawa.github.io/FItFlow/privacy/';
const fitFlowReleaseNotesUrl =
    'https://pabodawa.github.io/FItFlow/release-notes/';

final fitFlowPrivacyPolicyUri = Uri.parse(fitFlowPrivacyPolicyUrl);
final fitFlowReleaseNotesUri = Uri.parse(fitFlowReleaseNotesUrl);
final fitFlowSupportUri = Uri.parse('mailto:$fitFlowSupportEmail');
final fitFlowIssuesUri = Uri.parse(fitFlowIssuesUrl);

const fitFlowPolicyUpdated = '3 October 2026';

class LegalSection {
  const LegalSection(this.title, this.paragraphs);

  final String title;
  final List<String> paragraphs;
}

class LegalDocument {
  LegalDocument({
    required this.title,
    required this.kicker,
    required this.publicUri,
    required this.publicLabel,
    required this.sections,
  });

  final String title;
  final String kicker;
  final Uri publicUri;
  final String publicLabel;
  final List<LegalSection> sections;
}

final privacyPolicyDocument = LegalDocument(
  title: 'Privacy Policy',
  kicker: 'Last updated $fitFlowPolicyUpdated · Version 1.0',
  publicUri: fitFlowPrivacyPolicyUri,
  publicLabel: 'Open the public privacy policy',
  sections: [
    LegalSection('Who we are', [
      'FitFlow is a fitness companion for planning workouts, logging meals, tracking progress, and sharing training with other members. The project is published at github.com/PabodaWA/FItFlow.',
      'For privacy questions, email $fitFlowSupportEmail. This policy describes version $fitFlowVersionLabel. It is written so you can see what the app actually does. It is not a substitute for advice from your own lawyer.',
    ]),
    LegalSection('What this policy covers', [
      'It covers the FitFlow apps (iOS, Android, and web) and the FitFlow services that support them: the core account service, the nutrition service, and the AI suggestion service.',
      'In version $fitFlowVersionName, your account is stored by the core service. Workout plans, nutrition logs, progress, profile stats, reminders, and community posts are kept in the app on your device. Those features are built so they can later sync to FitFlow services. If that sync is turned on, the categories below are what those services would receive. We will update this policy before we start collecting a new category of information.',
    ]),
    LegalSection('Information we collect', [
      'Account. Name, email address, and a password. The password is stored only as a bcrypt hash. We also store a sign-in session (a bearer token and its expiry) so you can stay signed in until you log out.',
      'Profile and training. Display name, fitness goal (such as build muscle, lose weight, endurance, flexibility, or general fitness), streak, workouts completed, and calories burned.',
      'Workout preferences used to draft a session. Goal, experience level, session length, and equipment (none, dumbbells, bands, barbell, or a full gym).',
      'Nutrition you choose to log. Food name, meal (breakfast, lunch, dinner, or snacks), calories, protein, carbs, fat, and water intake.',
      'Progress you choose to record. Body weight, weekly workouts, calories, duration, and streak. Weight can be shown in kilograms or pounds.',
      'Settings. Workout reminders, weekly summary, and unit choice.',
      'Community, when you use it. Profile name, handle, bio, posts, achievement posts, comments, and likes. Anything you publish is visible to other FitFlow members.',
      'We do not ask for government ID, payment card numbers, precise GPS, contacts, photos from your camera roll, or advertising identifiers.',
    ]),
    LegalSection('How we use information', [
      'We use account data to create your login, keep the session secure, and tell the app which member is signed in.',
      'We use fitness, nutrition, and progress information to show your dashboard, plans, meals, and charts, and to honor settings such as reminders and units.',
      'We use community content to show the feed you chose to join.',
      'We do not sell personal information. We do not share it with data brokers or use it for third-party advertising.',
    ]),
    LegalSection('AI processing', [
      'The in-app workout generator runs on your device. It reads the goal, level, duration, and equipment you select and drafts a session from a fixed exercise catalog. It does not send that form to a server in this version.',
      'A separate FitFlow AI service can accept a goal (for example strength or endurance) and return a short list of workout and meal suggestions from that same kind of catalog. It does not receive your name, email, weight, or community posts. The shipping app does not call that service yet.',
      'Suggestions are optional. You can ignore them and pick another workout. They are not decisions that produce a legal effect or similarly significant effect, such as credit, employment, or medical treatment. We do not use your information to train third-party models, and we do not sell model inputs.',
      'You can use the rest of FitFlow without generating a workout.',
    ]),
    LegalSection('Social features', [
      'The community feed lets members publish posts and achievements, comment, and like. Your name, handle, bio, and the text you publish are visible to other members of the feed.',
      'Do not post another person’s private health details, or anything you would not want other members to see. Likes and comments are part of the feed and can be seen with the post.',
      'You can use training, nutrition, and progress without posting. In this version, community content stays on the device. If posts later sync to a FitFlow service, other members will see what you publish, and this section still describes that sharing.',
    ]),
    LegalSection('Legal bases under the GDPR', [
      'If you are in the European Economic Area, the United Kingdom, or Switzerland, FitFlow is the controller for the account data the core service stores, and for any later sync of the categories in this policy. Contact $fitFlowSupportEmail.',
      'We process account data and the features you ask for under the contract of providing FitFlow (Article 6(1)(b)). We process security logs such as session expiry under legitimate interests in keeping accounts safe (Article 6(1)(f)). Optional reminders and the weekly summary are off unless you leave them on; you can withdraw that choice in Settings (Article 6(1)(a)).',
      'Weight, diet, and fitness goals can be health-related. We process them only because you enter them so the app can track training and meals (Article 9(2)(a)). Stop entering them, or ask us to delete the account, and that processing stops. Device-only copies are removed when you clear the app’s storage or uninstall it.',
      'You have the right to access, rectify, erase, restrict, and port your personal data, to object to processing based on legitimate interests, and to withdraw consent. You can also complain to your local supervisory authority. We aim to reply within one month.',
      'Nothing in the AI features is a solely automated decision with a legal or similarly significant effect (Article 22).',
    ]),
    LegalSection('Health data and HIPAA', [
      'FitFlow is a consumer wellness app. It is not a hospital, physician practice, health plan, or healthcare clearinghouse, and it is not acting as a business associate of one. We do not bill insurance, accept clinic charts, or offer a Business Associate Agreement.',
      'Body weight, workouts, and meals you enter for your own training are wellness information. In ordinary personal use they are not protected health information under the U.S. Health Insurance Portability and Accountability Act (HIPAA).',
      'Do not use FitFlow to store someone else’s medical record or to meet a HIPAA duty. We do not claim to be HIPAA certified. If a covered organization ever needed FitFlow to handle protected health information, we would have to change this product and sign the agreements HIPAA requires first. We do not do that today.',
    ]),
    LegalSection('Who we share information with', [
      'Other FitFlow members see community content you publish. We do not give them your email or password.',
      'The core service operator (the person running the FitFlow server you sign in to) can access account records as needed to operate and protect the service. Passwords are stored as hashes, not as the password you typed.',
      'We may disclose information if the law requires it, or to respond to a valid legal request. We would share the least the request actually requires.',
      'If we ever use a company to host the account file or send mail, they would process data only on our instructions, and we would name that hosting in an update to this policy. This version does not use an advertising or analytics vendor.',
    ]),
    LegalSection('How long we keep it', [
      'Account records and sessions stay until you log out (sessions) or until you ask us to delete the account. A session that expires is dropped.',
      'On-device workouts, meals, progress, settings, and community posts stay on that device until you change them, clear app storage, or uninstall FitFlow.',
      'We do not keep a separate marketing list.',
    ]),
    LegalSection('How we protect it', [
      'Passwords are hashed with bcrypt before they are saved. Sign-in uses a bearer token that is checked on each account request and removed when you log out. The account file is written by the core service on the machine that runs it.',
      'Use a unique password. Production deployments should be reached over HTTPS. No method of storage is perfect; if we learn of a breach that affects your account, we will tell you and, where the law requires it, the relevant authority.',
    ]),
    LegalSection('Children', [
      'FitFlow is not directed at anyone under 16, and we do not knowingly create accounts for children under 16. If you believe a child has given us personal information, email $fitFlowSupportEmail and we will delete the account.',
    ]),
    LegalSection('International transfers', [
      'The account service may run outside your country, including outside the European Economic Area or the United Kingdom. Where a transfer of personal data needs a safeguard, we will use an appropriate mechanism such as the European Commission’s standard contractual clauses, and you can ask us for a summary at $fitFlowSupportEmail.',
    ]),
    LegalSection('Medical disclaimer', [
      'FitFlow is a general fitness and nutrition tracker. It is not a medical device and it does not provide medical advice, diagnosis, or treatment. Suggestions from the workout generator are exercise ideas, not a prescription.',
      'Talk with a qualified clinician before you change exercise or diet, especially if you are pregnant, injured, or managing a health condition. Stop if you feel pain, dizziness, or distress, and seek care if you need it.',
    ]),
    LegalSection('Changes and update history', [
      'If we change this policy, we will post the new version at the public URL below and change the “Last updated” date. If a change materially expands what we collect or who we share it with, we will also surface it in the app’s release notes.',
      '3 October 2026 — Version 1.0. First publication, covering account data, on-device fitness and nutrition logs, AI suggestions, community posts, GDPR rights, and the HIPAA scope of this consumer app.',
    ]),
    LegalSection('Contact', [
      'Email $fitFlowSupportEmail for access, correction, deletion, or any other privacy request. Include the email address on the account so we can find it.',
      'You can also open a request at $fitFlowIssuesUrl. Please do not include your password or detailed medical history in an issue.',
      'Public policy: $fitFlowPrivacyPolicyUrl',
    ]),
  ],
);

final releaseNotesDocument = LegalDocument(
  title: 'Release notes',
  kicker: 'Version $fitFlowVersionLabel · $fitFlowPolicyUpdated',
  publicUri: fitFlowReleaseNotesUri,
  publicLabel: 'Open the public release notes',
  sections: [
    LegalSection('FitFlow 1.0.1', [
      'Training, meals, and people, in one place. This build connects sign-in to the core service and keeps the rest of your day easy to reach from the home tabs.',
    ]),
    LegalSection('What you can do now', [
      'Create an account and sign in. Your password is stored as a bcrypt hash, and logging out ends the session.',
      'Start from Home. The dashboard points at a session and a suggested workout.',
      'Follow a plan. Open a workout, read the exercises, and start the session.',
      'Draft a workout around your goal, level, time, and equipment. The generator runs on your device, and you can ignore the result.',
      'Log meals from breakfast through snacks, watch calories and macros, and add water a glass at a time.',
      'See the week. Workouts, calories, duration, weight, and streak, in kilograms or pounds.',
      'Show up in Community. Publish a post or an achievement, comment, and like.',
      'Keep a profile. Edit your name, set a goal, check badges, and choose reminders, a weekly summary, and units.',
    ]),
    LegalSection('Also in this build', [
      'The privacy policy is published and linked from Settings, sign-in, and create account.',
      'Release builds can be signed for Google Play. See docs/android-release.md.',
      'Checks run for the Flutter app, the core API, the nutrition API, and the AI service.',
    ]),
    LegalSection('Please read', [
      'FitFlow is a training companion, not a clinician and not a medical device. It does not diagnose, treat, or bill insurance. Read the privacy policy for account data, on-device logs, AI suggestions, community posts, GDPR rights, and why ordinary personal use is outside HIPAA.',
      'Support: $fitFlowSupportEmail. Issues: $fitFlowIssuesUrl.',
    ]),
    LegalSection('Update history', [
      '1.0.1 (build 2) — 3 October 2026. Privacy policy, release notes, and in-app links, on top of accounts, workouts, AI session drafts, nutrition, progress, community, and profile.',
      '1.0.0 — First app. Onboarding, sign-in, and the home screen that later grew the training, nutrition, and community tabs.',
    ]),
  ],
);

Future<bool> openExternalUri(Uri uri) async {
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

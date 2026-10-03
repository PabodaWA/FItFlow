import 'package:fitflow/features/legal/legal.dart';
import 'package:fitflow/features/profile/profile_mock_data.dart';
import 'package:fitflow/features/profile/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('settings links the privacy policy and release notes', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(settings: ProfileMockData.settings),
      ),
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('setting-privacy')),
      300,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('settings-list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('privacy@fitflow.app'), findsOneWidget);
    final disclaimer = find.textContaining('not medical advice');
    await tester.scrollUntilVisible(
      disclaimer,
      200,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('settings-list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(disclaimer, findsOneWidget);

    await tester.tap(find.byKey(const Key('setting-privacy')));
    await tester.pumpAndSettle();

    expect(find.text(fitFlowPrivacyPolicyUrl), findsOneWidget);

    await tester.tap(find.byKey(const Key('legal-public-link')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining(fitFlowPrivacyPolicyUrl), findsWidgets);

    final legalScroll = find
        .descendant(
          of: find.byKey(const Key('legal-document')),
          matching: find.byType(Scrollable),
        )
        .first;
    for (final heading in [
      'AI processing',
      'Social features',
      'Legal bases under the GDPR',
      'Health data and HIPAA',
      'Medical disclaimer',
    ]) {
      await tester.scrollUntilVisible(
        find.text(heading),
        400,
        scrollable: legalScroll,
      );
      expect(find.text(heading), findsOneWidget);
    }

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('setting-release-notes')),
      300,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('settings-list')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.byKey(const Key('setting-release-notes')));
    await tester.pumpAndSettle();

    expect(find.textContaining('1.0.1'), findsWidgets);
    expect(find.text(fitFlowReleaseNotesUrl), findsOneWidget);
    final notesScroll = find
        .descendant(
          of: find.byKey(const Key('legal-document')),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.textContaining('not a clinician'),
      400,
      scrollable: notesScroll,
    );
    expect(find.textContaining('not a clinician'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Update history'),
      400,
      scrollable: notesScroll,
    );
    expect(find.text('Update history'), findsOneWidget);
  });
}

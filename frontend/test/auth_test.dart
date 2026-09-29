import 'package:fitflow/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _openLogin(WidgetTester tester) async {
  await tester.pumpWidget(const FitFlowApp());
  await tester.tap(find.text('Skip'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sign in rejects an empty form', (tester) async {
    await _openLogin(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
  });

  testWidgets('sign in opens home after valid input', (tester) async {
    await _openLogin(tester);

    await tester.enterText(
      find.byKey(const Key('login-email')),
      'ada@fitflow.app',
    );
    await tester.enterText(
      find.byKey(const Key('login-password')),
      'password1',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('You are signed in.'), findsOneWidget);
  });

  testWidgets('create account requires matching passwords', (tester) async {
    await _openLogin(tester);
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('Create your account'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('register-name')),
      'Ada Lovelace',
    );
    await tester.enterText(
      find.byKey(const Key('register-email')),
      'ada@fitflow.app',
    );
    await tester.enterText(
      find.byKey(const Key('register-password')),
      'password1',
    );
    await tester.enterText(
      find.byKey(const Key('register-confirm')),
      'password2',
    );
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Create Account'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
  });

  testWidgets('create account opens home after valid input', (tester) async {
    await _openLogin(tester);
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('register-name')),
      'Ada Lovelace',
    );
    await tester.enterText(
      find.byKey(const Key('register-email')),
      'ada@fitflow.app',
    );
    await tester.enterText(
      find.byKey(const Key('register-password')),
      'password1',
    );
    await tester.enterText(
      find.byKey(const Key('register-confirm')),
      'password1',
    );
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Create Account'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('You are signed in.'), findsOneWidget);
  });

  testWidgets('forgot password confirms a valid email', (tester) async {
    await _openLogin(tester);
    await tester.tap(find.text('Forgot Password'));
    await tester.pumpAndSettle();

    expect(find.text('Reset password'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('forgot-email')), 'not-an-email');
    await tester.tap(find.text('Send reset link'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('forgot-email')),
      'ada@fitflow.app',
    );
    await tester.tap(find.text('Send reset link'));
    await tester.pumpAndSettle();

    expect(find.text('Check your email'), findsOneWidget);
    expect(find.textContaining('ada@fitflow.app'), findsOneWidget);
  });
}

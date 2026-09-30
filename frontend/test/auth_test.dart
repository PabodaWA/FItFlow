import 'package:fitflow/features/auth/auth_api.dart';
import 'package:fitflow/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthApi implements AuthApi {
  FakeAuthApi({this.failure});

  final AuthException? failure;
  int logouts = 0;
  String? loggedOutToken;

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final failure = this.failure;
    if (failure != null) throw failure;
    return AuthSession(
      accessToken: 'token-$email',
      user: AuthUser(id: 'user-1', name: name, email: email),
    );
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final failure = this.failure;
    if (failure != null) throw failure;
    return AuthSession(
      accessToken: 'token-$email',
      user: AuthUser(id: 'user-1', name: 'Ada Lovelace', email: email),
    );
  }

  @override
  Future<void> logout(String accessToken) async {
    logouts += 1;
    loggedOutToken = accessToken;
  }

  @override
  Future<AuthUser> currentUser(String accessToken) async {
    return const AuthUser(
      id: 'user-1',
      name: 'Ada Lovelace',
      email: 'ada@fitflow.app',
    );
  }
}

Future<void> _openLogin(WidgetTester tester, {AuthApi? authApi}) async {
  await tester.pumpWidget(FitFlowApp(authApi: authApi ?? FakeAuthApi()));
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
    expect(find.text('Good Morning 👋'), findsOneWidget);
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

    expect(find.text('Good Morning 👋'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Ada Lovelace'), findsOneWidget);
  });

  testWidgets('sign in shows the server error and stays signed out', (
    tester,
  ) async {
    await _openLogin(
      tester,
      authApi: FakeAuthApi(
        failure: const AuthException('Invalid email or password'),
      ),
    );

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

    expect(find.text('Invalid email or password'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
  });

  testWidgets('logout revokes the session and returns to sign in', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final api = FakeAuthApi();
    await _openLogin(tester, authApi: api);
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

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('menu-logout')), 300);
    await tester.tap(find.byKey(const Key('menu-logout')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-logout')));
    await tester.pumpAndSettle();

    expect(api.logouts, 1);
    expect(api.loggedOutToken, 'token-ada@fitflow.app');
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Ada Lovelace'), findsNothing);
  });

  testWidgets('forgot password confirms a valid email', (tester) async {
    await _openLogin(tester);
    await tester.tap(find.text('Forgot Password'));
    await tester.pumpAndSettle();

    expect(find.text('Reset password'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('forgot-email')),
      'not-an-email',
    );
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

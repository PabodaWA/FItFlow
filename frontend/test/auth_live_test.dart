import 'package:fitflow/features/auth/auth_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const baseUrl = String.fromEnvironment('CORE_API_URL');

  test(
    'register, current user, logout, and login against the core API',
    () async {
      if (baseUrl.isEmpty) return;

      final api = HttpAuthApi(baseUrl: baseUrl);
      final email = 'ada.${DateTime.now().microsecondsSinceEpoch}@fitflow.app';

      final registered = await api.register(
        name: 'Ada Lovelace',
        email: email,
        password: 'password1',
      );
      expect(registered.user.name, 'Ada Lovelace');
      expect(registered.user.email, email);
      expect(registered.accessToken, isNotEmpty);

      final me = await api.currentUser(registered.accessToken);
      expect(me.id, registered.user.id);

      await api.logout(registered.accessToken);
      expect(
        () => api.currentUser(registered.accessToken),
        throwsA(isA<AuthException>()),
      );

      final loggedIn = await api.login(email: email, password: 'password1');
      expect(loggedIn.user.email, email);
      expect(loggedIn.accessToken, isNot(registered.accessToken));

      await expectLater(
        api.login(email: email, password: 'wrong-password'),
        throwsA(
          isA<AuthException>().having(
            (error) => error.message,
            'message',
            'Invalid email or password',
          ),
        ),
      );

      await expectLater(
        api.register(name: 'Ada Lovelace', email: email, password: 'password1'),
        throwsA(
          isA<AuthException>().having(
            (error) => error.message,
            'message',
            'An account with this email already exists',
          ),
        ),
      );

      await api.logout(loggedIn.accessToken);
    },
  );
}

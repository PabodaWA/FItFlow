import 'dart:convert';

import 'package:fitflow/features/auth/auth_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const user = {
    'id': 'user-1',
    'name': 'Ada Lovelace',
    'email': 'ada@fitflow.app',
  };

  test('register and login exchange a token for the current user', () async {
    final requests = <http.Request>[];
    final client = MockClient((request) async {
      requests.add(request);
      if (request.method == 'POST' && request.url.path == '/auth/register') {
        return http.Response(
          jsonEncode({
            'accessToken': 'register-token',
            'tokenType': 'Bearer',
            'user': user,
          }),
          201,
        );
      }
      if (request.method == 'POST' && request.url.path == '/auth/login') {
        return http.Response(
          jsonEncode({
            'accessToken': 'login-token',
            'tokenType': 'Bearer',
            'user': user,
          }),
          200,
        );
      }
      if (request.method == 'GET' && request.url.path == '/auth/me') {
        return http.Response(jsonEncode(user), 200);
      }
      return http.Response('missing', 404);
    });

    final api = HttpAuthApi(client: client, baseUrl: 'http://localhost:3000');
    final registered = await api.register(
      name: 'Ada Lovelace',
      email: 'ada@fitflow.app',
      password: 'password1',
    );
    expect(registered.accessToken, 'register-token');
    expect(registered.user.email, 'ada@fitflow.app');

    final loggedIn = await api.login(
      email: 'ada@fitflow.app',
      password: 'password1',
    );
    expect(loggedIn.accessToken, 'login-token');
    expect(
      requests
          .where((request) => request.url.path == '/auth/me')
          .map((request) => request.headers['authorization']),
      containsAll(['Bearer register-token', 'Bearer login-token']),
    );
  });

  test('logout sends the bearer token and accepts an empty response', () async {
    http.Request? logoutRequest;
    final client = MockClient((request) async {
      logoutRequest = request;
      return http.Response('', 204);
    });

    final api = HttpAuthApi(client: client, baseUrl: 'http://localhost:3000/');
    await api.logout('session-token');

    expect(logoutRequest?.method, 'POST');
    expect(logoutRequest?.url.path, '/auth/logout');
    expect(logoutRequest?.headers['authorization'], 'Bearer session-token');
  });

  test(
    'failed login and duplicate registration surface API messages',
    () async {
      final client = MockClient((request) async {
        if (request.url.path == '/auth/login') {
          return http.Response(
            jsonEncode({
              'statusCode': 401,
              'message': 'Invalid email or password',
            }),
            401,
          );
        }
        return http.Response(
          jsonEncode({
            'statusCode': 409,
            'message': ['An account with this email already exists'],
          }),
          409,
        );
      });

      final api = HttpAuthApi(client: client, baseUrl: 'http://localhost:3000');

      expect(
        () => api.login(email: 'ada@fitflow.app', password: 'password1'),
        throwsA(
          isA<AuthException>().having(
            (error) => error.message,
            'message',
            'Invalid email or password',
          ),
        ),
      );
      expect(
        () => api.register(
          name: 'Ada Lovelace',
          email: 'ada@fitflow.app',
          password: 'password1',
        ),
        throwsA(
          isA<AuthException>().having(
            (error) => error.message,
            'message',
            'An account with this email already exists',
          ),
        ),
      );
    },
  );
}

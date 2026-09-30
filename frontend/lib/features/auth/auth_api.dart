import 'dart:async';
import 'dart:convert';

import 'package:fitflow/core/api_config.dart';
import 'package:http/http.dart' as http;

class AuthUser {
  const AuthUser({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final email = json['email'];
    if (id is! String || name is! String || email is! String) {
      throw AuthException('Something went wrong. Try again.');
    }
    return AuthUser(id: id, name: name, email: email);
  }
}

class AuthSession {
  const AuthSession({required this.accessToken, required this.user});

  final String accessToken;
  final AuthUser user;
}

class AuthException implements Exception {
  const AuthException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

abstract class AuthApi {
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthSession> login({required String email, required String password});

  Future<void> logout(String accessToken);

  Future<AuthUser> currentUser(String accessToken);
}

class HttpAuthApi implements AuthApi {
  HttpAuthApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = _trimBase(baseUrl ?? coreApiBaseUrl());

  final http.Client _client;
  final String _baseUrl;

  static String _trimBase(String baseUrl) {
    if (baseUrl.endsWith('/')) {
      return baseUrl.substring(0, baseUrl.length - 1);
    }
    return baseUrl;
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _openSession('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  @override
  Future<AuthSession> login({required String email, required String password}) {
    return _openSession('/auth/login', {'email': email, 'password': password});
  }

  @override
  Future<void> logout(String accessToken) {
    return _send('POST', '/auth/logout', token: accessToken);
  }

  @override
  Future<AuthUser> currentUser(String accessToken) async {
    final json = await _send('GET', '/auth/me', token: accessToken);
    return AuthUser.fromJson(json);
  }

  Future<AuthSession> _openSession(
    String path,
    Map<String, String> body,
  ) async {
    final json = await _send('POST', path, body: body);
    final token = json['accessToken'];
    if (token is! String || token.isEmpty) {
      throw const AuthException('Something went wrong. Try again.');
    }
    final user = await currentUser(token);
    return AuthSession(accessToken: token, user: user);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, String>? body,
    String? token,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final uri = Uri.parse('$_baseUrl$path');

    late final http.Response response;
    try {
      final future = switch (method) {
        'POST' => _client.post(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        ),
        'GET' => _client.get(uri, headers: headers),
        _ => throw AuthException('Unsupported request $method'),
      };
      response = await future.timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const AuthException(
        'Cannot reach FitFlow. Check that the server is running.',
      );
    } on http.ClientException {
      throw const AuthException(
        'Cannot reach FitFlow. Check that the server is running.',
      );
    }

    if (response.statusCode == 204) return const {};
    final json = _decodeObject(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json;
    }
    throw AuthException(
      _messageFrom(json, response.statusCode),
      statusCode: response.statusCode,
    );
  }

  Map<String, dynamic> _decodeObject(String body) {
    if (body.isEmpty) return const {};
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      return const {};
    }
    return const {};
  }

  String _messageFrom(Map<String, dynamic> json, int statusCode) {
    final message = json['message'];
    if (message is String && message.isNotEmpty) return message;
    if (message is List && message.isNotEmpty) {
      return message.first.toString();
    }
    if (statusCode == 401) return 'Invalid email or password';
    if (statusCode == 409) {
      return 'An account with this email already exists';
    }
    return 'Something went wrong. Try again.';
  }
}

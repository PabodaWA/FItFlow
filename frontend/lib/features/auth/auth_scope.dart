import 'package:fitflow/features/auth/auth_api.dart';
import 'package:flutter/widgets.dart';

abstract class AuthSessionController {
  AuthSession? get session;

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<void> logout();
}

class AuthScope extends StatefulWidget {
  const AuthScope({super.key, required this.api, required this.child});

  final AuthApi api;
  final Widget child;

  static AuthSessionController of(BuildContext context) {
    final actions = maybeOf(context);
    if (actions == null) {
      throw StateError('AuthScope is missing above this widget');
    }
    return actions;
  }

  static AuthSessionController? maybeOf(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_AuthInherited>();
    return inherited?.state;
  }

  @override
  State<AuthScope> createState() => _AuthScopeState();
}

class _AuthScopeState extends State<AuthScope>
    implements AuthSessionController {
  @override
  AuthSession? session;

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final next = await widget.api.register(
      name: name,
      email: email,
      password: password,
    );
    if (mounted) setState(() => session = next);
    session = next;
    return next;
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final next = await widget.api.login(email: email, password: password);
    if (mounted) setState(() => session = next);
    session = next;
    return next;
  }

  @override
  Future<void> logout() async {
    final token = session?.accessToken;
    session = null;
    if (mounted) setState(() {});
    if (token == null) return;
    try {
      await widget.api.logout(token);
    } on AuthException {
      // The local session is already cleared.
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthInherited(state: this, child: widget.child);
  }
}

class _AuthInherited extends InheritedWidget {
  const _AuthInherited({required this.state, required super.child});

  final _AuthScopeState state;

  @override
  bool updateShouldNotify(_AuthInherited oldWidget) {
    return oldWidget.state.session?.accessToken != state.session?.accessToken;
  }
}

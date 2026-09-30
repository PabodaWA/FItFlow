import 'package:fitflow/core/fade_page_route.dart';
import 'package:fitflow/features/auth/auth_api.dart';
import 'package:fitflow/features/auth/auth_scope.dart';
import 'package:fitflow/features/auth/auth_validators.dart';
import 'package:fitflow/features/auth/auth_widgets.dart';
import 'package:fitflow/features/auth/forgot_password_screen.dart';
import 'package:fitflow/features/auth/register_screen.dart';
import 'package:fitflow/features/home/home_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _autovalidateMode = AutovalidateMode.disabled;
  var _submitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    final auth = AuthScope.of(context);
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await auth.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      openHome(context);
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Sign in',
      subtitle: 'Welcome back. Pick up your training where you left off.',
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('login-email'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                validator: validateEmail,
              ),
              const SizedBox(height: 16),
              PasswordField(
                fieldKey: const Key('login-password'),
                controller: _passwordController,
                label: 'Password',
                validator: validatePassword,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _signIn(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      fadePageRoute<void>(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text('Forgot Password'),
                ),
              ),
              const SizedBox(height: 8),
              AuthErrorText(message: _error),
              FilledButton(
                onPressed: _submitting ? null : _signIn,
                child: _submitting
                    ? const SizedBox(
                        key: Key('auth-progress'),
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : const Text('Sign In'),
              ),
              const SizedBox(height: 8),
              AuthSwitchLink(
                prompt: 'New to FitFlow?',
                action: 'Create Account',
                onPressed: () {
                  Navigator.of(context).push(
                    fadePageRoute<void>(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

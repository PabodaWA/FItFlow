import 'package:fitflow/core/fade_page_route.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    openHome(context);
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
              FilledButton(
                onPressed: _signIn,
                child: const Text('Sign In'),
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

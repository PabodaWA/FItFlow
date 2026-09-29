import 'package:fitflow/features/auth/auth_api.dart';
import 'package:fitflow/features/auth/auth_scope.dart';
import 'package:fitflow/features/auth/auth_validators.dart';
import 'package:fitflow/features/auth/auth_widgets.dart';
import 'package:fitflow/features/home/home_screen.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  var _autovalidateMode = AutovalidateMode.disabled;
  var _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_revalidate);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_revalidate);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _revalidate() {
    if (_autovalidateMode == AutovalidateMode.onUserInteraction) {
      _formKey.currentState?.validate();
    }
  }

  Future<void> _createAccount() async {
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
      await auth.register(
        name: _nameController.text.trim(),
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
      title: 'Create your account',
      subtitle: 'Set up FitFlow with the details you use to train.',
      onBack: () => Navigator.of(context).pop(),
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('register-name'),
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.name,
                autofillHints: const [AutofillHints.name],
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: validateFullName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('register-email'),
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
                fieldKey: const Key('register-password'),
                controller: _passwordController,
                label: 'Password',
                helperText: 'At least 8 characters',
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: validatePassword,
              ),
              const SizedBox(height: 16),
              PasswordField(
                fieldKey: const Key('register-confirm'),
                controller: _confirmController,
                label: 'Confirm Password',
                autofillHints: const [AutofillHints.newPassword],
                validator: (value) {
                  return validateConfirmPassword(
                    value,
                    _passwordController.text,
                  );
                },
                onFieldSubmitted: (_) => _createAccount(),
              ),
              const SizedBox(height: 24),
              AuthErrorText(message: _error),
              FilledButton(
                onPressed: _submitting ? null : _createAccount,
                child: _submitting
                    ? const SizedBox(
                        key: Key('auth-progress'),
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : const Text('Create Account'),
              ),
              const SizedBox(height: 8),
              AuthSwitchLink(
                prompt: 'Already have an account?',
                action: 'Sign in',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

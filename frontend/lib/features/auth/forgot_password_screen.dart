import 'package:fitflow/features/auth/auth_validators.dart';
import 'package:fitflow/features/auth/auth_widgets.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  var _autovalidateMode = AutovalidateMode.disabled;
  var _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final email = _emailController.text.trim();

    return AuthScaffold(
      title: _submitted ? 'Check your email' : 'Reset password',
      subtitle: _submitted
          ? 'If an account matches $email, reset instructions will be sent there.'
          : 'Enter the email for your FitFlow account.',
      onBack: () => Navigator.of(context).pop(),
      child: _submitted
          ? FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to sign in'),
            )
          : Form(
              key: _formKey,
              autovalidateMode: _autovalidateMode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    key: const Key('forgot-email'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.email],
                    autocorrect: false,
                    onFieldSubmitted: (_) => _sendResetLink(),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _sendResetLink,
                    child: const Text('Send reset link'),
                  ),
                ],
              ),
            ),
    );
  }
}

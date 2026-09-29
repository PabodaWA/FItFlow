final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) {
    return 'Enter your email';
  }
  if (!_emailPattern.hasMatch(email)) {
    return 'Enter a valid email';
  }
  return null;
}

String? validatePassword(String? value) {
  final password = value ?? '';
  if (password.isEmpty) {
    return 'Enter your password';
  }
  if (password.length < 8) {
    return 'Use at least 8 characters';
  }
  return null;
}

String? validateFullName(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) {
    return 'Enter your full name';
  }
  return null;
}

String? validateConfirmPassword(String? value, String password) {
  final confirmation = value ?? '';
  if (confirmation.isEmpty) {
    return 'Confirm your password';
  }
  if (confirmation != password) {
    return 'Passwords do not match';
  }
  return null;
}

import 'package:fitflow/features/auth/auth_api.dart';
import 'package:fitflow/features/auth/auth_scope.dart';
import 'package:fitflow/features/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(FitFlowApp(authApi: HttpAuthApi()));
}

class FitFlowApp extends StatefulWidget {
  const FitFlowApp({super.key, this.authApi});

  final AuthApi? authApi;

  @override
  State<FitFlowApp> createState() => _FitFlowAppState();
}

class _FitFlowAppState extends State<FitFlowApp> {
  late final AuthApi _authApi = widget.authApi ?? HttpAuthApi();

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      api: _authApi,
      child: MaterialApp(
        title: 'FitFlow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B7F4E)),
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        home: const OnboardingScreen(),
      ),
    );
  }
}

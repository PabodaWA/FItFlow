import 'package:fitflow/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('onboarding advances to authentication', (tester) async {
    await tester.pumpWidget(const FitFlowApp());

    expect(find.text('Welcome to FitFlow'), findsOneWidget);
    expect(
      find.text('Build healthier habits and reach your fitness goals.'),
      findsOneWidget,
    );
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Personalized Workouts'), findsOneWidget);
    expect(
      find.text('Get workouts designed around your fitness goals.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Track Your Progress'), findsOneWidget);
    expect(
      find.text('Monitor workouts, nutrition, and your progress.'),
      findsOneWidget,
    );
    expect(find.text('Get Started'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Welcome to FitFlow'), findsNothing);
  });

  testWidgets('skip leaves onboarding for authentication', (tester) async {
    await tester.pumpWidget(const FitFlowApp());

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Welcome to FitFlow'), findsNothing);
  });
}

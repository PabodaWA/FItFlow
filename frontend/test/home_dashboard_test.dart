import 'package:fitflow/features/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          );
        },
        home: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('dashboard shows the home sections', (tester) async {
    await pumpHome(tester);

    expect(find.text('Good Morning 👋'), findsOneWidget);
    expect(find.text('Ready for your workout?'), findsOneWidget);
    expect(find.text('Calories'), findsOneWidget);
    expect(find.text('Steps'), findsOneWidget);
    expect(find.text('Workout minutes'), findsOneWidget);
    expect(find.text('Full Body Strength'), findsOneWidget);
    expect(find.text('45 min • 8 exercises'), findsOneWidget);
    expect(find.text('Start Workout'), findsOneWidget);
    expect(find.text('✨ AI Coach'), findsOneWidget);
    expect(find.text('Your personalized workout is ready.'), findsOneWidget);
    expect(find.text('View Recommendation'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Weekly Progress'), 300);
    expect(find.text('Weekly Progress'), findsOneWidget);
    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('Sun'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Workouts'), findsOneWidget);
    expect(find.text('Nutrition'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('dashboard avoids overflow on common sizes', (tester) async {
    const sizes = <Size>[
      Size(320, 568),
      Size(360, 640),
      Size(390, 844),
      Size(768, 1024),
      Size(800, 400),
    ];

    for (final size in sizes) {
      await pumpHome(tester, size: size);
      await tester.scrollUntilVisible(find.text('Sun'), 400);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await pumpHome(tester, size: const Size(340, 700), textScale: 1.4);
    await tester.scrollUntilVisible(find.text('Sun'), 400);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'start workout opens details and recommendation opens AI workout',
    (tester) async {
      await pumpHome(tester);

      await tester.ensureVisible(find.text('Start Workout'));
      await tester.tap(find.text('Start Workout'));
      await tester.pumpAndSettle();
      expect(find.text('Goblet Squats'), findsOneWidget);
      expect(find.text('Exercises'), findsOneWidget);
      expect(find.text('This workout will be available soon.'), findsNothing);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('View Recommendation'));
      await tester.tap(find.text('View Recommendation'));
      await tester.pumpAndSettle();
      expect(find.text('AI Workout'), findsOneWidget);
      expect(find.text('Generate Workout'), findsOneWidget);
      expect(find.text('Fitness goal'), findsOneWidget);
      expect(find.text('Build Muscle'), findsOneWidget);
      expect(
        find.text('Your recommendation will be available soon.'),
        findsNothing,
      );
    },
  );

  testWidgets('bottom navigation opens each tab', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('Workouts'));
    await tester.pumpAndSettle();
    expect(find.text('Pick a session and start training.'), findsOneWidget);
    expect(find.text('Upper Body Power'), findsOneWidget);
    expect(find.text('Workout plans will show up here.'), findsNothing);

    await tester.tap(find.text('Nutrition'));
    await tester.pumpAndSettle();
    expect(find.text('Today\'s intake'), findsOneWidget);
    expect(find.text('Daily calories'), findsOneWidget);
    expect(find.text('Nutrition tracking will show up here.'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Greek yogurt with berries'),
      300,
    );
    expect(find.text('Greek yogurt with berries'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Apple and almonds'), 300);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Community'));
    await tester.pumpAndSettle();
    expect(find.text('Community features will show up here.'), findsNothing);
    expect(find.text('Jordan Hale'), findsWidgets);
    expect(find.byKey(const Key('create-post-button')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Completed my Full Body Workout 💪'),
      300,
    );
    expect(find.text('Completed my Full Body Workout 💪'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Your profile will show up here.'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Good Morning 👋'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Your profile will show up here.'), findsOneWidget);
  });
}

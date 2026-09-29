import 'package:fitflow/features/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
  }

  Future<void> openWorkouts(WidgetTester tester) async {
    await tester.tap(find.text('Workouts'));
    await tester.pumpAndSettle();
  }

  Future<void> popVisible(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Back').hitTestable());
    await tester.pumpAndSettle();
  }

  Future<void> reveal(
    WidgetTester tester,
    Finder finder, {
    required Finder scrollable,
  }) async {
    await tester.scrollUntilVisible(finder, 280, scrollable: scrollable);
    for (var attempt = 0; attempt < 6; attempt++) {
      if (finder.hitTestable().evaluate().isNotEmpty) return;
      await tester.drag(scrollable, const Offset(0, -160));
      await tester.pumpAndSettle();
    }
    expect(finder.hitTestable(), findsOneWidget);
  }

  Finder scrollableOf(Key key) {
    return find
        .descendant(of: find.byKey(key), matching: find.byType(Scrollable))
        .first;
  }

  testWidgets('workout list filters categories and opens a session', (
    tester,
  ) async {
    await pumpHome(tester);
    await openWorkouts(tester);

    expect(find.text('Strength'), findsWidgets);
    expect(find.text('Cardio'), findsWidgets);
    expect(find.text('HIIT'), findsWidgets);
    expect(find.text('Flexibility'), findsWidgets);
    expect(find.text('Full Body'), findsWidgets);
    expect(find.text('11 workouts'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('workout-filter-hiit')));
    await tester.tap(find.byKey(const Key('workout-filter-hiit')));
    await tester.pumpAndSettle();

    expect(find.text('2 workouts'), findsOneWidget);
    expect(find.byKey(const Key('workout-card-fat-burn-hiit')), findsOneWidget);
    expect(find.byKey(const Key('workout-card-beginner-hiit')), findsOneWidget);
    expect(
      find.byKey(const Key('workout-card-upper-body-power')),
      findsNothing,
    );

    await tester.ensureVisible(find.byKey(const Key('workout-filter-all')));
    await tester.tap(find.byKey(const Key('workout-filter-all')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('workout-card-steady-state-cardio')),
      400,
      scrollable: scrollableOf(const Key('workout-list')),
    );
    await tester.tap(find.byKey(const Key('workout-card-steady-state-cardio')));
    await tester.pumpAndSettle();

    expect(find.text('Steady State Cardio'), findsWidgets);
    expect(find.text('Duration'), findsOneWidget);
    expect(find.text('Calories'), findsOneWidget);
    expect(find.text('Difficulty'), findsOneWidget);
    expect(find.text('220'), findsOneWidget);
    expect(find.text('March in Place'), findsOneWidget);

    await reveal(
      tester,
      find.byKey(
        const Key('exercise-tile-steady-state-cardio-standing-knee-lift'),
      ),
      scrollable: scrollableOf(const Key('workout-details-scroll')),
    );
    await tester.tap(
      find.byKey(
        const Key('exercise-tile-steady-state-cardio-standing-knee-lift'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Standing Knee Lift'), findsOneWidget);
    expect(find.text('Sets'), findsOneWidget);
    expect(find.text('Repetitions'), findsOneWidget);
    expect(find.text('Rest'), findsOneWidget);
    expect(find.text('16'), findsOneWidget);
    expect(find.text('20s'), findsWidgets);

    await popVisible(tester);
    expect(find.text('March in Place'), findsOneWidget);

    await tester.tap(find.byKey(const Key('workout-details-start')));
    await tester.pumpAndSettle();

    expect(find.text('Exercise 1 of 4'), findsOneWidget);
    expect(find.text('Set 1 of 3'), findsOneWidget);
    expect(find.text('Complete set'), findsOneWidget);

    await tester.tap(find.byKey(const Key('session-primary-button')));
    await tester.pumpAndSettle();
    expect(find.text('Rest 20s before the next set.'), findsOneWidget);
    expect(find.text('Next set'), findsOneWidget);

    await tester.ensureVisible(find.text('Exercise details'));
    await tester.tap(find.text('Exercise details'));
    await tester.pumpAndSettle();
    expect(find.text('March in Place'), findsWidgets);
    expect(find.text('Repetitions'), findsWidgets);
    await popVisible(tester);

    for (var step = 0; step < 40; step++) {
      if (find.text('Workout complete').evaluate().isNotEmpty) break;
      await tester.tap(find.byKey(const Key('session-primary-button')));
      await tester.pumpAndSettle();
    }

    expect(find.text('Workout complete'), findsOneWidget);
    expect(find.text('You finished Steady State Cardio.'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    await tester.tap(find.byKey(const Key('session-primary-button')));
    await tester.pumpAndSettle();
    expect(find.text('Workout complete'), findsNothing);
    expect(find.text('March in Place'), findsOneWidget);

    await popVisible(tester);
    expect(
      find.byKey(const Key('workout-card-steady-state-cardio')),
      findsOneWidget,
    );
  });

  testWidgets('workout screens avoid overflow on a small phone', (
    tester,
  ) async {
    await pumpHome(tester, size: const Size(320, 568));
    await openWorkouts(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('workout-card-full-body-strength')),
      500,
      scrollable: scrollableOf(const Key('workout-list')),
    );
    await tester.tap(find.byKey(const Key('workout-card-full-body-strength')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('exercise-tile-full-body-strength-goblet-squats')),
      300,
      scrollable: scrollableOf(const Key('workout-details-scroll')),
    );
    await tester.tap(
      find.byKey(const Key('exercise-tile-full-body-strength-goblet-squats')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Goblet Squats'), findsOneWidget);
    expect(find.text('1 min'), findsOneWidget);
    await popVisible(tester);
    await tester.scrollUntilVisible(
      find.text('Bicycle Crunches'),
      400,
      scrollable: scrollableOf(const Key('workout-details-scroll')),
    );
    await tester.tap(find.byKey(const Key('workout-details-start')));
    await tester.pumpAndSettle();
    expect(find.text('Exercise 1 of 8'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

import 'package:fitflow/features/ai_workout/ai_workout_models.dart';
import 'package:fitflow/features/home/home_screen.dart';
import 'package:fitflow/features/profile/profile_mock_data.dart';
import 'package:fitflow/features/profile/profile_models.dart';
import 'package:fitflow/features/profile/profile_view.dart';
import 'package:fitflow/features/progress/progress_mock_data.dart';
import 'package:fitflow/features/progress/progress_models.dart';
import 'package:fitflow/features/progress/progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sample profile matches the local training summary', () {
    final profile = ProfileMockData.jordan;
    final goals = ProfileMockData.goals;
    final badges = ProfileMockData.achievements;

    expect(profile.name, 'Jordan Hale');
    expect(profile.initials, 'JH');
    expect(profile.goal, FitnessGoal.buildMuscle);
    expect(profile.streakDays, 12);
    expect(profile.workoutsCompleted, 86);
    expect(profile.caloriesBurned, 24860);
    expect(formatStatCount(profile.caloriesBurned), '24,860');
    expect(
      goals.singleWhere((goal) => goal.kind == profile.goal).title,
      'Build Muscle',
    );
    expect(goals.first.progress, 0.75);
    expect(goals[3].progress, closeTo(0.84, 0.001));
    expect(goals.last.progress, closeTo(0.4, 0.001));
    expect(earnedAchievementCount(badges), 4);
    expect(badges.where((badge) => !badge.earned).map((badge) => badge.id), [
      'thirty-day',
      'century',
    ]);
  });

  test('editing a profile keeps the previous values unchanged', () {
    final profile = ProfileMockData.jordan;
    final renamed = profile.copyWith(
      name: 'Alex Rivera',
      initials: initialsFor('Alex Rivera'),
      goal: FitnessGoal.loseWeight,
    );

    expect(profile.name, 'Jordan Hale');
    expect(profile.goal, FitnessGoal.buildMuscle);
    expect(renamed.name, 'Alex Rivera');
    expect(renamed.initials, 'AR');
    expect(renamed.goal, FitnessGoal.loseWeight);
    expect(renamed.streakDays, 12);
    expect(renamed.workoutsCompleted, 86);
    expect(renamed.caloriesBurned, 24860);
    expect(
      ProfileMockData.settings.copyWith(useMetricUnits: false).useMetricUnits,
      isFalse,
    );
    expect(ProfileMockData.settings.useMetricUnits, isTrue);
  });

  test('names and goal ratios are validated', () {
    expect(initialsFor('Jordan Hale'), 'JH');
    expect(initialsFor('  maya   chen  '), 'MC');
    expect(initialsFor('Alex'), 'A');
    expect(initialsFor('   '), '?');
    expect(validateProfileName('  '), 'Enter your name.');
    expect(validateProfileName('J'), 'Use at least 2 characters.');
    expect(validateProfileName('Jo'), isNull);
    expect(validateProfileName('a' * 41), 'Use 40 characters or fewer.');
    expect(ratioProgress(18, 24), 0.75);
    expect(ratioProgress(30, 24), 1);
    expect(ratioProgress(0, 24), 0);
    expect(ratioProgress(4, 0), 0);
    expect(formatStatCount(0), '0');
    expect(formatStatCount(2520), '2,520');
  });

  test(
    'weekly progress totals, weight, and chart scale match the mock week',
    () {
      final week = ProgressMockData.week;

      expect(week.weeklyWorkouts, 8);
      expect(week.caloriesBurned, 2520);
      expect(week.durationMinutes, 241);
      expect(week.currentWeightKg, 78.4);
      expect(week.workoutProgress, 1);
      expect(week.calorieProgress, closeTo(0.84, 0.001));
      expect(week.durationProgress, 1);
      expect(week.weightProgressValue, closeTo(0.6, 0.001));
      expect(week.streakProgress, closeTo(0.4, 0.001));
      expect(week.streakDays, 12);
      expect(week.bestStreakDays, 21);
      expect(week.peak((day) => day.workouts), 2);
      expect(week.peak((day) => day.calories), 540);
      expect(week.peak((day) => day.durationMinutes), 57);
      expect(chartFraction(2, 2), 1);
      expect(chartFraction(0, 2), 0);
      expect(chartFraction(5, 0), 0);
      expect(chartFraction(3, 2), 1);
      expect(visualBarFraction(0, 2), 0);
      expect(visualBarFraction(1, 100), 0.08);
      expect(weightProgress(76, 78.4, 80), closeTo(0.6, 0.001));
      expect(weightProgress(80, 78, 75), closeTo(0.4, 0.001));
      expect(weightProgress(70, 70, 70), 1);
      expect(weightProgress(70, 71, 70), 0);
      expect(formatBodyWeight(78.4, useMetric: true), '78.4 kg');
      expect(formatBodyWeight(78.4, useMetric: false), '172.8 lb');
      expect(
        weightSummaryLabel(
          startKg: 76,
          currentKg: 78.4,
          targetKg: 80,
          useMetric: true,
        ),
        '76.0 kg start · 78.4 kg now · 80.0 kg goal',
      );
    },
  );

  testWidgets('profile shows the image, summary, and account actions', (
    tester,
  ) async {
    await pumpProfile(tester);

    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Your training summary.'), findsOneWidget);
    expect(find.byKey(const Key('profile-image')), findsOneWidget);
    expect(find.bySemanticsLabel('Profile image'), findsOneWidget);
    expect(find.text('JH'), findsOneWidget);
    expect(find.text('Jordan Hale'), findsOneWidget);
    expect(find.text('Build Muscle'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Current streak'), findsOneWidget);
    expect(find.text('86'), findsOneWidget);
    expect(find.text('Workouts completed'), findsOneWidget);
    expect(find.text('24,860'), findsOneWidget);
    expect(find.text('Calories burned'), findsOneWidget);
    expect(find.text('Your profile will show up here.'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Logout'),
      300,
      scrollable: scrollableOf(const Key('profile-list')),
    );
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('My Goals'), findsOneWidget);
    expect(find.text('Achievements'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('edit profile updates the name and fitness goal', (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.byKey(const Key('menu-edit-profile')));
    await tester.pumpAndSettle();
    expect(find.text('Update your name and fitness goal.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('edit-profile-name')), ' ');
    await tester.tap(find.byKey(const Key('save-profile')));
    await tester.pumpAndSettle();
    expect(find.text('Enter your name.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('edit-profile-name')),
      'Alex Rivera',
    );
    await tester.tap(find.byKey(const Key('edit-goal-loseWeight')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-profile')));
    await tester.pumpAndSettle();

    expect(find.text('Alex Rivera'), findsOneWidget);
    expect(find.text('AR'), findsOneWidget);
    expect(find.text('Lose Weight'), findsOneWidget);
    expect(find.text('Jordan Hale'), findsNothing);
    expect(find.text('86'), findsOneWidget);
    expect(find.text('24,860'), findsOneWidget);
  });

  testWidgets('goals, achievements, and settings stay on the profile', (
    tester,
  ) async {
    await pumpProfile(tester);

    await tester.tap(find.byKey(const Key('menu-goals')));
    await tester.pumpAndSettle();
    expect(
      find.text('Choose the goal that leads your training.'),
      findsOneWidget,
    );
    expect(find.text('18 / 24 sessions'), findsOneWidget);
    expect(find.text('2,520 / 3,000 kcal'), findsOneWidget);
    expect(find.text('Current goal'), findsOneWidget);
    expect(find.byKey(const Key('current-goal-build-muscle')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('set-goal-lose-weight')),
      300,
      scrollable: scrollableOf(const Key('goals-list')),
    );
    await tester.tap(find.byKey(const Key('set-goal-lose-weight')));
    await tester.pumpAndSettle();
    expect(find.text('Lose Weight'), findsOneWidget);
    expect(find.text('Current goal'), findsNothing);

    await tester.tap(find.byKey(const Key('menu-achievements')));
    await tester.pumpAndSettle();
    expect(find.text('4 of 6 earned'), findsOneWidget);
    expect(find.text('First Workout'), findsOneWidget);
    expect(find.text('Finished your first FitFlow session.'), findsOneWidget);
    expect(find.text('Earned'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('100 Workouts'),
      300,
      scrollable: scrollableOf(const Key('achievements-list')),
    );
    expect(find.text('30-day Streak'), findsOneWidget);
    expect(find.text('Locked'), findsWidgets);
    expect(find.text('100 Workouts'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('menu-settings')),
      300,
      scrollable: scrollableOf(const Key('profile-list')),
    );
    await tester.tap(find.byKey(const Key('menu-settings')));
    await tester.pumpAndSettle();
    expect(find.text('Workout reminders'), findsOneWidget);
    expect(find.text('Weekly summary'), findsOneWidget);
    expect(find.text('Use kilograms'), findsOneWidget);
    expect(
      tester
          .widget<SwitchListTile>(find.byKey(const Key('setting-reminders')))
          .value,
      isTrue,
    );
    await tester.tap(find.byKey(const Key('setting-reminders')));
    await tester.tap(find.byKey(const Key('setting-metric')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-settings')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('menu-settings')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SwitchListTile>(find.byKey(const Key('setting-reminders')))
          .value,
      isFalse,
    );
    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const Key('setting-weekly-summary')),
          )
          .value,
      isTrue,
    );
    expect(
      tester
          .widget<SwitchListTile>(find.byKey(const Key('setting-metric')))
          .value,
      isFalse,
    );
  });

  testWidgets('logout returns to sign in', (tester) async {
    await pumpProfile(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('menu-logout')),
      300,
      scrollable: scrollableOf(const Key('profile-list')),
    );
    await tester.tap(find.byKey(const Key('menu-logout')));
    await tester.pumpAndSettle();
    expect(find.text('Log out?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('cancel-logout')));
    await tester.pumpAndSettle();
    expect(find.text('Jordan Hale'), findsOneWidget);

    await tester.tap(find.byKey(const Key('menu-logout')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-logout')));
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Jordan Hale'), findsNothing);
  });

  testWidgets('profile edits remain after switching tabs', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('menu-edit-profile')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('edit-profile-name')),
      'Alex Rivera',
    );
    await tester.tap(find.byKey(const Key('save-profile')));
    await tester.pumpAndSettle();
    expect(find.text('Alex Rivera'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Alex Rivera'), findsOneWidget);
    expect(find.text('AR'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('progress shows charts for the weekly snapshot', (tester) async {
    await pumpProfile(tester, size: const Size(390, 1400));
    await tester.tap(find.byKey(const Key('open-progress')));
    await tester.pumpAndSettle();

    expect(find.text('Progress'), findsWidgets);
    expect(find.text('This week'), findsWidgets);
    expect(find.text('Weekly workouts'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('8 / 5 workouts'), findsOneWidget);
    expect(find.text('Calories burned'), findsOneWidget);
    expect(find.text('2,520 kcal'), findsWidgets);
    expect(find.text('2,520 / 3,000 kcal'), findsOneWidget);
    expect(find.text('Workout duration'), findsOneWidget);
    expect(find.text('241 min'), findsOneWidget);
    expect(find.text('241 / 240 min'), findsOneWidget);
    expect(find.text('Mon'), findsWidgets);
    expect(find.text('Sun'), findsWidgets);
    expect(find.byType(LinearProgressIndicator), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Weight progress'),
      300,
      scrollable: scrollableOf(const Key('progress-list')),
    );
    expect(find.text('Weight progress'), findsOneWidget);
    expect(find.text('78.4 kg'), findsWidgets);
    expect(find.text('60% to goal'), findsOneWidget);
    expect(find.text('W1'), findsOneWidget);
    expect(find.text('W8'), findsOneWidget);
    expect(
      find.text('76.0 kg start · 78.4 kg now · 80.0 kg goal'),
      findsOneWidget,
    );
    expect(find.byType(CustomPaint), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('12 day streak'),
      300,
      scrollable: scrollableOf(const Key('progress-list')),
    );
    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('12 day streak'), findsOneWidget);
    expect(find.text('Best 21 days · 12 / 30'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsNWidgets(7));
    expect(tester.takeException(), isNull);
  });

  testWidgets('pounds are used when kilograms are turned off', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ProgressScreen(useMetricUnits: false)),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('progress-weight-value')),
      400,
      scrollable: scrollableOf(const Key('progress-list')),
    );
    expect(find.text('172.8 lb'), findsWidgets);
    expect(
      find.text('167.6 lb start · 172.8 lb now · 176.4 lb goal'),
      findsOneWidget,
    );
    expect(find.text('78.4 kg'), findsNothing);
  });

  testWidgets('profile and progress avoid overflow on common sizes', (
    tester,
  ) async {
    const sizes = <Size>[
      Size(320, 568),
      Size(360, 640),
      Size(390, 844),
      Size(768, 1024),
      Size(800, 400),
    ];

    for (final size in sizes) {
      await pumpProfile(tester, size: size);
      await tester.scrollUntilVisible(
        find.text('Logout'),
        400,
        scrollable: scrollableOf(const Key('profile-list')),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.scrollUntilVisible(
        find.byKey(const Key('open-progress')),
        400,
        scrollable: scrollableOf(const Key('profile-list')),
      );
      await tester.tap(find.byKey(const Key('open-progress')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('12 day streak'),
        500,
        scrollable: scrollableOf(const Key('progress-list')),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await pumpProfile(tester, size: const Size(340, 700), textScale: 1.4);
    await tester.scrollUntilVisible(
      find.byKey(const Key('open-progress')),
      400,
      scrollable: scrollableOf(const Key('profile-list')),
    );
    await tester.tap(find.byKey(const Key('open-progress')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('12 day streak'),
      500,
      scrollable: scrollableOf(const Key('progress-list')),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

Finder scrollableOf(Key key) {
  return find
      .descendant(of: find.byKey(key), matching: find.byType(Scrollable))
      .first;
}

Future<void> pumpProfile(
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B7F4E)),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        );
      },
      home: const ProfileView(),
      key: UniqueKey(),
    ),
  );
  await tester.pumpAndSettle();
}

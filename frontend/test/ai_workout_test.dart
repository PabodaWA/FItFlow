import 'package:fitflow/features/ai_workout/ai_workout_generator.dart';
import 'package:fitflow/features/ai_workout/ai_workout_mock_data.dart';
import 'package:fitflow/features/ai_workout/ai_workout_models.dart';
import 'package:fitflow/features/ai_workout/ai_workout_screen.dart';
import 'package:fitflow/features/home/home_screen.dart';
import 'package:fitflow/features/workout/workout_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mock plans follow goal, level, time, and equipment', () {
    final plan = AiWorkoutMockData.build(AiWorkoutPreferences.initial);

    expect(plan.workout.name, 'Build Muscle Workout');
    expect(plan.workout.durationMinutes, 45);
    expect(plan.workout.difficulty, WorkoutDifficulty.intermediate);
    expect(plan.exercises, hasLength(6));
    expect(
      plan.exercises.fold<int>(0, (sum, item) => sum + item.durationMinutes),
      45,
    );
    expect(plan.workout.exercises.map((exercise) => exercise.id), [
      'db-goblet-squat',
      'db-bench-press',
      'db-row',
      'db-shoulder-press',
      'db-rdl',
      'db-hammer-curl',
    ]);

    final squat = plan.exercises.first;
    expect(squat.exercise.name, 'Dumbbell Goblet Squat');
    expect(squat.exercise.sets, 4);
    expect(squat.exercise.repetitions, 12);
    expect(squat.exercise.restSeconds, 60);
    expect(squat.durationMinutes, 8);

    final press = plan.exercises[3];
    expect(press.exercise.name, 'Dumbbell Shoulder Press');
    expect(press.exercise.sets, 3);
    expect(press.exercise.restLabel, '1 min');
    expect(press.durationMinutes, 7);

    final beginner = AiWorkoutMockData.build(
      const AiWorkoutPreferences(
        goal: FitnessGoal.loseWeight,
        level: FitnessLevel.beginner,
        durationMinutes: 15,
        equipment: WorkoutEquipment.none,
      ),
    );
    expect(beginner.exercises.map((item) => item.exercise.name), [
      'Jump Squats',
      'Push-Ups',
      'Mountain Climbers',
    ]);
    expect(beginner.exercises.first.exercise.sets, 3);
    expect(beginner.exercises.first.exercise.repetitions, 14);
    expect(beginner.exercises.first.exercise.restSeconds, 45);
    expect(
      beginner.exercises.fold<int>(
        0,
        (sum, item) => sum + item.durationMinutes,
      ),
      15,
    );
    expect(
      beginner.exercises.any((item) => item.exercise.name.contains('Dumbbell')),
      isFalse,
    );

    for (final minutes in availableWorkoutTimes) {
      for (final goal in FitnessGoal.values) {
        for (final level in FitnessLevel.values) {
          for (final equipment in WorkoutEquipment.values) {
            final generated = AiWorkoutMockData.build(
              AiWorkoutPreferences(
                goal: goal,
                level: level,
                durationMinutes: minutes,
                equipment: equipment,
              ),
            );
            final total = generated.exercises.fold<int>(
              0,
              (sum, item) => sum + item.durationMinutes,
            );
            expect(
              total,
              minutes,
              reason: '${goal.name} ${level.name} ${equipment.name} $minutes',
            );
            expect(generated.exercises, isNotEmpty);
            expect(
              generated.workout.exercises.length,
              generated.exercises.length,
            );
          }
        }
      }
    }
  });

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

  Future<void> tapWhenVisible(
    WidgetTester tester,
    Finder finder, {
    required Finder scrollable,
  }) async {
    await tester.scrollUntilVisible(finder, 240, scrollable: scrollable);
    for (var attempt = 0; attempt < 8; attempt++) {
      if (finder.hitTestable().evaluate().isNotEmpty) break;
      await tester.drag(scrollable, const Offset(0, -140));
      await tester.pumpAndSettle();
    }
    expect(finder.hitTestable(), findsOneWidget);
    await tester.tap(finder);
  }

  Future<void> generateWorkout(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('generate-workout-button')));
    await tester.pump();
    expect(find.text(aiWorkoutLoadingMessage), findsOneWidget);
    expect(find.text('Dumbbell Goblet Squat'), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  Finder exerciseCard(String id) => find.byKey(Key('generated-exercise-$id'));

  Finder scrollableOf(Key key) {
    return find
        .descendant(of: find.byKey(key), matching: find.byType(Scrollable))
        .first;
  }

  void expectMetric(String id, String value) {
    expect(
      find.descendant(of: exerciseCard(id), matching: find.text(value)),
      findsWidgets,
    );
  }

  testWidgets('dashboard AI coach generates a workout and starts it', (
    tester,
  ) async {
    await pumpHome(tester);
    await tapWhenVisible(
      tester,
      find.text('View Recommendation'),
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('AI Workout'), findsOneWidget);
    expect(find.text('Fitness goal'), findsOneWidget);
    expect(find.text('Fitness level'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Equipment available'),
      240,
      scrollable: scrollableOf(const Key('ai-workout-form')),
    );
    expect(find.text('Available workout time'), findsOneWidget);
    expect(find.text('Equipment available'), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(const Key('ai-goal-buildMuscle')))
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(const Key('ai-level-intermediate')))
          .selected,
      isTrue,
    );
    expect(
      tester.widget<ChoiceChip>(find.byKey(const Key('ai-time-45'))).selected,
      isTrue,
    );
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(const Key('ai-equipment-dumbbells')))
          .selected,
      isTrue,
    );

    await generateWorkout(tester);

    expect(find.text('Build Muscle Workout'), findsOneWidget);
    expect(find.text('Goal'), findsOneWidget);
    expect(find.text('Level'), findsOneWidget);
    expect(find.text('Time'), findsOneWidget);
    expect(find.text('Equipment'), findsOneWidget);
    expect(find.text('Build Muscle'), findsOneWidget);
    expect(find.text('Intermediate'), findsOneWidget);
    expect(find.text('45 minutes'), findsOneWidget);
    expect(find.text('Dumbbells'), findsOneWidget);
    expect(find.text('Sets'), findsWidgets);
    expect(find.text('Reps'), findsWidgets);
    expect(find.text('Rest time'), findsWidgets);
    expect(find.text('Duration'), findsWidgets);
    expect(find.text('Dumbbell Goblet Squat'), findsOneWidget);
    expectMetric('db-goblet-squat', '4');
    expectMetric('db-goblet-squat', '12');
    expectMetric('db-goblet-squat', '1 min');
    expectMetric('db-goblet-squat', '8 min');

    await tester.scrollUntilVisible(
      exerciseCard('db-hammer-curl'),
      400,
      scrollable: scrollableOf(const Key('ai-workout-result')),
    );
    expect(find.text('Hammer Curl'), findsOneWidget);
    expectMetric('db-hammer-curl', '45s');
    expectMetric('db-rdl', '1 min 15s');
    expect(find.byKey(const Key('start-generated-workout')), findsOneWidget);

    await tester.tap(find.byKey(const Key('start-generated-workout')));
    await tester.pumpAndSettle();
    expect(find.text('Exercise 1 of 6'), findsOneWidget);
    expect(find.text('Dumbbell Goblet Squat'), findsOneWidget);
    expect(find.text('Set 1 of 4'), findsOneWidget);
    expect(find.text('Complete set'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Build Muscle Workout'),
      -400,
      scrollable: scrollableOf(const Key('ai-workout-result')),
    );
    expect(find.text('Build Muscle Workout'), findsOneWidget);

    await tester.tap(find.byKey(const Key('ai-change-selections')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('ai-goal-loseWeight')));
    await tester.tap(find.byKey(const Key('ai-goal-loseWeight')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('ai-level-beginner')));
    await tester.tap(find.byKey(const Key('ai-level-beginner')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('ai-time-15')));
    await tester.tap(find.byKey(const Key('ai-time-15')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('ai-equipment-none')));
    await tester.tap(find.byKey(const Key('ai-equipment-none')));
    await tester.pumpAndSettle();

    await generateWorkout(tester);
    expect(find.text('Lose Weight Workout'), findsOneWidget);
    expect(find.text('15 minutes'), findsOneWidget);
    expect(find.text('No Equipment'), findsOneWidget);
    expect(find.text('Jump Squats'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Mountain Climbers'),
      400,
      scrollable: scrollableOf(const Key('ai-workout-result')),
    );
    expect(find.text('Push-Ups'), findsOneWidget);
    expect(find.text('Mountain Climbers'), findsOneWidget);
    expect(find.text('Dumbbell Goblet Squat'), findsNothing);
    expectMetric('bw-jump-squat', '3');
    expectMetric('bw-jump-squat', '14');
    expectMetric('bw-jump-squat', '45s');
    expectMetric('bw-jump-squat', '5 min');
  });

  testWidgets('a custom generator can replace the local mock', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: AiWorkoutScreen(generator: _ScriptedGenerator())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('generate-workout-button')));
    await tester.pump();
    expect(find.text(aiWorkoutLoadingMessage), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Scripted Press'), findsOneWidget);
    expect(find.text('Dumbbell Goblet Squat'), findsNothing);
    expectMetric('scripted-press', '3');
    expectMetric('scripted-press', '8');
    expectMetric('scripted-press', '45s');
    expectMetric('scripted-press', '20 min');
  });

  testWidgets('ai workout avoids overflow on a small phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: AiWorkoutScreen(
          generator: MockAiWorkoutGenerator(delay: Duration(milliseconds: 40)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('ai-equipment-gym')),
      300,
      scrollable: scrollableOf(const Key('ai-workout-form')),
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('generate-workout-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      exerciseCard('db-hammer-curl'),
      400,
      scrollable: scrollableOf(const Key('ai-workout-result')),
    );
    expect(find.text('Hammer Curl'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _ScriptedGenerator implements AiWorkoutGenerator {
  const _ScriptedGenerator();

  @override
  Future<GeneratedWorkout> generate(AiWorkoutPreferences preferences) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    const exercise = Exercise(
      id: 'scripted-press',
      name: 'Scripted Press',
      sets: 3,
      repetitions: 8,
      restSeconds: 45,
      icon: Icons.fitness_center,
    );
    return const GeneratedWorkout(
      workout: Workout(
        id: 'scripted',
        name: 'Scripted Workout',
        category: WorkoutCategory.strength,
        durationMinutes: 20,
        calories: 160,
        difficulty: WorkoutDifficulty.beginner,
        exercises: [exercise],
      ),
      exercises: [GeneratedExercise(exercise: exercise, durationMinutes: 20)],
    );
  }
}

import 'package:fitflow/features/ai_workout/ai_workout_generator.dart';
import 'package:fitflow/features/ai_workout/ai_workout_models.dart';
import 'package:fitflow/features/workout/workout_models.dart';
import 'package:flutter/material.dart';

/// Local stand-in for a future AI workout API.
class MockAiWorkoutGenerator implements AiWorkoutGenerator {
  const MockAiWorkoutGenerator({
    this.delay = const Duration(milliseconds: 1400),
  });

  final Duration delay;

  @override
  Future<GeneratedWorkout> generate(AiWorkoutPreferences preferences) async {
    await Future<void>.delayed(delay);
    return AiWorkoutMockData.build(preferences);
  }
}

abstract final class AiWorkoutMockData {
  static GeneratedWorkout build(AiWorkoutPreferences preferences) {
    final seeds = _select(
      preferences,
      _exerciseCount(preferences.durationMinutes),
    );
    final durations = _distributeMinutes(preferences.durationMinutes, [
      for (final seed in seeds) seed.weight,
    ]);
    final generated = <GeneratedExercise>[
      for (var index = 0; index < seeds.length; index++)
        _toExercise(seeds[index], preferences.level, durations[index]),
    ];

    return GeneratedWorkout(
      workout: Workout(
        id: 'ai-${preferences.goal.name}-${preferences.level.name}-${preferences.durationMinutes}-${preferences.equipment.name}',
        name: '${preferences.goal.label} Workout',
        category: _category(preferences.goal),
        durationMinutes: preferences.durationMinutes,
        calories: _calories(preferences),
        difficulty: preferences.level.difficulty,
        exercises: [for (final item in generated) item.exercise],
      ),
      exercises: generated,
    );
  }
}

GeneratedExercise _toExercise(
  _Seed seed,
  FitnessLevel level,
  int durationMinutes,
) {
  final volume = _scale(seed, level);
  return GeneratedExercise(
    exercise: Exercise(
      id: seed.id,
      name: seed.name,
      sets: volume.sets,
      repetitions: volume.reps,
      restSeconds: volume.restSeconds,
      icon: seed.icon,
    ),
    durationMinutes: durationMinutes,
  );
}

typedef _Volume = ({int sets, int reps, int restSeconds});

_Volume _scale(_Seed seed, FitnessLevel level) {
  return switch (level) {
    FitnessLevel.beginner => (
      sets: seed.sets > 2 ? seed.sets - 1 : seed.sets,
      reps: seed.reps + 2,
      restSeconds: seed.restSeconds + 15,
    ),
    FitnessLevel.intermediate => (
      sets: seed.sets,
      reps: seed.reps,
      restSeconds: seed.restSeconds,
    ),
    FitnessLevel.advanced => (
      sets: seed.sets + 1,
      reps: seed.reps > 6 ? seed.reps - 2 : seed.reps,
      restSeconds: seed.restSeconds > 30
          ? seed.restSeconds - 15
          : seed.restSeconds,
    ),
  };
}

int _exerciseCount(int minutes) {
  final desired = switch (minutes) {
    <= 20 => 3,
    <= 35 => 4,
    _ => 6,
  };
  if (minutes < 1) return 1;
  return desired > minutes ? minutes : desired;
}

List<int> _distributeMinutes(int total, List<int> weights) {
  if (weights.isEmpty || total <= 0) return const [];
  final count = weights.length;
  if (total < count) {
    return [for (var index = 0; index < count; index++) index < total ? 1 : 0];
  }

  final safeWeights = [for (final weight in weights) weight <= 0 ? 1 : weight];
  final weightSum = safeWeights.fold<int>(0, (sum, weight) => sum + weight);
  if (weightSum == total) return safeWeights;

  final shares = List<int>.filled(count, 0);
  var assigned = 0;
  for (var index = 0; index < count; index++) {
    final slotsAfter = count - index - 1;
    if (slotsAfter == 0) {
      shares[index] = total - assigned;
      break;
    }
    final raw = (total * safeWeights[index] / weightSum).round();
    final maxAllowed = total - assigned - slotsAfter;
    final share = raw.clamp(1, maxAllowed);
    shares[index] = share;
    assigned += share;
  }
  return shares;
}

List<_Seed> _select(AiWorkoutPreferences preferences, int count) {
  final pool = [
    for (final seed in _seeds)
      if (seed.equipment == preferences.equipment) seed,
  ];
  final preferred = [
    for (final seed in pool)
      if (seed.goals.contains(preferences.goal)) seed,
  ];
  final fillers = [
    for (final seed in pool)
      if (!preferred.contains(seed)) seed,
  ];
  final ordered = [...preferred, ...fillers];
  if (ordered.isEmpty) {
    throw StateError('No exercises for ${preferences.equipment.name}');
  }
  if (ordered.length >= count) return ordered.take(count).toList();
  return ordered;
}

WorkoutCategory _category(FitnessGoal goal) {
  return switch (goal) {
    FitnessGoal.buildMuscle => WorkoutCategory.strength,
    FitnessGoal.loseWeight => WorkoutCategory.hiit,
    FitnessGoal.endurance => WorkoutCategory.cardio,
    FitnessGoal.flexibility => WorkoutCategory.flexibility,
    FitnessGoal.generalFitness => WorkoutCategory.fullBody,
  };
}

int _calories(AiWorkoutPreferences preferences) {
  final perMinute = switch (preferences.goal) {
    FitnessGoal.buildMuscle => 8,
    FitnessGoal.loseWeight => 10,
    FitnessGoal.endurance => 9,
    FitnessGoal.flexibility => 4,
    FitnessGoal.generalFitness => 7,
  };
  final levelBoost = switch (preferences.level) {
    FitnessLevel.beginner => 0,
    FitnessLevel.intermediate => 1,
    FitnessLevel.advanced => 2,
  };
  return (perMinute + levelBoost) * preferences.durationMinutes;
}

class _Seed {
  const _Seed({
    required this.id,
    required this.name,
    required this.equipment,
    required this.goals,
    required this.icon,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.weight,
  });

  final String id;
  final String name;
  final WorkoutEquipment equipment;
  final Set<FitnessGoal> goals;
  final IconData icon;
  final int sets;
  final int reps;
  final int restSeconds;
  final int weight;
}

const _seeds = <_Seed>[
  _Seed(
    id: 'db-goblet-squat',
    name: 'Dumbbell Goblet Squat',
    equipment: WorkoutEquipment.dumbbells,
    goals: {FitnessGoal.buildMuscle, FitnessGoal.generalFitness},
    icon: Icons.accessibility_new,
    sets: 4,
    reps: 12,
    restSeconds: 60,
    weight: 8,
  ),
  _Seed(
    id: 'db-bench-press',
    name: 'Dumbbell Bench Press',
    equipment: WorkoutEquipment.dumbbells,
    goals: {FitnessGoal.buildMuscle},
    icon: Icons.fitness_center,
    sets: 4,
    reps: 10,
    restSeconds: 75,
    weight: 8,
  ),
  _Seed(
    id: 'db-row',
    name: 'Dumbbell Row',
    equipment: WorkoutEquipment.dumbbells,
    goals: {FitnessGoal.buildMuscle, FitnessGoal.generalFitness},
    icon: Icons.swap_vert,
    sets: 4,
    reps: 10,
    restSeconds: 60,
    weight: 8,
  ),
  _Seed(
    id: 'db-shoulder-press',
    name: 'Dumbbell Shoulder Press',
    equipment: WorkoutEquipment.dumbbells,
    goals: {FitnessGoal.buildMuscle},
    icon: Icons.arrow_upward,
    sets: 3,
    reps: 10,
    restSeconds: 60,
    weight: 7,
  ),
  _Seed(
    id: 'db-rdl',
    name: 'Dumbbell Romanian Deadlift',
    equipment: WorkoutEquipment.dumbbells,
    goals: {FitnessGoal.buildMuscle},
    icon: Icons.fitness_center,
    sets: 3,
    reps: 10,
    restSeconds: 75,
    weight: 7,
  ),
  _Seed(
    id: 'db-hammer-curl',
    name: 'Hammer Curl',
    equipment: WorkoutEquipment.dumbbells,
    goals: {FitnessGoal.buildMuscle},
    icon: Icons.fitness_center,
    sets: 3,
    reps: 12,
    restSeconds: 45,
    weight: 7,
  ),
  _Seed(
    id: 'db-thruster',
    name: 'Dumbbell Thruster',
    equipment: WorkoutEquipment.dumbbells,
    goals: {
      FitnessGoal.loseWeight,
      FitnessGoal.endurance,
      FitnessGoal.generalFitness,
    },
    icon: Icons.bolt,
    sets: 3,
    reps: 12,
    restSeconds: 40,
    weight: 7,
  ),
  _Seed(
    id: 'db-lunge',
    name: 'Dumbbell Reverse Lunge',
    equipment: WorkoutEquipment.dumbbells,
    goals: {FitnessGoal.loseWeight, FitnessGoal.generalFitness},
    icon: Icons.directions_walk,
    sets: 3,
    reps: 10,
    restSeconds: 40,
    weight: 6,
  ),
  _Seed(
    id: 'db-swing',
    name: 'Dumbbell Swing',
    equipment: WorkoutEquipment.dumbbells,
    goals: {FitnessGoal.loseWeight, FitnessGoal.endurance},
    icon: Icons.fitness_center,
    sets: 3,
    reps: 15,
    restSeconds: 30,
    weight: 6,
  ),
  _Seed(
    id: 'db-halo',
    name: 'Dumbbell Halo',
    equipment: WorkoutEquipment.dumbbells,
    goals: {FitnessGoal.flexibility, FitnessGoal.generalFitness},
    icon: Icons.autorenew,
    sets: 2,
    reps: 8,
    restSeconds: 20,
    weight: 5,
  ),
  _Seed(
    id: 'db-pullover',
    name: 'Dumbbell Pullover',
    equipment: WorkoutEquipment.dumbbells,
    goals: {FitnessGoal.flexibility},
    icon: Icons.open_in_full,
    sets: 3,
    reps: 10,
    restSeconds: 30,
    weight: 5,
  ),
  _Seed(
    id: 'db-farmer',
    name: 'Farmer Carry',
    equipment: WorkoutEquipment.dumbbells,
    goals: {FitnessGoal.endurance, FitnessGoal.generalFitness},
    icon: Icons.directions_walk,
    sets: 3,
    reps: 12,
    restSeconds: 40,
    weight: 6,
  ),
  _Seed(
    id: 'bw-jump-squat',
    name: 'Jump Squats',
    equipment: WorkoutEquipment.none,
    goals: {FitnessGoal.loseWeight, FitnessGoal.endurance},
    icon: Icons.directions_run,
    sets: 4,
    reps: 12,
    restSeconds: 30,
    weight: 5,
  ),
  _Seed(
    id: 'bw-push-up',
    name: 'Push-Ups',
    equipment: WorkoutEquipment.none,
    goals: {
      FitnessGoal.loseWeight,
      FitnessGoal.buildMuscle,
      FitnessGoal.generalFitness,
    },
    icon: Icons.fitness_center,
    sets: 3,
    reps: 12,
    restSeconds: 45,
    weight: 5,
  ),
  _Seed(
    id: 'bw-mountain',
    name: 'Mountain Climbers',
    equipment: WorkoutEquipment.none,
    goals: {FitnessGoal.loseWeight, FitnessGoal.endurance},
    icon: Icons.terrain,
    sets: 4,
    reps: 16,
    restSeconds: 25,
    weight: 5,
  ),
  _Seed(
    id: 'bw-burpee',
    name: 'Burpees',
    equipment: WorkoutEquipment.none,
    goals: {FitnessGoal.loseWeight, FitnessGoal.generalFitness},
    icon: Icons.bolt,
    sets: 3,
    reps: 10,
    restSeconds: 30,
    weight: 6,
  ),
  _Seed(
    id: 'bw-high-knees',
    name: 'High Knees',
    equipment: WorkoutEquipment.none,
    goals: {FitnessGoal.endurance, FitnessGoal.loseWeight},
    icon: Icons.directions_run,
    sets: 4,
    reps: 20,
    restSeconds: 20,
    weight: 5,
  ),
  _Seed(
    id: 'bw-glute',
    name: 'Glute Bridges',
    equipment: WorkoutEquipment.none,
    goals: {
      FitnessGoal.buildMuscle,
      FitnessGoal.flexibility,
      FitnessGoal.generalFitness,
    },
    icon: Icons.airline_seat_recline_normal,
    sets: 3,
    reps: 15,
    restSeconds: 30,
    weight: 6,
  ),
  _Seed(
    id: 'bw-squat',
    name: 'Bodyweight Squats',
    equipment: WorkoutEquipment.none,
    goals: {FitnessGoal.buildMuscle, FitnessGoal.generalFitness},
    icon: Icons.accessibility_new,
    sets: 4,
    reps: 12,
    restSeconds: 45,
    weight: 7,
  ),
  _Seed(
    id: 'bw-lunge',
    name: 'Reverse Lunges',
    equipment: WorkoutEquipment.none,
    goals: {FitnessGoal.buildMuscle, FitnessGoal.generalFitness},
    icon: Icons.directions_walk,
    sets: 3,
    reps: 10,
    restSeconds: 45,
    weight: 6,
  ),
  _Seed(
    id: 'bw-pike',
    name: 'Pike Push-Ups',
    equipment: WorkoutEquipment.none,
    goals: {FitnessGoal.buildMuscle},
    icon: Icons.arrow_upward,
    sets: 3,
    reps: 8,
    restSeconds: 45,
    weight: 6,
  ),
  _Seed(
    id: 'bw-plank',
    name: 'Plank Shoulder Taps',
    equipment: WorkoutEquipment.none,
    goals: {FitnessGoal.buildMuscle, FitnessGoal.generalFitness},
    icon: Icons.back_hand_outlined,
    sets: 3,
    reps: 12,
    restSeconds: 30,
    weight: 5,
  ),
  _Seed(
    id: 'bw-cat-cow',
    name: 'Cat-Cow',
    equipment: WorkoutEquipment.none,
    goals: {FitnessGoal.flexibility},
    icon: Icons.pets,
    sets: 2,
    reps: 10,
    restSeconds: 15,
    weight: 5,
  ),
  _Seed(
    id: 'bw-stretch',
    name: "World's Greatest Stretch",
    equipment: WorkoutEquipment.none,
    goals: {FitnessGoal.flexibility},
    icon: Icons.accessibility_new,
    sets: 2,
    reps: 6,
    restSeconds: 20,
    weight: 6,
  ),
  _Seed(
    id: 'band-squat',
    name: 'Banded Squat',
    equipment: WorkoutEquipment.bands,
    goals: {FitnessGoal.buildMuscle, FitnessGoal.generalFitness},
    icon: Icons.accessibility_new,
    sets: 4,
    reps: 12,
    restSeconds: 45,
    weight: 7,
  ),
  _Seed(
    id: 'band-row',
    name: 'Banded Row',
    equipment: WorkoutEquipment.bands,
    goals: {FitnessGoal.buildMuscle},
    icon: Icons.swap_vert,
    sets: 4,
    reps: 10,
    restSeconds: 60,
    weight: 7,
  ),
  _Seed(
    id: 'band-press',
    name: 'Banded Chest Press',
    equipment: WorkoutEquipment.bands,
    goals: {FitnessGoal.buildMuscle},
    icon: Icons.fitness_center,
    sets: 3,
    reps: 12,
    restSeconds: 45,
    weight: 6,
  ),
  _Seed(
    id: 'band-good-morning',
    name: 'Banded Good Morning',
    equipment: WorkoutEquipment.bands,
    goals: {FitnessGoal.buildMuscle, FitnessGoal.flexibility},
    icon: Icons.accessibility_new,
    sets: 3,
    reps: 10,
    restSeconds: 45,
    weight: 6,
  ),
  _Seed(
    id: 'band-curl',
    name: 'Banded Curl',
    equipment: WorkoutEquipment.bands,
    goals: {FitnessGoal.buildMuscle},
    icon: Icons.fitness_center,
    sets: 3,
    reps: 12,
    restSeconds: 30,
    weight: 5,
  ),
  _Seed(
    id: 'band-pull-apart',
    name: 'Band Pull-Apart',
    equipment: WorkoutEquipment.bands,
    goals: {FitnessGoal.buildMuscle, FitnessGoal.flexibility},
    icon: Icons.open_in_full,
    sets: 3,
    reps: 15,
    restSeconds: 30,
    weight: 5,
  ),
  _Seed(
    id: 'band-punch',
    name: 'Banded Punches',
    equipment: WorkoutEquipment.bands,
    goals: {FitnessGoal.loseWeight, FitnessGoal.endurance},
    icon: Icons.bolt,
    sets: 3,
    reps: 20,
    restSeconds: 25,
    weight: 6,
  ),
  _Seed(
    id: 'band-jump-squat',
    name: 'Banded Jump Squat',
    equipment: WorkoutEquipment.bands,
    goals: {FitnessGoal.loseWeight, FitnessGoal.endurance},
    icon: Icons.directions_run,
    sets: 3,
    reps: 12,
    restSeconds: 30,
    weight: 6,
  ),
  _Seed(
    id: 'band-pull-down',
    name: 'Banded Pull-Down',
    equipment: WorkoutEquipment.bands,
    goals: {FitnessGoal.endurance, FitnessGoal.generalFitness},
    icon: Icons.south,
    sets: 3,
    reps: 12,
    restSeconds: 30,
    weight: 6,
  ),
  _Seed(
    id: 'band-dislocate',
    name: 'Band Dislocates',
    equipment: WorkoutEquipment.bands,
    goals: {FitnessGoal.flexibility},
    icon: Icons.autorenew,
    sets: 2,
    reps: 8,
    restSeconds: 15,
    weight: 5,
  ),
  _Seed(
    id: 'bb-squat',
    name: 'Back Squat',
    equipment: WorkoutEquipment.barbell,
    goals: {FitnessGoal.buildMuscle},
    icon: Icons.accessibility_new,
    sets: 4,
    reps: 8,
    restSeconds: 90,
    weight: 8,
  ),
  _Seed(
    id: 'bb-bench',
    name: 'Bench Press',
    equipment: WorkoutEquipment.barbell,
    goals: {FitnessGoal.buildMuscle},
    icon: Icons.fitness_center,
    sets: 4,
    reps: 8,
    restSeconds: 90,
    weight: 8,
  ),
  _Seed(
    id: 'bb-deadlift',
    name: 'Deadlift',
    equipment: WorkoutEquipment.barbell,
    goals: {FitnessGoal.buildMuscle, FitnessGoal.generalFitness},
    icon: Icons.fitness_center,
    sets: 4,
    reps: 6,
    restSeconds: 90,
    weight: 8,
  ),
  _Seed(
    id: 'bb-row',
    name: 'Barbell Row',
    equipment: WorkoutEquipment.barbell,
    goals: {FitnessGoal.buildMuscle},
    icon: Icons.swap_vert,
    sets: 4,
    reps: 8,
    restSeconds: 75,
    weight: 7,
  ),
  _Seed(
    id: 'bb-press',
    name: 'Overhead Press',
    equipment: WorkoutEquipment.barbell,
    goals: {FitnessGoal.buildMuscle},
    icon: Icons.arrow_upward,
    sets: 3,
    reps: 8,
    restSeconds: 75,
    weight: 7,
  ),
  _Seed(
    id: 'bb-rdl',
    name: 'Barbell Romanian Deadlift',
    equipment: WorkoutEquipment.barbell,
    goals: {FitnessGoal.buildMuscle},
    icon: Icons.fitness_center,
    sets: 3,
    reps: 8,
    restSeconds: 75,
    weight: 7,
  ),
  _Seed(
    id: 'bb-hip-thrust',
    name: 'Hip Thrust',
    equipment: WorkoutEquipment.barbell,
    goals: {FitnessGoal.generalFitness},
    icon: Icons.airline_seat_recline_normal,
    sets: 3,
    reps: 10,
    restSeconds: 60,
    weight: 7,
  ),
  _Seed(
    id: 'bb-lunge',
    name: 'Barbell Lunge',
    equipment: WorkoutEquipment.barbell,
    goals: {FitnessGoal.loseWeight, FitnessGoal.generalFitness},
    icon: Icons.directions_walk,
    sets: 3,
    reps: 10,
    restSeconds: 60,
    weight: 6,
  ),
  _Seed(
    id: 'bb-thruster',
    name: 'Barbell Thruster',
    equipment: WorkoutEquipment.barbell,
    goals: {FitnessGoal.loseWeight, FitnessGoal.endurance},
    icon: Icons.bolt,
    sets: 3,
    reps: 8,
    restSeconds: 60,
    weight: 7,
  ),
  _Seed(
    id: 'bb-good-morning',
    name: 'Good Morning',
    equipment: WorkoutEquipment.barbell,
    goals: {FitnessGoal.flexibility, FitnessGoal.generalFitness},
    icon: Icons.accessibility_new,
    sets: 3,
    reps: 8,
    restSeconds: 45,
    weight: 6,
  ),
  _Seed(
    id: 'gym-leg-press',
    name: 'Leg Press',
    equipment: WorkoutEquipment.gym,
    goals: {FitnessGoal.buildMuscle, FitnessGoal.generalFitness},
    icon: Icons.airline_seat_recline_extra,
    sets: 4,
    reps: 10,
    restSeconds: 75,
    weight: 8,
  ),
  _Seed(
    id: 'gym-chest-press',
    name: 'Chest Press',
    equipment: WorkoutEquipment.gym,
    goals: {FitnessGoal.buildMuscle},
    icon: Icons.fitness_center,
    sets: 4,
    reps: 10,
    restSeconds: 75,
    weight: 8,
  ),
  _Seed(
    id: 'gym-lat-pulldown',
    name: 'Lat Pulldown',
    equipment: WorkoutEquipment.gym,
    goals: {FitnessGoal.buildMuscle},
    icon: Icons.south,
    sets: 4,
    reps: 10,
    restSeconds: 60,
    weight: 7,
  ),
  _Seed(
    id: 'gym-seated-row',
    name: 'Seated Row',
    equipment: WorkoutEquipment.gym,
    goals: {FitnessGoal.buildMuscle},
    icon: Icons.swap_vert,
    sets: 3,
    reps: 10,
    restSeconds: 60,
    weight: 7,
  ),
  _Seed(
    id: 'gym-shoulder',
    name: 'Shoulder Press Machine',
    equipment: WorkoutEquipment.gym,
    goals: {FitnessGoal.buildMuscle},
    icon: Icons.arrow_upward,
    sets: 3,
    reps: 10,
    restSeconds: 60,
    weight: 7,
  ),
  _Seed(
    id: 'gym-leg-curl',
    name: 'Leg Curl',
    equipment: WorkoutEquipment.gym,
    goals: {FitnessGoal.buildMuscle},
    icon: Icons.airline_seat_legroom_extra,
    sets: 3,
    reps: 12,
    restSeconds: 45,
    weight: 6,
  ),
  _Seed(
    id: 'gym-bike',
    name: 'Bike Intervals',
    equipment: WorkoutEquipment.gym,
    goals: {FitnessGoal.endurance, FitnessGoal.loseWeight},
    icon: Icons.pedal_bike,
    sets: 4,
    reps: 12,
    restSeconds: 30,
    weight: 7,
  ),
  _Seed(
    id: 'gym-rower',
    name: 'Rowing Intervals',
    equipment: WorkoutEquipment.gym,
    goals: {FitnessGoal.endurance, FitnessGoal.loseWeight},
    icon: Icons.rowing,
    sets: 4,
    reps: 12,
    restSeconds: 30,
    weight: 7,
  ),
  _Seed(
    id: 'gym-woodchop',
    name: 'Cable Woodchop',
    equipment: WorkoutEquipment.gym,
    goals: {FitnessGoal.generalFitness, FitnessGoal.loseWeight},
    icon: Icons.bolt,
    sets: 3,
    reps: 12,
    restSeconds: 30,
    weight: 6,
  ),
  _Seed(
    id: 'gym-stretch',
    name: 'Chest Opener Stretch',
    equipment: WorkoutEquipment.gym,
    goals: {FitnessGoal.flexibility},
    icon: Icons.self_improvement,
    sets: 2,
    reps: 8,
    restSeconds: 20,
    weight: 5,
  ),
];

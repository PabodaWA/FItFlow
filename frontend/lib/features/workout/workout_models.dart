import 'package:flutter/material.dart';

enum WorkoutCategory { strength, cardio, hiit, flexibility, fullBody }

enum WorkoutDifficulty { beginner, intermediate, advanced }

class WorkoutCategoryStyle {
  const WorkoutCategoryStyle({
    required this.label,
    required this.icon,
    required this.colors,
  });

  final String label;
  final IconData icon;
  final List<Color> colors;
}

extension WorkoutCategoryPresentation on WorkoutCategory {
  WorkoutCategoryStyle get style => switch (this) {
    WorkoutCategory.strength => const WorkoutCategoryStyle(
      label: 'Strength',
      icon: Icons.fitness_center,
      colors: [Color(0xFF3D4F7C), Color(0xFF243044)],
    ),
    WorkoutCategory.cardio => const WorkoutCategoryStyle(
      label: 'Cardio',
      icon: Icons.directions_run,
      colors: [Color(0xFFE25B2A), Color(0xFF9A3412)],
    ),
    WorkoutCategory.hiit => const WorkoutCategoryStyle(
      label: 'HIIT',
      icon: Icons.bolt,
      colors: [Color(0xFFDB2777), Color(0xFF9D174D)],
    ),
    WorkoutCategory.flexibility => const WorkoutCategoryStyle(
      label: 'Flexibility',
      icon: Icons.self_improvement,
      colors: [Color(0xFF0F766E), Color(0xFF115E59)],
    ),
    WorkoutCategory.fullBody => const WorkoutCategoryStyle(
      label: 'Full Body',
      icon: Icons.accessibility_new,
      colors: [Color(0xFF1B7F4E), Color(0xFF124E32)],
    ),
  };
}

extension WorkoutDifficultyPresentation on WorkoutDifficulty {
  String get label => switch (this) {
    WorkoutDifficulty.beginner => 'Beginner',
    WorkoutDifficulty.intermediate => 'Intermediate',
    WorkoutDifficulty.advanced => 'Advanced',
  };

  Color get color => switch (this) {
    WorkoutDifficulty.beginner => const Color(0xFF1B7F4E),
    WorkoutDifficulty.intermediate => const Color(0xFFB86E00),
    WorkoutDifficulty.advanced => const Color(0xFFC2410C),
  };
}

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.repetitions,
    required this.restSeconds,
    required this.icon,
  });

  final String id;
  final String name;
  final int sets;
  final int repetitions;
  final int restSeconds;
  final IconData icon;

  String get restLabel => formatRestTime(restSeconds);

  String get summaryLabel => '$sets sets • $repetitions reps • $restLabel rest';
}

class Workout {
  const Workout({
    required this.id,
    required this.name,
    required this.category,
    required this.durationMinutes,
    required this.calories,
    required this.difficulty,
    required this.exercises,
  });

  final String id;
  final String name;
  final WorkoutCategory category;
  final int durationMinutes;
  final int calories;
  final WorkoutDifficulty difficulty;
  final List<Exercise> exercises;

  String get durationLabel => '$durationMinutes min';

  String get caloriesLabel => '$calories kcal';

  String get exerciseCountLabel =>
      exercises.length == 1 ? '1 exercise' : '${exercises.length} exercises';
}

String formatRestTime(int seconds) {
  if (seconds <= 0) return '0s';
  final minutes = seconds ~/ 60;
  final remainder = seconds % 60;
  if (minutes <= 0) return '${seconds}s';
  if (remainder == 0) return minutes == 1 ? '1 min' : '$minutes min';
  return '$minutes min ${remainder}s';
}

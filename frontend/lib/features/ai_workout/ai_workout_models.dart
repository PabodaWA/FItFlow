import 'package:fitflow/features/workout/workout_models.dart';

enum FitnessGoal {
  buildMuscle,
  loseWeight,
  endurance,
  flexibility,
  generalFitness,
}

enum FitnessLevel { beginner, intermediate, advanced }

enum WorkoutEquipment { none, dumbbells, bands, barbell, gym }

const availableWorkoutTimes = <int>[15, 30, 45, 60];

extension FitnessGoalPresentation on FitnessGoal {
  String get label => switch (this) {
    FitnessGoal.buildMuscle => 'Build Muscle',
    FitnessGoal.loseWeight => 'Lose Weight',
    FitnessGoal.endurance => 'Endurance',
    FitnessGoal.flexibility => 'Flexibility',
    FitnessGoal.generalFitness => 'General Fitness',
  };
}

extension FitnessLevelPresentation on FitnessLevel {
  String get label => switch (this) {
    FitnessLevel.beginner => 'Beginner',
    FitnessLevel.intermediate => 'Intermediate',
    FitnessLevel.advanced => 'Advanced',
  };

  WorkoutDifficulty get difficulty => switch (this) {
    FitnessLevel.beginner => WorkoutDifficulty.beginner,
    FitnessLevel.intermediate => WorkoutDifficulty.intermediate,
    FitnessLevel.advanced => WorkoutDifficulty.advanced,
  };
}

extension WorkoutEquipmentPresentation on WorkoutEquipment {
  String get label => switch (this) {
    WorkoutEquipment.none => 'No Equipment',
    WorkoutEquipment.dumbbells => 'Dumbbells',
    WorkoutEquipment.bands => 'Resistance Bands',
    WorkoutEquipment.barbell => 'Barbell',
    WorkoutEquipment.gym => 'Full Gym',
  };
}

/// Inputs collected before a workout is created.
///
/// A future AI backend can accept this same payload.
class AiWorkoutPreferences {
  const AiWorkoutPreferences({
    required this.goal,
    required this.level,
    required this.durationMinutes,
    required this.equipment,
  });

  final FitnessGoal goal;
  final FitnessLevel level;
  final int durationMinutes;
  final WorkoutEquipment equipment;

  static const initial = AiWorkoutPreferences(
    goal: FitnessGoal.buildMuscle,
    level: FitnessLevel.intermediate,
    durationMinutes: 45,
    equipment: WorkoutEquipment.dumbbells,
  );

  String get timeLabel => '$durationMinutes minutes';
}

class GeneratedExercise {
  const GeneratedExercise({
    required this.exercise,
    required this.durationMinutes,
  });

  final Exercise exercise;
  final int durationMinutes;

  String get durationLabel => '$durationMinutes min';
}

class GeneratedWorkout {
  const GeneratedWorkout({required this.workout, required this.exercises});

  final Workout workout;
  final List<GeneratedExercise> exercises;
}

import 'package:fitflow/features/ai_workout/ai_workout_models.dart';

/// Creates a workout from [AiWorkoutPreferences].
///
/// The workout screen depends only on this contract. A network-backed
/// implementation can replace the local mock when an AI API is ready.
abstract interface class AiWorkoutGenerator {
  Future<GeneratedWorkout> generate(AiWorkoutPreferences preferences);
}

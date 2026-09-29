import 'package:fitflow/features/progress/progress_models.dart';

/// Local week shown until a progress backend is connected.
abstract final class ProgressMockData {
  static const week = ProgressSnapshot(
    workoutTarget: 5,
    calorieTarget: 3000,
    durationTargetMinutes: 240,
    startWeightKg: 76,
    targetWeightKg: 80,
    streakDays: 12,
    bestStreakDays: 21,
    streakTargetDays: 30,
    days: [
      DayActivity(
        label: 'Mon',
        workouts: 1,
        calories: 320,
        durationMinutes: 27,
      ),
      DayActivity(
        label: 'Tue',
        workouts: 1,
        calories: 410,
        durationMinutes: 43,
      ),
      DayActivity(
        label: 'Wed',
        workouts: 1,
        calories: 280,
        durationMinutes: 23,
      ),
      DayActivity(
        label: 'Thu',
        workouts: 2,
        calories: 540,
        durationMinutes: 57,
      ),
      DayActivity(
        label: 'Fri',
        workouts: 1,
        calories: 390,
        durationMinutes: 36,
      ),
      DayActivity(
        label: 'Sat',
        workouts: 1,
        calories: 180,
        durationMinutes: 13,
      ),
      DayActivity(
        label: 'Sun',
        workouts: 1,
        calories: 400,
        durationMinutes: 42,
      ),
    ],
    weights: [
      WeightEntry(label: 'W1', kilograms: 76),
      WeightEntry(label: 'W2', kilograms: 76.4),
      WeightEntry(label: 'W3', kilograms: 76.8),
      WeightEntry(label: 'W4', kilograms: 77.1),
      WeightEntry(label: 'W5', kilograms: 77.4),
      WeightEntry(label: 'W6', kilograms: 77.8),
      WeightEntry(label: 'W7', kilograms: 78.1),
      WeightEntry(label: 'W8', kilograms: 78.4),
    ],
  );
}

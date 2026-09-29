import 'package:fitflow/features/profile/profile_models.dart';

const poundsPerKilogram = 2.2046226218;

class DayActivity {
  const DayActivity({
    required this.label,
    required this.workouts,
    required this.calories,
    required this.durationMinutes,
  });

  final String label;
  final int workouts;
  final int calories;
  final int durationMinutes;
}

class WeightEntry {
  const WeightEntry({required this.label, required this.kilograms});

  final String label;
  final double kilograms;
}

class ProgressSnapshot {
  const ProgressSnapshot({
    required this.days,
    required this.weights,
    required this.workoutTarget,
    required this.calorieTarget,
    required this.durationTargetMinutes,
    required this.startWeightKg,
    required this.targetWeightKg,
    required this.streakDays,
    required this.bestStreakDays,
    required this.streakTargetDays,
  });

  final List<DayActivity> days;
  final List<WeightEntry> weights;
  final int workoutTarget;
  final int calorieTarget;
  final int durationTargetMinutes;
  final double startWeightKg;
  final double targetWeightKg;
  final int streakDays;
  final int bestStreakDays;
  final int streakTargetDays;

  int get weeklyWorkouts => days.fold(0, (sum, day) => sum + day.workouts);

  int get caloriesBurned => days.fold(0, (sum, day) => sum + day.calories);

  int get durationMinutes =>
      days.fold(0, (sum, day) => sum + day.durationMinutes);

  double get currentWeightKg =>
      weights.isEmpty ? startWeightKg : weights.last.kilograms;

  double get workoutProgress => ratioProgress(weeklyWorkouts, workoutTarget);

  double get calorieProgress => ratioProgress(caloriesBurned, calorieTarget);

  double get durationProgress =>
      ratioProgress(durationMinutes, durationTargetMinutes);

  double get weightProgressValue =>
      weightProgress(startWeightKg, currentWeightKg, targetWeightKg);

  double get streakProgress => ratioProgress(streakDays, streakTargetDays);

  int peak(int Function(DayActivity day) read) {
    var maxValue = 0;
    for (final day in days) {
      final value = read(day);
      if (value > maxValue) maxValue = value;
    }
    return maxValue;
  }
}

double chartFraction(num value, num maxValue) {
  if (maxValue <= 0) return 0;
  return (value / maxValue).clamp(0, 1).toDouble();
}

double visualBarFraction(num value, num maxValue) {
  final fraction = chartFraction(value, maxValue);
  if (fraction == 0) return 0;
  return fraction < 0.08 ? 0.08 : fraction;
}

double weightProgress(double start, double current, double target) {
  final span = target - start;
  if (span == 0) return current == target ? 1 : 0;
  return ((current - start) / span).clamp(0, 1).toDouble();
}

double kilogramsToPounds(double kilograms) => kilograms * poundsPerKilogram;

String formatBodyWeight(double kilograms, {required bool useMetric}) {
  if (useMetric) return '${kilograms.toStringAsFixed(1)} kg';
  return '${kilogramsToPounds(kilograms).toStringAsFixed(1)} lb';
}

String weightSummaryLabel({
  required double startKg,
  required double currentKg,
  required double targetKg,
  required bool useMetric,
}) {
  final start = formatBodyWeight(startKg, useMetric: useMetric);
  final current = formatBodyWeight(currentKg, useMetric: useMetric);
  final target = formatBodyWeight(targetKg, useMetric: useMetric);
  return '$start start · $current now · $target goal';
}

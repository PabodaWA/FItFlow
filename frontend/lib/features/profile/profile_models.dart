import 'package:fitflow/features/ai_workout/ai_workout_models.dart';
import 'package:flutter/material.dart';

const maxProfileNameLength = 40;

class MemberProfile {
  const MemberProfile({
    required this.name,
    required this.initials,
    required this.avatarColor,
    required this.goal,
    required this.streakDays,
    required this.workoutsCompleted,
    required this.caloriesBurned,
  });

  final String name;
  final String initials;
  final Color avatarColor;
  final FitnessGoal goal;
  final int streakDays;
  final int workoutsCompleted;
  final int caloriesBurned;

  MemberProfile copyWith({
    String? name,
    String? initials,
    Color? avatarColor,
    FitnessGoal? goal,
    int? streakDays,
    int? workoutsCompleted,
    int? caloriesBurned,
  }) {
    return MemberProfile(
      name: name ?? this.name,
      initials: initials ?? this.initials,
      avatarColor: avatarColor ?? this.avatarColor,
      goal: goal ?? this.goal,
      streakDays: streakDays ?? this.streakDays,
      workoutsCompleted: workoutsCompleted ?? this.workoutsCompleted,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    );
  }
}

class TrainingGoal {
  const TrainingGoal({
    required this.id,
    required this.title,
    required this.detail,
    required this.current,
    required this.target,
    required this.unit,
    required this.icon,
    required this.color,
    this.kind,
  });

  final String id;
  final String title;
  final String detail;
  final int current;
  final int target;
  final String unit;
  final IconData icon;
  final Color color;
  final FitnessGoal? kind;

  double get progress => ratioProgress(current, target);
}

class AchievementBadge {
  const AchievementBadge({
    required this.id,
    required this.title,
    required this.detail,
    required this.earned,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String detail;
  final bool earned;
  final IconData icon;
  final Color color;
}

class ProfileSettings {
  const ProfileSettings({
    this.workoutReminders = true,
    this.weeklySummary = true,
    this.useMetricUnits = true,
  });

  final bool workoutReminders;
  final bool weeklySummary;
  final bool useMetricUnits;

  ProfileSettings copyWith({
    bool? workoutReminders,
    bool? weeklySummary,
    bool? useMetricUnits,
  }) {
    return ProfileSettings(
      workoutReminders: workoutReminders ?? this.workoutReminders,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      useMetricUnits: useMetricUnits ?? this.useMetricUnits,
    );
  }
}

String initialsFor(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  final first = parts.first.substring(0, 1);
  final last = parts.last.substring(0, 1);
  return '$first$last'.toUpperCase();
}

String? validateProfileName(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) return 'Enter your name.';
  if (name.length < 2) return 'Use at least 2 characters.';
  if (name.length > maxProfileNameLength) {
    return 'Use $maxProfileNameLength characters or fewer.';
  }
  return null;
}

String formatStatCount(int value) {
  final negative = value < 0;
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    final remaining = digits.length - index;
    if (index > 0 && remaining % 3 == 0) buffer.write(',');
    buffer.write(digits[index]);
  }
  final formatted = buffer.toString();
  return negative ? '-$formatted' : formatted;
}

double ratioProgress(int current, int target) {
  if (target <= 0) return 0;
  return (current / target).clamp(0, 1).toDouble();
}

int earnedAchievementCount(List<AchievementBadge> badges) {
  return badges.where((badge) => badge.earned).length;
}

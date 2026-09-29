import 'package:fitflow/features/ai_workout/ai_workout_models.dart';
import 'package:fitflow/features/profile/profile_models.dart';
import 'package:flutter/material.dart';

/// Local profile shown until an account backend is connected.
abstract final class ProfileMockData {
  static const jordan = MemberProfile(
    name: 'Jordan Hale',
    initials: 'JH',
    avatarColor: Color(0xFF1B7F4E),
    goal: FitnessGoal.buildMuscle,
    streakDays: 12,
    workoutsCompleted: 86,
    caloriesBurned: 24860,
  );

  static const settings = ProfileSettings();

  static const goals = <TrainingGoal>[
    TrainingGoal(
      id: 'build-muscle',
      title: 'Build Muscle',
      detail: 'Strength sessions this month',
      current: 18,
      target: 24,
      unit: 'sessions',
      icon: Icons.fitness_center,
      color: Color(0xFF1B7F4E),
      kind: FitnessGoal.buildMuscle,
    ),
    TrainingGoal(
      id: 'lose-weight',
      title: 'Lose Weight',
      detail: 'Kilograms toward your target weight',
      current: 2,
      target: 4,
      unit: 'kg',
      icon: Icons.monitor_weight_outlined,
      color: Color(0xFF2F6FED),
      kind: FitnessGoal.loseWeight,
    ),
    TrainingGoal(
      id: 'endurance',
      title: 'Endurance',
      detail: 'Cardio sessions this month',
      current: 6,
      target: 12,
      unit: 'sessions',
      icon: Icons.directions_run,
      color: Color(0xFF0F766E),
      kind: FitnessGoal.endurance,
    ),
    TrainingGoal(
      id: 'weekly-burn',
      title: 'Weekly calorie burn',
      detail: 'Calories burned from workouts this week',
      current: 2520,
      target: 3000,
      unit: 'kcal',
      icon: Icons.local_fire_department_outlined,
      color: Color(0xFFE25B2A),
    ),
    TrainingGoal(
      id: 'streak',
      title: '30-day streak',
      detail: 'Train on consecutive days',
      current: 12,
      target: 30,
      unit: 'days',
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFB86E00),
    ),
  ];

  static const achievements = <AchievementBadge>[
    AchievementBadge(
      id: 'first-workout',
      title: 'First Workout',
      detail: 'Finished your first FitFlow session.',
      earned: true,
      icon: Icons.flag_outlined,
      color: Color(0xFF1B7F4E),
    ),
    AchievementBadge(
      id: 'week-streak',
      title: '7-day Streak',
      detail: 'Trained seven days in a row.',
      earned: true,
      icon: Icons.local_fire_department_outlined,
      color: Color(0xFFE25B2A),
    ),
    AchievementBadge(
      id: 'fifty-workouts',
      title: '50 Workouts',
      detail: 'Logged fifty completed workouts.',
      earned: true,
      icon: Icons.fitness_center,
      color: Color(0xFF2F6FED),
    ),
    AchievementBadge(
      id: 'ten-thousand',
      title: '10,000 kcal',
      detail: 'Burned ten thousand workout calories.',
      earned: true,
      icon: Icons.bolt_outlined,
      color: Color(0xFFB86E00),
    ),
    AchievementBadge(
      id: 'thirty-day',
      title: '30-day Streak',
      detail: 'Keep the streak going to 30 days.',
      earned: false,
      icon: Icons.emoji_events_outlined,
      color: Color(0xFF7C3AED),
    ),
    AchievementBadge(
      id: 'century',
      title: '100 Workouts',
      detail: 'Fourteen sessions away from 100.',
      earned: false,
      icon: Icons.military_tech_outlined,
      color: Color(0xFF0F766E),
    ),
  ];
}

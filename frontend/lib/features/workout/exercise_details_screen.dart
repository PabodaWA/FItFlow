import 'package:fitflow/core/fade_page_route.dart';
import 'package:fitflow/features/workout/workout_models.dart';
import 'package:fitflow/features/workout/workout_widgets.dart';
import 'package:flutter/material.dart';

class ExerciseDetailsScreen extends StatelessWidget {
  const ExerciseDetailsScreen({
    super.key,
    required this.exercise,
    required this.workout,
  });

  final Exercise exercise;
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 240,
                backgroundColor: workout.category.style.colors.last,
                foregroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: WorkoutArtwork(
                    category: workout.category,
                    icon: exercise.icon,
                    badge: workout.category.style.label,
                    height: null,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      exercise.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      workout.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: WorkoutStat(
                            icon: Icons.repeat,
                            value: '${exercise.sets}',
                            label: 'Sets',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: WorkoutStat(
                            icon: Icons.fitness_center,
                            value: '${exercise.repetitions}',
                            label: 'Repetitions',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: WorkoutStat(
                            icon: Icons.timer_outlined,
                            value: exercise.restLabel,
                            label: 'Rest',
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void openExerciseDetails(
  BuildContext context, {
  required Exercise exercise,
  required Workout workout,
}) {
  Navigator.of(context).push(
    fadePageRoute<void>(
      builder: (context) =>
          ExerciseDetailsScreen(exercise: exercise, workout: workout),
    ),
  );
}

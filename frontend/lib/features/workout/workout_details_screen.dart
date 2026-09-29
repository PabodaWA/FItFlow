import 'package:fitflow/core/fade_page_route.dart';
import 'package:fitflow/features/workout/exercise_details_screen.dart';
import 'package:fitflow/features/workout/start_workout_screen.dart';
import 'package:fitflow/features/workout/workout_models.dart';
import 'package:fitflow/features/workout/workout_widgets.dart';
import 'package:flutter/material.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  const WorkoutDetailsScreen({super.key, required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canStart = workout.exercises.isNotEmpty;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: CustomScrollView(
            key: const Key('workout-details-scroll'),
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 232,
                backgroundColor: workout.category.style.colors.last,
                foregroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: WorkoutArtwork(
                    category: workout.category,
                    icon: workout.category.style.icon,
                    badge: workout.category.style.label,
                    height: null,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      workout.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: WorkoutStat(
                            icon: Icons.timer_outlined,
                            value: workout.durationLabel,
                            label: 'Duration',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: WorkoutStat(
                            icon: Icons.local_fire_department_rounded,
                            value: '${workout.calories}',
                            label: 'Calories',
                            color: const Color(0xFFE25B2A),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: WorkoutStat(
                            icon: Icons.speed,
                            value: workout.difficulty.label,
                            label: 'Difficulty',
                            color: workout.difficulty.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Exercises',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (workout.exercises.isEmpty)
                      Text(
                        'No exercises in this workout yet.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    else
                      for (
                        var index = 0;
                        index < workout.exercises.length;
                        index++
                      ) ...[
                        if (index > 0) const SizedBox(height: 10),
                        _ExerciseTile(
                          index: index,
                          exercise: workout.exercises[index],
                          workout: workout,
                        ),
                      ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: WorkoutBottomBar(
        child: FilledButton.icon(
          key: const Key('workout-details-start'),
          onPressed: canStart ? () => openStartWorkout(context, workout) : null,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Start Workout'),
        ),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({
    required this.index,
    required this.exercise,
    required this.workout,
  });

  final int index;
  final Exercise exercise;
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('exercise-tile-${workout.id}-${exercise.id}'),
          onTap: () => openExerciseDetails(
            context,
            exercise: exercise,
            workout: workout,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: WorkoutArtwork(
                      category: workout.category,
                      icon: exercise.icon,
                      height: 64,
                      compact: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exercise ${index + 1}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        exercise.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise.summaryLabel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void openWorkoutDetails(BuildContext context, Workout workout) {
  Navigator.of(context).push(
    fadePageRoute<void>(
      builder: (context) => WorkoutDetailsScreen(workout: workout),
    ),
  );
}

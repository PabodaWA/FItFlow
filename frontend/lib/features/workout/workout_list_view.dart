import 'package:fitflow/features/workout/workout_details_screen.dart';
import 'package:fitflow/features/workout/workout_mock_data.dart';
import 'package:fitflow/features/workout/workout_models.dart';
import 'package:fitflow/features/workout/workout_widgets.dart';
import 'package:flutter/material.dart';

class WorkoutListView extends StatefulWidget {
  const WorkoutListView({super.key});

  @override
  State<WorkoutListView> createState() => _WorkoutListViewState();
}

class _WorkoutListViewState extends State<WorkoutListView> {
  WorkoutCategory? _category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final workouts = WorkoutCatalog.byCategory(_category);
    final filters = <WorkoutCategory?>[null, ...WorkoutCategory.values];

    return ColoredBox(
      color: colorScheme.surfaceContainerLow,
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              key: const Key('workout-list'),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                Text(
                  'Workouts',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pick a session and start training.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var index = 0; index < filters.length; index++) ...[
                        if (index > 0) const SizedBox(width: 8),
                        _CategoryChip(
                          category: filters[index],
                          selected: _category == filters[index],
                          onSelected: () {
                            setState(() => _category = filters[index]);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  workouts.length == 1
                      ? '1 workout'
                      : '${workouts.length} workouts',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                if (workouts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Text(
                      'No workouts in this category yet.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  for (var index = 0; index < workouts.length; index++) ...[
                    if (index > 0) const SizedBox(height: 14),
                    _WorkoutListCard(workout: workouts[index]),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onSelected,
  });

  final WorkoutCategory? category;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = category?.style.label ?? 'All';

    return ChoiceChip(
      key: Key('workout-filter-${category?.name ?? 'all'}'),
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onSelected(),
      selectedColor: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      labelStyle: TextStyle(
        color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: selected ? colorScheme.primary : colorScheme.outlineVariant,
      ),
    );
  }
}

class _WorkoutListCard extends StatelessWidget {
  const _WorkoutListCard({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        key: Key('workout-card-${workout.id}'),
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openWorkoutDetails(context, workout),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WorkoutArtwork(
                category: workout.category,
                icon: workout.category.style.icon,
                badge: workout.category.style.label,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        WorkoutMeta(
                          icon: Icons.timer_outlined,
                          label: workout.durationLabel,
                        ),
                        DifficultyPill(difficulty: workout.difficulty),
                        WorkoutMeta(
                          icon: Icons.format_list_numbered,
                          label: workout.exerciseCountLabel,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

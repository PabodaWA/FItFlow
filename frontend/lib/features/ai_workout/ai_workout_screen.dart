import 'package:fitflow/core/fade_page_route.dart';
import 'package:fitflow/features/ai_workout/ai_workout_generator.dart';
import 'package:fitflow/features/ai_workout/ai_workout_mock_data.dart';
import 'package:fitflow/features/ai_workout/ai_workout_models.dart';
import 'package:fitflow/features/workout/start_workout_screen.dart';
import 'package:fitflow/features/workout/workout_widgets.dart';
import 'package:flutter/material.dart';

const aiWorkoutLoadingMessage = '✨ Creating your personalized workout...';

class AiWorkoutScreen extends StatefulWidget {
  const AiWorkoutScreen({super.key, this.generator});

  /// Defaults to local mock plans. Pass another [AiWorkoutGenerator]
  /// when a backend is available.
  final AiWorkoutGenerator? generator;

  @override
  State<AiWorkoutScreen> createState() => _AiWorkoutScreenState();
}

class _AiWorkoutScreenState extends State<AiWorkoutScreen> {
  late final AiWorkoutGenerator _generator =
      widget.generator ?? const MockAiWorkoutGenerator();

  AiWorkoutPreferences _preferences = AiWorkoutPreferences.initial;
  GeneratedWorkout? _workout;
  bool _loading = false;
  String? _error;

  Future<void> _generate() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
      _workout = null;
    });

    try {
      final workout = await _generator.generate(_preferences);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _workout = workout;
      });
    } on Exception {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not create a workout. Please try again.';
      });
    }
  }

  void _editSelections() {
    setState(() {
      _workout = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final workout = _workout;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('AI Workout'),
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: _loading
              ? const _GeneratingWorkout()
              : workout == null
              ? _PreferencesForm(
                  preferences: _preferences,
                  error: _error,
                  onGoal: (goal) => setState(() {
                    _preferences = AiWorkoutPreferences(
                      goal: goal,
                      level: _preferences.level,
                      durationMinutes: _preferences.durationMinutes,
                      equipment: _preferences.equipment,
                    );
                    _error = null;
                  }),
                  onLevel: (level) => setState(() {
                    _preferences = AiWorkoutPreferences(
                      goal: _preferences.goal,
                      level: level,
                      durationMinutes: _preferences.durationMinutes,
                      equipment: _preferences.equipment,
                    );
                    _error = null;
                  }),
                  onTime: (minutes) => setState(() {
                    _preferences = AiWorkoutPreferences(
                      goal: _preferences.goal,
                      level: _preferences.level,
                      durationMinutes: minutes,
                      equipment: _preferences.equipment,
                    );
                    _error = null;
                  }),
                  onEquipment: (equipment) => setState(() {
                    _preferences = AiWorkoutPreferences(
                      goal: _preferences.goal,
                      level: _preferences.level,
                      durationMinutes: _preferences.durationMinutes,
                      equipment: equipment,
                    );
                    _error = null;
                  }),
                )
              : _GeneratedPlan(workout: workout, preferences: _preferences),
        ),
      ),
      bottomNavigationBar: _loading
          ? null
          : WorkoutBottomBar(
              child: workout == null
                  ? FilledButton.icon(
                      key: const Key('generate-workout-button'),
                      onPressed: _generate,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Generate Workout'),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextButton(
                          key: const Key('ai-change-selections'),
                          onPressed: _editSelections,
                          child: const Text('Change selections'),
                        ),
                        const SizedBox(height: 4),
                        FilledButton.icon(
                          key: const Key('start-generated-workout'),
                          onPressed: workout.workout.exercises.isEmpty
                              ? null
                              : () =>
                                    openStartWorkout(context, workout.workout),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Start Workout'),
                        ),
                      ],
                    ),
            ),
    );
  }
}

class _PreferencesForm extends StatelessWidget {
  const _PreferencesForm({
    required this.preferences,
    required this.error,
    required this.onGoal,
    required this.onLevel,
    required this.onTime,
    required this.onEquipment,
  });

  final AiWorkoutPreferences preferences;
  final String? error;
  final ValueChanged<FitnessGoal> onGoal;
  final ValueChanged<FitnessLevel> onLevel;
  final ValueChanged<int> onTime;
  final ValueChanged<WorkoutEquipment> onEquipment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      key: const Key('ai-workout-form'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.auto_awesome, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Personalize your session',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Choose a goal, level, time, and equipment. Then generate a workout you can start right away.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 16),
          Text(
            error!,
            key: const Key('ai-workout-error'),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.error,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: 24),
        _OptionGroup<FitnessGoal>(
          title: 'Fitness goal',
          options: FitnessGoal.values,
          selected: preferences.goal,
          label: (goal) => goal.label,
          chipKey: (goal) => Key('ai-goal-${goal.name}'),
          onSelected: onGoal,
        ),
        const SizedBox(height: 22),
        _OptionGroup<FitnessLevel>(
          title: 'Fitness level',
          options: FitnessLevel.values,
          selected: preferences.level,
          label: (level) => level.label,
          chipKey: (level) => Key('ai-level-${level.name}'),
          onSelected: onLevel,
        ),
        const SizedBox(height: 22),
        _OptionGroup<int>(
          title: 'Available workout time',
          options: availableWorkoutTimes,
          selected: preferences.durationMinutes,
          label: (minutes) => '$minutes minutes',
          chipKey: (minutes) => Key('ai-time-$minutes'),
          onSelected: onTime,
        ),
        const SizedBox(height: 22),
        _OptionGroup<WorkoutEquipment>(
          title: 'Equipment available',
          options: WorkoutEquipment.values,
          selected: preferences.equipment,
          label: (equipment) => equipment.label,
          chipKey: (equipment) => Key('ai-equipment-${equipment.name}'),
          onSelected: onEquipment,
        ),
      ],
    );
  }
}

class _OptionGroup<T> extends StatelessWidget {
  const _OptionGroup({
    required this.title,
    required this.options,
    required this.selected,
    required this.label,
    required this.chipKey,
    required this.onSelected,
  });

  final String title;
  final List<T> options;
  final T selected;
  final String Function(T option) label;
  final Key Function(T option) chipKey;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ChoiceChip(
                key: chipKey(option),
                label: Text(label(option)),
                selected: option == selected,
                showCheckmark: false,
                onSelected: (isSelected) {
                  if (isSelected) onSelected(option);
                },
                selectedColor: colorScheme.primary,
                backgroundColor: colorScheme.surface,
                labelStyle: TextStyle(
                  color: option == selected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: option == selected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _GeneratingWorkout extends StatelessWidget {
  const _GeneratingWorkout();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        key: const Key('ai-workout-loading'),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              aiWorkoutLoadingMessage,
              key: const Key('ai-workout-loading-message'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneratedPlan extends StatelessWidget {
  const _GeneratedPlan({required this.workout, required this.preferences});

  final GeneratedWorkout workout;
  final AiWorkoutPreferences preferences;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      key: const Key('ai-workout-result'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Text(
          workout.workout.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your personalized workout is ready.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SummaryPill(label: 'Goal', value: preferences.goal.label),
            _SummaryPill(label: 'Level', value: preferences.level.label),
            _SummaryPill(label: 'Time', value: preferences.timeLabel),
            _SummaryPill(
              label: 'Equipment',
              value: preferences.equipment.label,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            WorkoutMeta(
              icon: Icons.timer_outlined,
              label: workout.workout.durationLabel,
            ),
            WorkoutMeta(
              icon: Icons.format_list_numbered,
              label: workout.workout.exerciseCountLabel,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Exercises',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < workout.exercises.length; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          _GeneratedExerciseCard(index: index, item: workout.exercises[index]),
        ],
      ],
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneratedExerciseCard extends StatelessWidget {
  const _GeneratedExerciseCard({required this.index, required this.item});

  final int index;
  final GeneratedExercise item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final exercise = item.exercise;

    return DecoratedBox(
      key: Key('generated-exercise-${exercise.id}'),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(exercise.icon, color: colorScheme.primary),
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
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
                    label: 'Reps',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: WorkoutStat(
                    icon: Icons.timer_outlined,
                    value: exercise.restLabel,
                    label: 'Rest time',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: WorkoutStat(
                    icon: Icons.timelapse,
                    value: item.durationLabel,
                    label: 'Duration',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void openAiWorkout(BuildContext context) {
  Navigator.of(
    context,
  ).push(fadePageRoute<void>(builder: (context) => const AiWorkoutScreen()));
}

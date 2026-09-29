import 'package:fitflow/core/fade_page_route.dart';
import 'package:fitflow/features/workout/exercise_details_screen.dart';
import 'package:fitflow/features/workout/workout_models.dart';
import 'package:fitflow/features/workout/workout_widgets.dart';
import 'package:flutter/material.dart';

class StartWorkoutScreen extends StatefulWidget {
  const StartWorkoutScreen({super.key, required this.workout});

  final Workout workout;

  @override
  State<StartWorkoutScreen> createState() => _StartWorkoutScreenState();
}

enum _SessionPhase { active, resting, complete }

class _StartWorkoutScreenState extends State<StartWorkoutScreen> {
  int _exerciseIndex = 0;
  int _setIndex = 0;
  _SessionPhase _phase = _SessionPhase.active;

  Exercise get _exercise => widget.workout.exercises[_exerciseIndex];

  bool get _isLastSet => _setIndex >= _exercise.sets - 1;

  bool get _isLastExercise =>
      _exerciseIndex >= widget.workout.exercises.length - 1;

  int get _totalSets => widget.workout.exercises.fold<int>(
    0,
    (sum, exercise) => sum + exercise.sets,
  );

  int get _completedSets {
    if (_phase == _SessionPhase.complete) return _totalSets;
    var completed = 0;
    for (var index = 0; index < _exerciseIndex; index++) {
      completed += widget.workout.exercises[index].sets;
    }
    completed += _setIndex;
    if (_phase == _SessionPhase.resting) completed += 1;
    return completed;
  }

  String get _primaryLabel => switch (_phase) {
    _SessionPhase.active => 'Complete set',
    _SessionPhase.resting when !_isLastSet => 'Next set',
    _SessionPhase.resting when !_isLastExercise => 'Next exercise',
    _SessionPhase.resting => 'Finish workout',
    _SessionPhase.complete => 'Done',
  };

  String get _restMessage {
    final rest = _exercise.restLabel;
    if (!_isLastSet) return 'Rest $rest before the next set.';
    if (!_isLastExercise) return 'Rest $rest before the next exercise.';
    return 'Rest $rest, then finish your workout.';
  }

  void _onPrimary() {
    switch (_phase) {
      case _SessionPhase.active:
        setState(() => _phase = _SessionPhase.resting);
      case _SessionPhase.resting:
        setState(() {
          if (!_isLastSet) {
            _setIndex += 1;
            _phase = _SessionPhase.active;
            return;
          }
          if (!_isLastExercise) {
            _exerciseIndex += 1;
            _setIndex = 0;
            _phase = _SessionPhase.active;
            return;
          }
          _phase = _SessionPhase.complete;
        });
      case _SessionPhase.complete:
        Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final complete = _phase == _SessionPhase.complete;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: Text(widget.workout.name),
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: complete
              ? _CompleteBody(workout: widget.workout)
              : Column(
                  children: [
                    LinearProgressIndicator(
                      value: _totalSets == 0 ? 0 : _completedSets / _totalSets,
                      minHeight: 4,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      color: colorScheme.primary,
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        children: [
                          Text(
                            'Exercise ${_exerciseIndex + 1} of ${widget.workout.exercises.length}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: WorkoutArtwork(
                              category: widget.workout.category,
                              icon: _exercise.icon,
                              badge: widget.workout.category.style.label,
                              height: 180,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _exercise.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _phase == _SessionPhase.resting
                                ? 'Set ${_setIndex + 1} of ${_exercise.sets} complete'
                                : 'Set ${_setIndex + 1} of ${_exercise.sets}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: WorkoutStat(
                                  icon: Icons.repeat,
                                  value: '${_exercise.sets}',
                                  label: 'Sets',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: WorkoutStat(
                                  icon: Icons.fitness_center,
                                  value: '${_exercise.repetitions}',
                                  label: 'Repetitions',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: WorkoutStat(
                                  icon: Icons.timer_outlined,
                                  value: _exercise.restLabel,
                                  label: 'Rest',
                                ),
                              ),
                            ],
                          ),
                          if (_phase == _SessionPhase.resting) ...[
                            const SizedBox(height: 16),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _restMessage,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              color: colorScheme
                                                  .onPrimaryContainer,
                                              height: 1.35,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          if (!_isLastExercise) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Up next · ${widget.workout.exercises[_exerciseIndex + 1].name}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => openExerciseDetails(
                                context,
                                exercise: _exercise,
                                workout: widget.workout,
                              ),
                              icon: const Icon(Icons.info_outline),
                              label: const Text('Exercise details'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: WorkoutBottomBar(
        child: FilledButton(
          key: const Key('session-primary-button'),
          onPressed: _onPrimary,
          child: Text(_primaryLabel),
        ),
      ),
    );
  }
}

class _CompleteBody extends StatelessWidget {
  const _CompleteBody({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
      children: [
        Center(
          child: Container(
            width: 88,
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 44,
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Workout complete',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You finished ${workout.name}.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            WorkoutMeta(
              icon: Icons.timer_outlined,
              label: workout.durationLabel,
            ),
            WorkoutMeta(
              icon: Icons.local_fire_department_outlined,
              label: workout.caloriesLabel,
            ),
            WorkoutMeta(
              icon: Icons.format_list_numbered,
              label: workout.exerciseCountLabel,
            ),
          ],
        ),
      ],
    );
  }
}

void openStartWorkout(BuildContext context, Workout workout) {
  Navigator.of(context).push(
    fadePageRoute<void>(
      builder: (context) => StartWorkoutScreen(workout: workout),
    ),
  );
}

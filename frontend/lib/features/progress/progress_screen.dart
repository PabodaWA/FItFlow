import 'package:fitflow/features/profile/profile_models.dart';
import 'package:fitflow/features/profile/profile_widgets.dart';
import 'package:fitflow/features/progress/progress_mock_data.dart';
import 'package:fitflow/features/progress/progress_models.dart';
import 'package:flutter/material.dart';

const _workoutColor = Color(0xFF1B7F4E);
const _calorieColor = Color(0xFFE25B2A);
const _durationColor = Color(0xFF2F6FED);
const _weightColor = Color(0xFF0F766E);
const _streakColor = Color(0xFFB86E00);

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, this.snapshot, this.useMetricUnits = true});

  /// Local snapshot shown before a progress backend is connected.
  final ProgressSnapshot? snapshot;
  final bool useMetricUnits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = snapshot ?? ProgressMockData.week;
    final todayIndex = DateTime.now().weekday - 1;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Progress'),
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            key: const Key('progress-list'),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Text(
                'This week',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              _MetricCard(
                titleKey: const Key('progress-weekly-workouts'),
                title: 'Weekly workouts',
                value: formatStatCount(progress.weeklyWorkouts),
                detail:
                    '${formatStatCount(progress.weeklyWorkouts)} / ${formatStatCount(progress.workoutTarget)} workouts',
                progress: progress.workoutProgress,
                color: _workoutColor,
                icon: Icons.fitness_center,
                chart: _BarChart(
                  labels: [for (final day in progress.days) day.label],
                  fractions: [
                    for (final day in progress.days)
                      visualBarFraction(
                        day.workouts,
                        progress.peak((entry) => entry.workouts),
                      ),
                  ],
                  todayIndex: todayIndex,
                  color: _workoutColor,
                ),
              ),
              const SizedBox(height: 14),
              _MetricCard(
                titleKey: const Key('progress-calories'),
                title: 'Calories burned',
                value: '${formatStatCount(progress.caloriesBurned)} kcal',
                detail:
                    '${formatStatCount(progress.caloriesBurned)} / ${formatStatCount(progress.calorieTarget)} kcal',
                progress: progress.calorieProgress,
                color: _calorieColor,
                icon: Icons.local_fire_department_outlined,
                chart: _BarChart(
                  labels: [for (final day in progress.days) day.label],
                  fractions: [
                    for (final day in progress.days)
                      visualBarFraction(
                        day.calories,
                        progress.peak((entry) => entry.calories),
                      ),
                  ],
                  todayIndex: todayIndex,
                  color: _calorieColor,
                ),
              ),
              const SizedBox(height: 14),
              _MetricCard(
                titleKey: const Key('progress-duration'),
                title: 'Workout duration',
                value: '${formatStatCount(progress.durationMinutes)} min',
                detail:
                    '${formatStatCount(progress.durationMinutes)} / ${formatStatCount(progress.durationTargetMinutes)} min',
                progress: progress.durationProgress,
                color: _durationColor,
                icon: Icons.timer_outlined,
                chart: _BarChart(
                  labels: [for (final day in progress.days) day.label],
                  fractions: [
                    for (final day in progress.days)
                      visualBarFraction(
                        day.durationMinutes,
                        progress.peak((entry) => entry.durationMinutes),
                      ),
                  ],
                  todayIndex: todayIndex,
                  color: _durationColor,
                ),
              ),
              const SizedBox(height: 14),
              _WeightCard(progress: progress, useMetricUnits: useMetricUnits),
              const SizedBox(height: 14),
              _StreakCard(progress: progress),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.titleKey,
    required this.title,
    required this.value,
    required this.detail,
    required this.progress,
    required this.color,
    required this.icon,
    required this.chart,
  });

  final Key titleKey;
  final String title;
  final String value;
  final String detail;
  final double progress;
  final Color color;
  final IconData icon;
  final Widget chart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: profileCardDecoration(colorScheme),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _MetricIcon(icon: icon, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    key: titleKey,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      value,
                      maxLines: 1,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              detail,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            chart,
          ],
        ),
      ),
    );
  }
}

class _MetricIcon extends StatelessWidget {
  const _MetricIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({
    required this.labels,
    required this.fractions,
    required this.todayIndex,
    required this.color,
  });

  final List<String> labels;
  final List<double> fractions;
  final int todayIndex;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var index = 0; index < labels.length; index++)
            Expanded(
              child: _DayBar(
                label: labels[index],
                fraction: index < fractions.length ? fractions[index] : 0,
                isToday: index == todayIndex,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.label,
    required this.fraction,
    required this.isToday,
    required this.color,
  });

  final String label;
  final double fraction;
  final bool isToday;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final barColor = isToday ? color : color.withValues(alpha: 0.45);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: fraction.clamp(0, 1),
                widthFactor: 0.62,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              color: isToday ? color : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightCard extends StatelessWidget {
  const _WeightCard({required this.progress, required this.useMetricUnits});

  final ProgressSnapshot progress;
  final bool useMetricUnits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final percent = (progress.weightProgressValue * 100).round();
    final current = formatBodyWeight(
      progress.currentWeightKg,
      useMetric: useMetricUnits,
    );

    return DecoratedBox(
      decoration: profileCardDecoration(colorScheme),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _MetricIcon(
                  icon: Icons.monitor_weight_outlined,
                  color: _weightColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Weight progress',
                    key: const Key('progress-weight'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      current,
                      key: const Key('progress-weight-value'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _weightColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$percent% to goal',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.weightProgressValue,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: _weightColor,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: CustomPaint(
                painter: _WeightChartPainter(
                  values: [
                    for (final entry in progress.weights) entry.kilograms,
                  ],
                  lineColor: _weightColor,
                  gridColor: colorScheme.outlineVariant,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final entry in progress.weights)
                  Expanded(
                    child: Text(
                      entry.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              weightSummaryLabel(
                startKg: progress.startWeightKg,
                currentKg: progress.currentWeightKg,
                targetKg: progress.targetWeightKg,
                useMetric: useMetricUnits,
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  const _WeightChartPainter({
    required this.values,
    required this.lineColor,
    required this.gridColor,
  });

  final List<double> values;
  final Color lineColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || size.width <= 0 || size.height <= 0) return;

    var minValue = values.first;
    var maxValue = values.first;
    for (final value in values) {
      if (value < minValue) minValue = value;
      if (value > maxValue) maxValue = value;
    }
    final span = (maxValue - minValue).abs() < 0.01 ? 1.0 : maxValue - minValue;
    final chart = Rect.fromLTWH(4, 8, size.width - 8, size.height - 16);

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final step in [0.0, 0.5, 1.0]) {
      final y = chart.bottom - chart.height * step;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
    }

    Offset pointFor(int index) {
      final dx = values.length == 1
          ? chart.center.dx
          : chart.left + chart.width * index / (values.length - 1);
      final dy =
          chart.bottom - chart.height * ((values[index] - minValue) / span);
      return Offset(dx, dy);
    }

    final path = Path()..moveTo(pointFor(0).dx, pointFor(0).dy);
    for (var index = 1; index < values.length; index++) {
      final point = pointFor(index);
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final dotPaint = Paint()..color = lineColor;
    final holePaint = Paint()..color = Colors.white;
    for (var index = 0; index < values.length; index++) {
      final point = pointFor(index);
      canvas.drawCircle(point, 4.5, holePaint);
      canvas.drawCircle(point, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.progress});

  final ProgressSnapshot progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      decoration: profileCardDecoration(colorScheme),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress.streakProgress,
                        strokeWidth: 6,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        color: _streakColor,
                      ),
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: _streakColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Streak',
                        key: const Key('progress-streak'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${formatStatCount(progress.streakDays)} day streak',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _streakColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Best ${formatStatCount(progress.bestStreakDays)} days · ${formatStatCount(progress.streakDays)} / ${formatStatCount(progress.streakTargetDays)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'This week',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final day in progress.days)
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          day.workouts > 0
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: day.workouts > 0
                              ? _streakColor
                              : colorScheme.outline,
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

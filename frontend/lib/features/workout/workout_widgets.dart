import 'package:fitflow/features/workout/workout_models.dart';
import 'package:flutter/material.dart';

class WorkoutArtwork extends StatelessWidget {
  const WorkoutArtwork({
    super.key,
    required this.category,
    required this.icon,
    this.badge,
    this.height = 168,
    this.compact = false,
  });

  final WorkoutCategory category;
  final IconData icon;
  final String? badge;
  final double? height;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = category.style;
    final artwork = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: style.colors,
        ),
      ),
      child: compact
          ? Center(child: Icon(icon, color: Colors.white, size: 28))
          : Stack(
              fit: StackFit.expand,
              children: [
                const CustomPaint(painter: _ArtworkPatternPainter()),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (badge != null) _ArtworkBadge(label: badge!),
                      const Spacer(),
                      Icon(icon, color: Colors.white, size: 36),
                    ],
                  ),
                ),
              ],
            ),
    );

    if (height == null) return artwork;
    return SizedBox(height: height, width: double.infinity, child: artwork);
  }
}

class _ArtworkBadge extends StatelessWidget {
  const _ArtworkBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ArtworkPatternPainter extends CustomPainter {
  const _ArtworkPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()..color = const Color(0x1FFFFFFF);
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.18), 54, glow);
    canvas.drawCircle(Offset(size.width * 0.08, size.height * 1.08), 78, glow);
    final icon = Paint()..color = const Color(0x14FFFFFF);
    canvas.drawCircle(Offset(size.width + 8, size.height + 10), 90, icon);
  }

  @override
  bool shouldRepaint(covariant _ArtworkPatternPainter oldDelegate) => false;
}

class DifficultyPill extends StatelessWidget {
  const DifficultyPill({super.key, required this.difficulty});

  final WorkoutDifficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final color = difficulty.color;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          difficulty.label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class WorkoutMeta extends StatelessWidget {
  const WorkoutMeta({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class WorkoutStat extends StatelessWidget {
  const WorkoutStat({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = color ?? colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Column(
          children: [
            Icon(icon, size: 20, color: accent),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                softWrap: false,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutBottomBar extends StatelessWidget {
  const WorkoutBottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:fitflow/core/fade_page_route.dart';
import 'package:fitflow/features/nutrition/add_meal_screen.dart';
import 'package:fitflow/features/nutrition/nutrition_mock_data.dart';
import 'package:fitflow/features/nutrition/nutrition_models.dart';
import 'package:flutter/material.dart';

const _calorieColor = Color(0xFFE25B2A);
const _proteinColor = Color(0xFF2F6FED);
const _carbColor = Color(0xFFB86E00);
const _fatColor = Color(0xFFC2410C);
const _waterColor = Color(0xFF0F766E);

class NutritionView extends StatefulWidget {
  const NutritionView({super.key, this.initialDay});

  /// Local log shown before a nutrition backend is connected.
  final NutritionDay? initialDay;

  @override
  State<NutritionView> createState() => _NutritionViewState();
}

class _NutritionViewState extends State<NutritionView> {
  late NutritionDay _day;

  @override
  void initState() {
    super.initState();
    _day = widget.initialDay ?? NutritionMockData.today;
  }

  Future<void> _addMeal() async {
    final food = await Navigator.of(context).push<FoodEntry>(
      fadePageRoute<FoodEntry>(builder: (context) => const AddMealScreen()),
    );
    if (!mounted || food == null) return;
    setState(() => _day = _day.addFood(food));
  }

  void _addGlass() {
    setState(() => _day = _day.addWater(nutritionGlassMl));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ColoredBox(
      color: colorScheme.surfaceContainerLow,
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              key: const Key('nutrition-list'),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                Text(
                  'Nutrition',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Today\'s intake',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),
                _DailyCaloriesCard(day: _day),
                const SizedBox(height: 28),
                const _SectionTitle('Today\'s targets'),
                const SizedBox(height: 12),
                _MacroGrid(day: _day),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const Key('add-water-button'),
                    onPressed: _addGlass,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _waterColor,
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(
                        color: _waterColor.withValues(alpha: 0.45),
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                    ),
                    icon: const Icon(Icons.water_drop_outlined),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Add glass · ${waterLabel(nutritionGlassMl)}',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const _SectionTitle('Meals'),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('add-meal-button'),
                  onPressed: _addMeal,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Meal'),
                ),
                const SizedBox(height: 16),
                for (
                  var index = 0;
                  index < MealSlot.values.length;
                  index++
                ) ...[
                  if (index > 0) const SizedBox(height: 14),
                  _MealCard(
                    slot: MealSlot.values[index],
                    foods: _day.foodsFor(MealSlot.values[index]),
                    calories: _day.caloriesFor(MealSlot.values[index]),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _DailyCaloriesCard extends StatelessWidget {
  const _DailyCaloriesCard({required this.day});

  final NutritionDay day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = nutritionProgress(day.calories, day.targets.calories);
    final remaining = calorieBalanceLabel(day.calories, day.targets.calories);
    final over = day.calories > day.targets.calories;

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily calories',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            caloriesLabel(day.calories),
            key: const Key('daily-calorie-total'),
            maxLines: 1,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'of ${caloriesLabel(day.targets.calories)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          remaining,
          key: const Key('calorie-balance'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: over ? colorScheme.error : _calorieColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: _calorieColor.withValues(alpha: 0.16),
            color: _calorieColor,
          ),
        ),
      ],
    );

    return DecoratedBox(
      key: const Key('daily-calories'),
      decoration: _cardDecoration(colorScheme, radius: 24),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final ring = _NutritionRing(
              progress: progress,
              color: _calorieColor,
              size: 96,
              strokeWidth: 9,
            );
            if (constraints.maxWidth < 300) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(child: ring),
                  const SizedBox(height: 16),
                  details,
                ],
              );
            }
            return Row(
              children: [
                ring,
                const SizedBox(width: 16),
                Expanded(child: details),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MacroGrid extends StatelessWidget {
  const _MacroGrid({required this.day});

  final NutritionDay day;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MacroCard(
                cardKey: const Key('macro-protein'),
                label: 'Protein',
                value: macroGramsLabel(day.proteinGrams),
                goal: macroGramsLabel(day.targets.proteinGrams),
                progress: nutritionProgress(
                  day.proteinGrams,
                  day.targets.proteinGrams,
                ),
                color: _proteinColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MacroCard(
                cardKey: const Key('macro-carbohydrates'),
                label: 'Carbohydrates',
                value: macroGramsLabel(day.carbsGrams),
                goal: macroGramsLabel(day.targets.carbsGrams),
                progress: nutritionProgress(
                  day.carbsGrams,
                  day.targets.carbsGrams,
                ),
                color: _carbColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MacroCard(
                cardKey: const Key('macro-fat'),
                label: 'Fat',
                value: macroGramsLabel(day.fatGrams),
                goal: macroGramsLabel(day.targets.fatGrams),
                progress: nutritionProgress(day.fatGrams, day.targets.fatGrams),
                color: _fatColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MacroCard(
                cardKey: const Key('macro-water'),
                label: 'Water',
                value: waterLabel(day.waterMl),
                goal: waterLabel(day.targets.waterMl),
                progress: nutritionProgress(day.waterMl, day.targets.waterMl),
                color: _waterColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  const _MacroCard({
    required this.cardKey,
    required this.label,
    required this.value,
    required this.goal,
    required this.progress,
    required this.color,
  });

  final Key cardKey;
  final String label;
  final String value;
  final String goal;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final labelStyle = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.2,
    );
    final labelLineHeight =
        MediaQuery.textScalerOf(context).scale(labelStyle?.fontSize ?? 12) *
        (labelStyle?.height ?? 1.2);

    return DecoratedBox(
      key: cardKey,
      decoration: _cardDecoration(colorScheme, radius: 20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        child: Column(
          children: [
            _NutritionRing(progress: progress, color: color, size: 64),
            const SizedBox(height: 10),
            SizedBox(
              height: labelLineHeight * 2,
              width: double.infinity,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: labelStyle,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  maxLines: 1,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'of $goal',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: color.withValues(alpha: 0.16),
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionRing extends StatelessWidget {
  const _NutritionRing({
    required this.progress,
    required this.color,
    this.size = 72,
    this.strokeWidth = 7,
  });

  final double progress;
  final Color color;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: strokeWidth,
            strokeAlign: CircularProgressIndicator.strokeAlignInside,
            strokeCap: StrokeCap.round,
            backgroundColor: color.withValues(alpha: 0.16),
            color: color,
          ),
          Padding(
            padding: EdgeInsets.all(strokeWidth + 6),
            child: FittedBox(
              child: Text(
                '$percent%',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.slot,
    required this.foods,
    required this.calories,
  });

  final MealSlot slot;
  final List<FoodEntry> foods;
  final int calories;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DecoratedBox(
      key: Key('meal-${slot.name}'),
      decoration: _cardDecoration(colorScheme, radius: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: slot.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(slot.icon, size: 20, color: slot.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    slot.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  caloriesLabel(calories),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: slot.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (foods.isEmpty)
              Text(
                'No foods logged.',
                key: Key('meal-empty-${slot.name}'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else
              for (var index = 0; index < foods.length; index++) ...[
                if (index > 0) ...[
                  const SizedBox(height: 12),
                  Divider(height: 1, color: colorScheme.outlineVariant),
                  const SizedBox(height: 12),
                ],
                _FoodRow(food: foods[index]),
              ],
          ],
        ),
      ),
    );
  }
}

class _FoodRow extends StatelessWidget {
  const _FoodRow({required this.food});

  final FoodEntry food;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      key: Key('food-${food.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          food.name,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          food.macroLine,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

BoxDecoration _cardDecoration(
  ColorScheme colorScheme, {
  required double radius,
}) {
  return BoxDecoration(
    color: colorScheme.surface,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

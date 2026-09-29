import 'package:flutter/material.dart';

enum MealSlot { breakfast, lunch, dinner, snacks }

extension MealSlotPresentation on MealSlot {
  String get label => switch (this) {
    MealSlot.breakfast => 'Breakfast',
    MealSlot.lunch => 'Lunch',
    MealSlot.dinner => 'Dinner',
    MealSlot.snacks => 'Snacks',
  };

  IconData get icon => switch (this) {
    MealSlot.breakfast => Icons.wb_sunny_outlined,
    MealSlot.lunch => Icons.lunch_dining_outlined,
    MealSlot.dinner => Icons.dinner_dining_outlined,
    MealSlot.snacks => Icons.cookie_outlined,
  };

  Color get color => switch (this) {
    MealSlot.breakfast => const Color(0xFFB86E00),
    MealSlot.lunch => const Color(0xFF1B7F4E),
    MealSlot.dinner => const Color(0xFF2F6FED),
    MealSlot.snacks => const Color(0xFFDB2777),
  };
}

/// One glass logged from the nutrition dashboard.
const nutritionGlassMl = 250;

class NutritionTargets {
  const NutritionTargets({
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.waterMl,
  });

  static const standard = NutritionTargets(
    calories: 2200,
    proteinGrams: 150,
    carbsGrams: 250,
    fatGrams: 70,
    waterMl: 2500,
  );

  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final int waterMl;
}

class FoodEntry {
  const FoodEntry({
    required this.id,
    required this.name,
    required this.slot,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });

  final String id;
  final String name;
  final MealSlot slot;
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;

  String get macroLine =>
      '${caloriesLabel(calories)} · Protein ${macroGramsLabel(proteinGrams)} · Carbs ${macroGramsLabel(carbsGrams)} · Fat ${macroGramsLabel(fatGrams)}';
}

class NutritionDay {
  const NutritionDay({
    required this.foods,
    required this.waterMl,
    this.targets = NutritionTargets.standard,
  });

  final List<FoodEntry> foods;
  final int waterMl;
  final NutritionTargets targets;

  int get calories => foods.fold(0, (sum, food) => sum + food.calories);

  int get proteinGrams => foods.fold(0, (sum, food) => sum + food.proteinGrams);

  int get carbsGrams => foods.fold(0, (sum, food) => sum + food.carbsGrams);

  int get fatGrams => foods.fold(0, (sum, food) => sum + food.fatGrams);

  List<FoodEntry> foodsFor(MealSlot slot) {
    return foods.where((food) => food.slot == slot).toList(growable: false);
  }

  int caloriesFor(MealSlot slot) {
    return foodsFor(slot).fold(0, (sum, food) => sum + food.calories);
  }

  NutritionDay addFood(FoodEntry food) {
    return NutritionDay(
      foods: [...foods, food],
      waterMl: waterMl,
      targets: targets,
    );
  }

  NutritionDay addWater(int milliliters) {
    return NutritionDay(
      foods: foods,
      waterMl: waterMl + milliliters,
      targets: targets,
    );
  }
}

String newFoodId() => 'food-${DateTime.now().microsecondsSinceEpoch}';

String formatNutritionCount(int value) {
  final negative = value < 0;
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    final remaining = digits.length - index;
    if (index > 0 && remaining % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[index]);
  }
  final formatted = buffer.toString();
  return negative ? '-$formatted' : formatted;
}

String caloriesLabel(int calories) => '${formatNutritionCount(calories)} kcal';

String macroGramsLabel(int grams) => '${formatNutritionCount(grams)} g';

String waterLabel(int milliliters) => '${formatNutritionCount(milliliters)} ml';

double nutritionProgress(int current, int target) {
  if (target <= 0) return 0;
  return (current / target).clamp(0, 1).toDouble();
}

int nutritionPercent(int current, int target) {
  return (nutritionProgress(current, target) * 100).round();
}

String calorieBalanceLabel(int current, int target) {
  final delta = target - current;
  if (delta >= 0) return '${caloriesLabel(delta)} remaining';
  return '${caloriesLabel(-delta)} over';
}

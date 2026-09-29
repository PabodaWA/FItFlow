import 'package:fitflow/features/nutrition/nutrition_models.dart';

/// Local meals for the nutrition tab until the nutrition service is connected.
abstract final class NutritionMockData {
  static const today = NutritionDay(
    waterMl: 1500,
    foods: [
      FoodEntry(
        id: 'yogurt',
        name: 'Greek yogurt with berries',
        slot: MealSlot.breakfast,
        calories: 280,
        proteinGrams: 22,
        carbsGrams: 28,
        fatGrams: 8,
      ),
      FoodEntry(
        id: 'oats',
        name: 'Oatmeal with banana',
        slot: MealSlot.breakfast,
        calories: 320,
        proteinGrams: 10,
        carbsGrams: 54,
        fatGrams: 7,
      ),
      FoodEntry(
        id: 'chicken',
        name: 'Grilled chicken bowl',
        slot: MealSlot.lunch,
        calories: 540,
        proteinGrams: 42,
        carbsGrams: 48,
        fatGrams: 16,
      ),
      FoodEntry(
        id: 'salmon',
        name: 'Salmon and rice',
        slot: MealSlot.dinner,
        calories: 610,
        proteinGrams: 38,
        carbsGrams: 52,
        fatGrams: 24,
      ),
      FoodEntry(
        id: 'apple',
        name: 'Apple and almonds',
        slot: MealSlot.snacks,
        calories: 210,
        proteinGrams: 6,
        carbsGrams: 22,
        fatGrams: 12,
      ),
    ],
  );
}

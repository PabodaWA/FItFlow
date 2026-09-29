import 'package:fitflow/features/nutrition/add_meal_screen.dart';
import 'package:fitflow/features/nutrition/nutrition_mock_data.dart';
import 'package:fitflow/features/nutrition/nutrition_models.dart';
import 'package:fitflow/features/nutrition/nutrition_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sample day totals match the local nutrition log', () {
    final day = NutritionMockData.today;

    expect(day.calories, 1960);
    expect(day.proteinGrams, 118);
    expect(day.carbsGrams, 204);
    expect(day.fatGrams, 67);
    expect(day.waterMl, 1500);
    expect(day.targets.calories, 2200);
    expect(day.foodsFor(MealSlot.breakfast).map((food) => food.name), [
      'Greek yogurt with berries',
      'Oatmeal with banana',
    ]);
    expect(day.caloriesFor(MealSlot.breakfast), 600);
    expect(day.caloriesFor(MealSlot.lunch), 540);
    expect(day.caloriesFor(MealSlot.dinner), 610);
    expect(day.caloriesFor(MealSlot.snacks), 210);
    expect(nutritionPercent(day.calories, day.targets.calories), 89);
    expect(nutritionPercent(day.proteinGrams, day.targets.proteinGrams), 79);
    expect(nutritionPercent(day.carbsGrams, day.targets.carbsGrams), 82);
    expect(nutritionPercent(day.fatGrams, day.targets.fatGrams), 96);
    expect(nutritionPercent(day.waterMl, day.targets.waterMl), 60);
    expect(
      calorieBalanceLabel(day.calories, day.targets.calories),
      '240 kcal remaining',
    );
    expect(
      day.foods.first.macroLine,
      '280 kcal · Protein 22 g · Carbs 28 g · Fat 8 g',
    );
  });

  test(
    'progress stays within the ring and counts use thousands separators',
    () {
      expect(nutritionProgress(500, 1000), 0.5);
      expect(nutritionProgress(1500, 1000), 1);
      expect(nutritionProgress(0, 1000), 0);
      expect(nutritionProgress(10, 0), 0);
      expect(nutritionPercent(1, 3), 33);
      expect(formatNutritionCount(0), '0');
      expect(formatNutritionCount(999), '999');
      expect(formatNutritionCount(2500), '2,500');
      expect(formatNutritionCount(1000000), '1,000,000');
      expect(calorieBalanceLabel(2300, 2200), '100 kcal over');
    },
  );

  test('adding food or water keeps the previous log unchanged', () {
    final day = NutritionMockData.today;
    final next = day
        .addFood(
          const FoodEntry(
            id: 'shake',
            name: 'Protein shake',
            slot: MealSlot.snacks,
            calories: 180,
            proteinGrams: 30,
            carbsGrams: 8,
            fatGrams: 3,
          ),
        )
        .addWater(nutritionGlassMl);

    expect(day.foods, hasLength(5));
    expect(day.waterMl, 1500);
    expect(next.foods, hasLength(6));
    expect(next.calories, 2140);
    expect(next.proteinGrams, 148);
    expect(next.foodsFor(MealSlot.snacks).last.name, 'Protein shake');
    expect(next.waterMl, 1750);
  });

  test('meal form rejects empty and out-of-range values', () {
    expect(validateFoodName('  '), 'Enter the food name.');
    expect(validateFoodName('Oats'), isNull);
    expect(validateFoodName('a' * 61), 'Use 60 characters or fewer.');
    expect(
      validateNutritionAmount('', label: 'calories', max: maxCalories),
      'Enter calories.',
    );
    expect(
      validateNutritionAmount('12a', label: 'protein', max: maxMacroGrams),
      'Use a whole number.',
    );
    expect(
      validateNutritionAmount('5001', label: 'calories', max: maxCalories),
      'Use 5000 or less.',
    );
    expect(
      validateNutritionAmount('0', label: 'fat', max: maxMacroGrams),
      isNull,
    );
  });

  testWidgets('dashboard shows calories, macros, water, and meals', (
    tester,
  ) async {
    await pumpNutrition(tester, size: const Size(390, 2600));
    final day = NutritionMockData.today;

    expect(find.text('Nutrition'), findsWidgets);
    expect(find.text('Today\'s intake'), findsOneWidget);
    expect(find.text('Daily calories'), findsOneWidget);
    expect(find.text(caloriesLabel(day.calories)), findsOneWidget);
    expect(
      find.text('of ${caloriesLabel(day.targets.calories)}'),
      findsOneWidget,
    );
    expect(find.text('240 kcal remaining'), findsOneWidget);
    expect(find.text('Protein'), findsOneWidget);
    expect(find.text('Carbohydrates'), findsWidgets);
    expect(find.text('Fat'), findsWidgets);
    expect(find.text('Water'), findsOneWidget);
    expect(find.text(macroGramsLabel(day.proteinGrams)), findsOneWidget);
    expect(find.text(macroGramsLabel(day.carbsGrams)), findsOneWidget);
    expect(find.text(macroGramsLabel(day.fatGrams)), findsOneWidget);
    expect(find.text(waterLabel(day.waterMl)), findsOneWidget);
    expect(find.text('89%'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNWidgets(5));
    expect(find.byType(LinearProgressIndicator), findsNWidgets(5));

    expect(find.text('Breakfast', skipOffstage: false), findsOneWidget);
    expect(find.text('Lunch', skipOffstage: false), findsOneWidget);
    expect(find.text('Dinner', skipOffstage: false), findsOneWidget);
    expect(find.text('Snacks', skipOffstage: false), findsOneWidget);
    expect(
      find.text('Greek yogurt with berries', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text(day.foods.first.macroLine, skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.text('Grilled chicken bowl', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Salmon and rice', skipOffstage: false), findsOneWidget);
    expect(find.text('Apple and almonds', skipOffstage: false), findsOneWidget);
    expect(find.text('Add Meal', skipOffstage: false), findsOneWidget);
    expect(find.text('No foods logged.', skipOffstage: false), findsNothing);
  });

  testWidgets('adding a glass updates the water progress', (tester) async {
    await pumpNutrition(tester);

    await tester.scrollUntilVisible(
      find.byKey(const Key('add-water-button')),
      300,
    );
    await tester.tap(find.byKey(const Key('add-water-button')));
    await tester.pumpAndSettle();

    expect(find.text(waterLabel(1750), skipOffstage: false), findsOneWidget);
    expect(find.text(waterLabel(1500), skipOffstage: false), findsNothing);
    expect(find.text('70%', skipOffstage: false), findsOneWidget);
    expect(find.text('60%', skipOffstage: false), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('add meal validates, then logs the food locally', (tester) async {
    await pumpNutrition(tester);

    await tester.scrollUntilVisible(
      find.byKey(const Key('add-meal-button')),
      300,
    );
    await tester.tap(find.byKey(const Key('add-meal-button')));
    await tester.pumpAndSettle();

    expect(find.text('Log a food'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Calories'), findsOneWidget);
    expect(find.text('Protein'), findsOneWidget);
    expect(find.text('Carbohydrates'), findsWidgets);
    expect(find.text('Fat'), findsWidgets);

    await tester.tap(find.byKey(const Key('save-meal-button')));
    await tester.pumpAndSettle();
    expect(find.text('Enter the food name.'), findsOneWidget);
    expect(find.text('Enter calories.'), findsOneWidget);
    expect(find.text('Enter protein.'), findsOneWidget);
    expect(find.text('Enter carbohydrates.'), findsOneWidget);
    expect(find.text('Enter fat.'), findsOneWidget);
    expect(find.text('Cottage cheese'), findsNothing);

    await tester.tap(find.byKey(const Key('meal-slot-snacks')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('meal-food-name')),
      'Cottage cheese',
    );
    await tester.enterText(find.byKey(const Key('meal-calories')), '120');
    await tester.enterText(find.byKey(const Key('meal-protein')), '14');
    await tester.enterText(find.byKey(const Key('meal-carbs')), '6');
    await tester.enterText(find.byKey(const Key('meal-fat')), '5');
    await tester.tap(find.byKey(const Key('save-meal-button')));
    await tester.pumpAndSettle();

    expect(find.text('Log a food'), findsNothing);
    expect(find.text('Cottage cheese', skipOffstage: false), findsOneWidget);
    expect(
      find.text(
        '120 kcal · Protein 14 g · Carbs 6 g · Fat 5 g',
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    expect(find.text('Snacks', skipOffstage: false), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('daily-calorie-total')),
      -400,
    );
    expect(find.text(caloriesLabel(2080)), findsOneWidget);
    expect(
      find.text(macroGramsLabel(132), skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('1,960 kcal', skipOffstage: false), findsNothing);
  });

  testWidgets('leaving the form does not add a meal', (tester) async {
    await pumpNutrition(tester);

    await tester.scrollUntilVisible(
      find.byKey(const Key('add-meal-button')),
      300,
    );
    await tester.tap(find.byKey(const Key('add-meal-button')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('daily-calorie-total')),
      -400,
    );
    expect(find.text('1,960 kcal'), findsOneWidget);
    expect(find.text('Cottage cheese', skipOffstage: false), findsNothing);
  });

  testWidgets('an empty meal shows that nothing is logged', (tester) async {
    final foods = NutritionMockData.today.foods
        .where((food) => food.slot != MealSlot.snacks)
        .toList();
    await pumpNutrition(tester, day: NutritionDay(foods: foods, waterMl: 0));

    await tester.scrollUntilVisible(
      find.byKey(const Key('meal-empty-snacks')),
      300,
    );
    expect(find.text('No foods logged.', skipOffstage: false), findsOneWidget);
    expect(find.text('0 ml', skipOffstage: false), findsOneWidget);
    expect(find.text('0%', skipOffstage: false), findsOneWidget);
  });

  testWidgets('nutrition layouts avoid overflow', (tester) async {
    const sizes = <Size>[
      Size(320, 568),
      Size(360, 640),
      Size(390, 844),
      Size(768, 1024),
      Size(800, 400),
    ];

    for (final size in sizes) {
      await pumpNutrition(tester, size: size);
      await _exerciseNutritionLayout(tester);
    }

    await pumpNutrition(tester, size: const Size(340, 700), textScale: 1.4);
    await _exerciseNutritionLayout(tester);
  });
}

Future<void> _exerciseNutritionLayout(WidgetTester tester) async {
  final list = find.descendant(
    of: find.byKey(const Key('nutrition-list')),
    matching: find.byType(Scrollable),
  );
  final form = find.descendant(
    of: find.byKey(const Key('add-meal-form')),
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    ),
  );

  await tester.scrollUntilVisible(
    find.text('Apple and almonds'),
    400,
    scrollable: list,
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);

  await tester.scrollUntilVisible(
    find.byKey(const Key('add-meal-button')),
    -400,
    scrollable: list,
  );
  await tester.tap(find.byKey(const Key('add-meal-button')));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.text('Save meal'),
    400,
    scrollable: form,
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  await tester.pageBack();
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> pumpNutrition(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double textScale = 1,
  NutritionDay? day,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B7F4E)),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        );
      },
      home: NutritionView(initialDay: day),
    ),
  );
  await tester.pumpAndSettle();
}

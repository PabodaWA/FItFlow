import 'package:fitflow/features/nutrition/nutrition_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const maxFoodNameLength = 60;
const maxCalories = 5000;
const maxMacroGrams = 999;

String? validateFoodName(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) return 'Enter the food name.';
  if (name.length > maxFoodNameLength) {
    return 'Use $maxFoodNameLength characters or fewer.';
  }
  return null;
}

String? validateNutritionAmount(
  String? value, {
  required String label,
  required int max,
}) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Enter $label.';
  final amount = int.tryParse(text);
  if (amount == null) return 'Use a whole number.';
  if (amount < 0) return 'Use 0 or more.';
  if (amount > max) return 'Use $max or less.';
  return null;
}

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  var _slot = MealSlot.breakfast;
  var _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    final food = FoodEntry(
      id: newFoodId(),
      name: _nameController.text.trim(),
      slot: _slot,
      calories: int.parse(_caloriesController.text.trim()),
      proteinGrams: int.parse(_proteinController.text.trim()),
      carbsGrams: int.parse(_carbsController.text.trim()),
      fatGrams: int.parse(_fatController.text.trim()),
    );
    Navigator.of(context).pop(food);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Add Meal'),
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
            child: ListView(
              key: const Key('add-meal-form'),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                Text(
                  'Log a food',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose a meal, then enter the food and its macros.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Meal',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final slot in MealSlot.values)
                      ChoiceChip(
                        key: Key('meal-slot-${slot.name}'),
                        label: Text(slot.label),
                        selected: slot == _slot,
                        showCheckmark: false,
                        onSelected: (selected) {
                          if (selected) setState(() => _slot = slot);
                        },
                        selectedColor: colorScheme.primary,
                        backgroundColor: colorScheme.surface,
                        labelStyle: TextStyle(
                          color: slot == _slot
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide(
                          color: slot == _slot
                              ? colorScheme.primary
                              : colorScheme.outlineVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                TextFormField(
                  key: const Key('meal-food-name'),
                  controller: _nameController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  maxLength: maxFoodNameLength,
                  decoration: const InputDecoration(
                    labelText: 'Food',
                    prefixIcon: Icon(Icons.restaurant_outlined),
                    counterText: '',
                  ),
                  validator: validateFoodName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('meal-calories'),
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Calories',
                    suffixText: 'kcal',
                    prefixIcon: Icon(Icons.local_fire_department_outlined),
                  ),
                  validator: (value) => validateNutritionAmount(
                    value,
                    label: 'calories',
                    max: maxCalories,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('meal-protein'),
                  controller: _proteinController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Protein',
                    suffixText: 'g',
                  ),
                  validator: (value) => validateNutritionAmount(
                    value,
                    label: 'protein',
                    max: maxMacroGrams,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('meal-carbs'),
                  controller: _carbsController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Carbohydrates',
                    suffixText: 'g',
                  ),
                  validator: (value) => validateNutritionAmount(
                    value,
                    label: 'carbohydrates',
                    max: maxMacroGrams,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('meal-fat'),
                  controller: _fatController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _save(),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Fat',
                    suffixText: 'g',
                  ),
                  validator: (value) => validateNutritionAmount(
                    value,
                    label: 'fat',
                    max: maxMacroGrams,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  key: const Key('save-meal-button'),
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                  label: const Text('Save meal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

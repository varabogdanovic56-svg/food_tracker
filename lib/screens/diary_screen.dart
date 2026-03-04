import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../providers/providers.dart';

class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key});

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen> {
  MealType? _selectedMealType;

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final reportAsync = ref.watch(currentDayReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('d MMMM yyyy').format(selectedDate)),
      ),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (report) => Column(
          children: [
            _buildMealTabs(report),
            Expanded(child: _buildMealContent(report)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add-food'),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }

  Widget _buildMealTabs(DailyReport report) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: MealType.values.map((type) {
            final meal = report.meals
                .where((m) => m.mealType == type)
                .firstOrNull;
            final isSelected = _selectedMealType == type;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(type.displayName),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedMealType = type),
                avatar: meal != null
                    ? CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          meal.totalCalories.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMealContent(DailyReport report) {
    final mealType = _selectedMealType ?? MealType.breakfast;
    final meal = report.meals.where((m) => m.mealType == mealType).firstOrNull;

    if (meal == null || meal.entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Нет продуктов',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Добавьте продукты в этот приём пищи',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMealSummary(meal),
        const SizedBox(height: 16),
        ...meal.entries.map((entry) => _buildEntryTile(entry)),
      ],
    );
  }

  Widget _buildMealSummary(Meal meal) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Итого',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${meal.totalCalories.toStringAsFixed(0)} ккал',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroItem('Белки', meal.totalProtein, 'г'),
                _buildMacroItem('Углеводы', meal.totalCarbs, 'г'),
                _buildMacroItem('Жиры', meal.totalFat, 'г'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroItem(String label, double value, String unit) {
    return Column(
      children: [
        Text(
          '${value.toStringAsFixed(1)}$unit',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildEntryTile(MealEntry entry) {
    return Dismissible(
      key: Key('entry_${entry.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        await ref.read(foodServiceProvider).deleteMealEntry(entry.id);
        ref.invalidate(currentDayReportProvider);
      },
      child: Card(
        child: ListTile(
          title: Text(entry.productName),
          subtitle: Text('${entry.grams.toStringAsFixed(0)}г'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.calories.toStringAsFixed(0)} ккал',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Б:${entry.protein.toStringAsFixed(1)} У:${entry.carbs.toStringAsFixed(1)} Ж:${entry.fat.toStringAsFixed(1)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

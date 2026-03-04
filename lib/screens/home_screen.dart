import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/common_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(currentDayReportProvider);
    final goals = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Tracker'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Ошибка: $e')),
        data: (report) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(context, ref),
              const SizedBox(height: 24),
              Center(
                child: CaloriesRing(
                  current: report.totalCalories,
                  goal: report.caloriesGoal,
                ),
              ),
              const SizedBox(height: 24),
              MacroProgressBar(
                label: 'Белки',
                current: report.totalProtein,
                goal: report.proteinGoal,
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              MacroProgressBar(
                label: 'Углеводы',
                current: report.totalCarbs,
                goal: report.carbsGoal,
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              MacroProgressBar(
                label: 'Жиры',
                current: report.totalFat,
                goal: report.fatGoal,
                color: Colors.yellow[700]!,
              ),
              const SizedBox(height: 24),
              if (report.waterSummary != null)
                WaterProgress(
                  current: report.waterSummary!.totalMl,
                  goal: report.waterSummary!.goalMl,
                ),
              const SizedBox(height: 24),
              _buildQuickActions(context, ref),
              const SizedBox(height: 24),
              _buildMealsSummary(context, report),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            ref.read(selectedDateProvider.notifier).state = selectedDate
                .subtract(const Duration(days: 1));
          },
        ),
        GestureDetector(
          onTap: () => _selectDate(context, ref),
          child: Column(
            children: [
              Text(
                isToday ? 'Сегодня' : DateFormat('EEEE').format(selectedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('d MMMM yyyy').format(selectedDate),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: isToday
              ? null
              : () {
                  ref.read(selectedDateProvider.notifier).state = selectedDate
                      .add(const Duration(days: 1));
                },
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    final date = await showDatePicker(
      context: context,
      initialDate: ref.read(selectedDateProvider),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      ref.read(selectedDateProvider.notifier).state = date;
    }
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Быстрые действия',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            QuickAddButton(
              icon: Icons.water_drop,
              label: '+200мл',
              color: Colors.blue,
              onTap: () => _addWater(ref, 200),
            ),
            QuickAddButton(
              icon: Icons.water_drop,
              label: '+500мл',
              color: Colors.blue,
              onTap: () => _addWater(ref, 500),
            ),
            QuickAddButton(
              icon: Icons.restaurant,
              label: 'Добавить еду',
              onTap: () => Navigator.pushNamed(context, '/add-food'),
            ),
            QuickAddButton(
              icon: Icons.monitor_weight,
              label: 'Вес',
              color: Colors.purple,
              onTap: () => _showWeightDialog(context, ref),
            ),
          ],
        ),
      ],
    );
  }

  void _addWater(WidgetRef ref, int amount) async {
    final date = ref.read(selectedDateProvider);
    await ref.read(foodServiceProvider).addWaterIntake(date, amount);
    ref.invalidate(currentDayReportProvider);
  }

  void _showWeightDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить вес'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Вес (кг)',
            hintText: 'Например: 75.5',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              final weight = double.tryParse(controller.text);
              if (weight != null) {
                final date = ref.read(selectedDateProvider);
                await ref
                    .read(foodServiceProvider)
                    .addWeight(date, weight, null);
                ref.invalidate(currentDayReportProvider);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsSummary(BuildContext context, DailyReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Приёмы пищи',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/diary'),
              child: const Text('Подробнее'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...MealType.values.map((type) {
          final meal = report.meals
              .where((m) => m.mealType == type)
              .firstOrNull;
          return _buildMealTile(context, type, meal);
        }),
      ],
    );
  }

  Widget _buildMealTile(BuildContext context, MealType type, Meal? meal) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(_getMealIcon(type), color: Theme.of(context).primaryColor),
      ),
      title: Text(type.displayName),
      subtitle: Text(
        meal != null ? '${meal.entries.length} продуктов' : 'Нет данных',
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: Text(
        meal != null ? '${meal.totalCalories.toStringAsFixed(0)} ккал' : '-',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      onTap: () => Navigator.pushNamed(context, '/diary', arguments: type),
    );
  }

  IconData _getMealIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.free_breakfast;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.cookie;
    }
  }
}

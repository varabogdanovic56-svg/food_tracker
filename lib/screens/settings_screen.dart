import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Цели питания',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildGoalItem(
            context,
            ref,
            'Калории в день',
            goals.caloriesPerDay,
            'ккал',
            (value) => ref.read(goalsProvider.notifier).updateCalories(value),
          ),
          _buildGoalItem(
            context,
            ref,
            'Белки в день',
            goals.proteinPerDay,
            'г',
            (value) => ref.read(goalsProvider.notifier).updateProtein(value),
          ),
          _buildGoalItem(
            context,
            ref,
            'Углеводы в день',
            goals.carbsPerDay,
            'г',
            (value) => ref.read(goalsProvider.notifier).updateCarbs(value),
          ),
          _buildGoalItem(
            context,
            ref,
            'Жиры в день',
            goals.fatPerDay,
            'г',
            (value) => ref.read(goalsProvider.notifier).updateFat(value),
          ),
          _buildGoalItem(
            context,
            ref,
            'Вода в день',
            goals.waterPerDayMl.toDouble(),
            'мл',
            (value) =>
                ref.read(goalsProvider.notifier).updateWater(value.toInt()),
            isInt: true,
          ),
          const SizedBox(height: 32),
          const Text(
            'О приложении',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Food Tracker'),
              subtitle: const Text('Версия 1.0.0'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(
    BuildContext context,
    WidgetRef ref,
    String label,
    double value,
    String unit,
    Function(double) onChanged, {
    bool isInt = false,
  }) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isInt ? value.toInt() : value.toStringAsFixed(0)} $unit',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditDialog(
                context,
                ref,
                label,
                value,
                unit,
                onChanged,
                isInt: isInt,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    String label,
    double currentValue,
    String unit,
    Function(double) onChanged, {
    bool isInt = false,
  }) {
    final controller = TextEditingController(
      text: isInt
          ? currentValue.toInt().toString()
          : currentValue.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Изменить $label'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: !isInt),
          decoration: InputDecoration(labelText: label, suffixText: unit),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final value = isInt
                  ? int.tryParse(controller.text)?.toDouble()
                  : double.tryParse(controller.text);
              if (value != null && value > 0) {
                onChanged(value);
              }
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}

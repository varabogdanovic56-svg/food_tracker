import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/providers.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key});

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> {
  String _searchQuery = '';
  Product? _selectedProduct;
  final _gramsController = TextEditingController(text: '100');
  MealType _selectedMealType = MealType.breakfast;

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить еду')),
      body: _selectedProduct == null
          ? _buildProductSearch()
          : _buildAmountInput(),
    );
  }

  Widget _buildProductSearch() {
    final productsAsync = ref.watch(productSearchProvider(_searchQuery));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Поиск продукта...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        Expanded(
          child: productsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Ошибка: $e')),
            data: (products) => ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(
                    '${product.caloriesPer100g.toStringAsFixed(0)} ккал на 100г',
                  ),
                  onTap: () => setState(() {
                    _selectedProduct = product;
                    _gramsController.text = product.defaultGrams.toString();
                  }),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    final grams = double.tryParse(_gramsController.text) ?? 0;
    final multiplier = grams / 100;
    final calories = _selectedProduct!.caloriesPer100g * multiplier;
    final protein = _selectedProduct!.proteinPer100g * multiplier;
    final carbs = _selectedProduct!.carbsPer100g * multiplier;
    final fat = _selectedProduct!.fatPer100g * multiplier;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: ListTile(
              title: Text(
                _selectedProduct!.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${_selectedProduct!.caloriesPer100g.toStringAsFixed(0)} ккал на 100г',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selectedProduct = null),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Приём пищи',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: MealType.values.map((type) {
              return ChoiceChip(
                label: Text(type.displayName),
                selected: _selectedMealType == type,
                onSelected: (_) => setState(() => _selectedMealType = type),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _gramsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Количество (грамм)',
              suffixText: 'г',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Пищевая ценность',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildNutrientRow(
                    'Калории',
                    '${calories.toStringAsFixed(0)} ккал',
                  ),
                  _buildNutrientRow('Белки', '${protein.toStringAsFixed(1)} г'),
                  _buildNutrientRow(
                    'Углеводы',
                    '${carbs.toStringAsFixed(1)} г',
                  ),
                  _buildNutrientRow('Жиры', '${fat.toStringAsFixed(1)} г'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addFood,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Добавить'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _addFood() async {
    if (_selectedProduct == null) return;

    final grams = double.tryParse(_gramsController.text) ?? 0;
    if (grams <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите количество')));
      return;
    }

    final date = ref.read(selectedDateProvider);
    final meal = await ref
        .read(foodServiceProvider)
        .getOrCreateMeal(date, _selectedMealType);
    await ref
        .read(foodServiceProvider)
        .addMealEntry(meal.id, _selectedProduct!, grams);
    ref.invalidate(currentDayReportProvider);

    if (mounted) Navigator.pop(context);
  }
}

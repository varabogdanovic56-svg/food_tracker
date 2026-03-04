import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/providers.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productSearchProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Продукты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddProductDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Поиск продуктов...',
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
                  return _buildProductTile(product);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile(Product product) {
    return Card(
      child: ListTile(
        title: Text(product.name),
        subtitle: Text(
          '${product.caloriesPer100g.toStringAsFixed(0)} ккал | '
          'Б:${product.proteinPer100g.toStringAsFixed(1)} '
          'У:${product.carbsPer100g.toStringAsFixed(1)} '
          'Ж:${product.fatPer100g.toStringAsFixed(1)}',
        ),
        trailing: product.isCustom
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteProduct(product),
              )
            : null,
        onTap: () => _showProductDetails(product),
      ),
    );
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('На 100г:', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            _buildMacroRow(
              'Калории',
              '${product.caloriesPer100g.toStringAsFixed(0)} ккал',
            ),
            _buildMacroRow(
              'Белки',
              '${product.proteinPer100g.toStringAsFixed(1)} г',
            ),
            _buildMacroRow(
              'Углеводы',
              '${product.carbsPer100g.toStringAsFixed(1)} г',
            ),
            _buildMacroRow(
              'Жиры',
              '${product.fatPer100g.toStringAsFixed(1)} г',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow(String label, String value) {
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

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить продукт'),
        content: Text('Вы уверены, что хотите удалить "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              // Delete product logic here
              Navigator.pop(context);
              ref.invalidate(productsProvider);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final calController = TextEditingController();
    final protController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить продукт'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Название'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: calController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Калории на 100г'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: protController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Белки на 100г'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: carbsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Углеводы на 100г',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: fatController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Жиры на 100г'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              final product = Product(
                id: 0,
                name: nameController.text,
                caloriesPer100g: double.tryParse(calController.text) ?? 0,
                proteinPer100g: double.tryParse(protController.text) ?? 0,
                carbsPer100g: double.tryParse(carbsController.text) ?? 0,
                fatPer100g: double.tryParse(fatController.text) ?? 0,
                createdAt: DateTime.now(),
              );
              await ref.read(foodServiceProvider).insertProduct(product);
              ref.invalidate(productsProvider);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }
}

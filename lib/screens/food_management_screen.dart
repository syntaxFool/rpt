import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_panda_tracker/models/index.dart';
import 'package:red_panda_tracker/providers/food_provider.dart';
import 'package:red_panda_tracker/services/sheet_api.dart';
import 'package:red_panda_tracker/widgets/edit_food_sheet.dart';
import 'package:red_panda_tracker/widgets/add_food_sheet.dart';

class FoodManagementScreen extends StatelessWidget {
  const FoodManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Food Pantry'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<FoodProvider>(
        builder: (context, foodProvider, child) {
          final foods = foodProvider.foods;

          if (foods.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '🍱',
                    style: TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your pantry is empty',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF4A342E),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first custom food\nusing Chef\'s Creation',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF4A342E).withValues(alpha: 0.7),
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddFoodSheet(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Food'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF27D52),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header with count
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${foods.length} food${foods.length == 1 ? '' : 's'} in your pantry',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF4A342E).withValues(alpha: 0.7),
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      color: const Color(0xFFF27D52),
                      iconSize: 32,
                      onPressed: () => _showAddFoodSheet(context),
                      tooltip: 'Create new food',
                    ),
                    foodProvider.isSyncing
                        ? const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.sync),
                            color: const Color(0xFF4A342E),
                            tooltip: 'Sync pantry',
                            onPressed: () => _syncPantry(context),
                          ),
                  ],
                ),
              ),

              // Food list
              Expanded(
                child: ListView.builder(
                  itemCount: foods.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final food = foods[index];
                    return _FoodCard(food: food);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddFoodSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddFoodSheet(),
    );
  }

  Future<void> _syncPantry(BuildContext context) async {
    final response = await SheetApi().fetchAll();
    if (response == null) return;
    final data = response['data'] as Map<String, dynamic>? ?? response;
    final updated = await context.read<FoodProvider>().refreshFromSheets(data);
    if (!context.mounted) return;

    final message = updated > 0
        ? 'Pulled $updated food${updated == 1 ? '' : 's'} from Sheets'
        : 'Pantry already up to date';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _FoodCard extends StatelessWidget {
  final FoodAsset food;

  const _FoodCard({required this.food});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showEditSheet(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Text(
                    '🍱',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      food.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A342E),
                      ),
                    ),
                  ),
                  // Action buttons
                  IconButton(
                    icon: const Icon(Icons.edit),
                    color: const Color(0xFFF27D52),
                    onPressed: () => _showEditSheet(context),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red.shade400,
                    onPressed: () => _confirmDelete(context),
                    tooltip: 'Delete',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Macros per 100g
              Text(
                'Per 100g',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF4A342E).withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildMacroBadge(
                    '🔥 ${food.caloriesPer100g.toStringAsFixed(0)} kcal',
                    Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _buildMacroBadge(
                    'P ${food.proteinPer100g.toStringAsFixed(1)}g',
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildMacroBadge(
                    'C ${food.carbsPer100g.toStringAsFixed(1)}g',
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildMacroBadge(
                    'F ${food.fatPer100g.toStringAsFixed(1)}g',
                    Colors.amber.shade700,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditFoodSheet(food: food),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Food?'),
        content: Text(
          'Are you sure you want to delete "${food.name}" from your pantry?\n\nThis action cannot be undone.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<FoodProvider>(context, listen: false)
                  .deleteFood(food.name);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted ${food.name}'),
                  duration: const Duration(seconds: 4),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

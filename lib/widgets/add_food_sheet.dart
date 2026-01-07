import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_panda_tracker/models/food_asset.dart';
import 'package:red_panda_tracker/providers/food_provider.dart';

class AddFoodSheet extends StatefulWidget {
  const AddFoodSheet({super.key});

  @override
  State<AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<AddFoodSheet> {
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _saveFoodAsset() async {
    // Validate inputs
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a food name'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    // Parse numeric values
    final calories = double.tryParse(_caloriesController.text) ?? 0.0;
    final protein = double.tryParse(_proteinController.text) ?? 0.0;
    final carbs = double.tryParse(_carbsController.text) ?? 0.0;
    final fat = double.tryParse(_fatController.text) ?? 0.0;

    if (calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calories must be greater than 0'),
          backgroundColor: Color(0xFFE53935),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final foodAsset = FoodAsset(
        name: name,
        caloriesPer100g: calories,
        emoji: '🍱', // Chef's Creation emoji
        proteinPer100g: protein,
        carbsPer100g: carbs,
        fatPer100g: fat,
      );

      // Add to food provider
      final foodProvider = Provider.of<FoodProvider>(context, listen: false);
      await foodProvider.addFood(foodAsset);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $name to your pantry! 🐼'),
            backgroundColor: const Color(0xFFF27D52),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFE53935),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDF9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Create New Food 🍱',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF4A342E),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Food Name Input
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Food Name',
                  hintText: "e.g., Mom's Lasagna",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Helper text
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Enter values per 100g (Check the nutrition label!)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF4A342E).withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              // 2x2 Grid of inputs
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  // Calories (Neon Orange)
                  _buildMacroInput(
                    controller: _caloriesController,
                    label: 'Calories',
                    unit: 'kcal',
                    color: const Color(0xFFF27D52),
                  ),
                  // Protein
                  _buildMacroInput(
                    controller: _proteinController,
                    label: 'Protein',
                    unit: 'g',
                    color: const Color(0xFF6366F1),
                    shortLabel: 'Protein',
                  ),
                  // Carbs
                  _buildMacroInput(
                    controller: _carbsController,
                    label: 'Carbs',
                    unit: 'g',
                    color: const Color(0xFF10B981),
                    shortLabel: 'Carbs',
                  ),
                  // Fat
                  _buildMacroInput(
                    controller: _fatController,
                    label: 'Fat',
                    unit: 'g',
                    color: const Color(0xFFF59E0B),
                    shortLabel: 'Fat',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveFoodAsset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF27D52),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save to Pantry',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroInput({
    required TextEditingController controller,
    required String label,
    required String unit,
    required Color color,
    String? shortLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              if (shortLabel != null)
                Text(
                  shortLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                )
              else
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            suffix: Text(
              unit,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF4A342E).withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

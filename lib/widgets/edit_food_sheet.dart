import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:red_panda_tracker/models/index.dart';
import 'package:red_panda_tracker/providers/food_provider.dart';

/// Convert text to proper case (first letter of each word capitalized)
String _toProperCase(String text) {
  if (text.isEmpty) return text;
  return text.trim().split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + (word.length > 1 ? word.substring(1).toLowerCase() : '');
  }).join(' ');
}

class EditFoodSheet extends StatefulWidget {
  final FoodAsset food;

  const EditFoodSheet({
    super.key,
    required this.food,
  });

  @override
  State<EditFoodSheet> createState() => _EditFoodSheetState();
}

class _EditFoodSheetState extends State<EditFoodSheet> {
  late TextEditingController _nameController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.food.name);
    _caloriesController = TextEditingController(
      text: widget.food.caloriesPer100g.toStringAsFixed(0),
    );
    _proteinController = TextEditingController(
      text: widget.food.proteinPer100g.toStringAsFixed(1),
    );
    _carbsController = TextEditingController(
      text: widget.food.carbsPer100g.toStringAsFixed(1),
    );
    _fatController = TextEditingController(
      text: widget.food.fatPer100g.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _saveFood() async {
    final name = _toProperCase(_nameController.text.trim());
    final calories = double.tryParse(_caloriesController.text) ?? 0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a food name'), duration: Duration(seconds: 3)),
      );
      return;
    }

    if (calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calories must be greater than 0'), duration: Duration(seconds: 3)),
      );
      return;
    }

    final protein = double.tryParse(_proteinController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;
    final fat = double.tryParse(_fatController.text) ?? 0;

    final updatedFood = FoodAsset(
      name: name,
      caloriesPer100g: calories,
      emoji: widget.food.emoji,
      proteinPer100g: protein,
      carbsPer100g: carbs,
      fatPer100g: fat,
    );

    setState(() => _isSaving = true);

    try {
      await Provider.of<FoodProvider>(context, listen: false)
          .updateFood(widget.food.name, updatedFood);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated $name 🐼')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving $name: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDF9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                '🍱',
                style: TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Edit Food',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4A342E),
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Update nutritional values per 100g',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4A342E).withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 24),

          // Food Name
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Food Name',
              prefixIcon: const Icon(Icons.restaurant_menu),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          // 2x2 Grid for macros
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              // Calories
              _buildMacroField(
                controller: _caloriesController,
                label: 'Calories',
                suffix: 'kcal',
                icon: Icons.local_fire_department,
                color: Colors.orange,
              ),
              // Protein
              _buildMacroField(
                controller: _proteinController,
                label: 'Protein',
                suffix: 'g',
                icon: Icons.fitness_center,
                color: Colors.blue,
              ),
              // Carbs
              _buildMacroField(
                controller: _carbsController,
                label: 'Carbs',
                suffix: 'g',
                icon: Icons.grain,
                color: Colors.green,
              ),
              // Fat
              _buildMacroField(
                controller: _fatController,
                label: 'Fat',
                suffix: 'g',
                icon: Icons.water_drop,
                color: Colors.amber.shade700,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveFood,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF27D52),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A342E),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
              suffix: Text(
                suffix,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF4A342E).withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

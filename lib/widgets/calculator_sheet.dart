import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:red_panda_tracker/models/index.dart';
import 'package:red_panda_tracker/providers/index.dart';
import 'package:red_panda_tracker/widgets/add_food_sheet.dart';

class CalculatorSheet extends StatefulWidget {
  const CalculatorSheet({super.key});

  @override
  State<CalculatorSheet> createState() => _CalculatorSheetState();
}

class _CalculatorSheetState extends State<CalculatorSheet> {
  late TextEditingController _gramsController;
  FoodAsset? _selectedFood;
  double _calculatedCalories = 0;
  double _calculatedProtein = 0;
  double _calculatedCarbs = 0;
  double _calculatedFat = 0;
  String _selectedCategory = 'Other';
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _gramsController = TextEditingController();
    _gramsController.addListener(_calculateMacros);
  }

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  void _calculateMacros() {
    if (_selectedFood != null) {
      // Default to 100g if no input
      final grams = double.tryParse(_gramsController.text) ?? 100.0;
      
      setState(() {
        _calculatedCalories = _selectedFood!.calculateCalories(grams);
        _calculatedProtein = _selectedFood!.calculateProtein(grams);
        _calculatedCarbs = _selectedFood!.calculateCarbs(grams);
        _calculatedFat = _selectedFood!.calculateFat(grams);
      });
    } else {
      setState(() {
        _calculatedCalories = 0;
        _calculatedProtein = 0;
        _calculatedCarbs = 0;
        _calculatedFat = 0;
      });
    }
  }

  void _addEntry(BuildContext context) {
    if (_selectedFood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a food')),
      );
      return;
    }

    // Default to 100g if empty
    final grams = double.tryParse(_gramsController.text) ?? 100.0;

    final log = LogEntry(
      id: _uuid.v4(),
      foodName: _selectedFood!.name,
      foodEmoji: _selectedFood!.emoji,
      grams: grams,
      calories: _calculatedCalories,
      mealCategory: _selectedCategory,
    );

    Provider.of<LogProvider>(context, listen: false).addLog(log);
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedFood!.emoji} ${_selectedFood!.name} logged!'),
        backgroundColor: const Color(0xFFF27D52),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            Provider.of<LogProvider>(context, listen: false).deleteLog(log.id);
          },
        ),
      ),
    );
  }

  void _openAddFoodSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddFoodSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Text(
              'Smart Feeder 🍽️',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF4A342E),
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Meal Category Selector
            Row(
              children: [
                const Text(
                  'Meal: ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A342E),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Breakfast', label: Text('🌅'), tooltip: 'Breakfast'),
                      ButtonSegment(value: 'Lunch', label: Text('☀️'), tooltip: 'Lunch'),
                      ButtonSegment(value: 'Dinner', label: Text('🌙'), tooltip: 'Dinner'),
                      ButtonSegment(value: 'Snack', label: Text('🍿'), tooltip: 'Snack'),
                    ],
                    selected: {_selectedCategory},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedCategory = newSelection.first;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return const Color(0xFFF27D52);
                          }
                          return Colors.white;
                        },
                      ),
                      foregroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.white;
                          }
                          return const Color(0xFF4A342E);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Foods Section
            Consumer<LogProvider>(
              builder: (context, logProvider, _) {
                final recentLogs = logProvider.logs
                    .where((log) => log.timestamp.isAfter(
                        DateTime.now().subtract(const Duration(days: 3))))
                    .toList();
                
                // Group by food name and count occurrences
                final foodCount = <String, int>{};
                final foodData = <String, Map<String, dynamic>>{};
                
                for (var log in recentLogs) {
                  foodCount[log.foodName] = (foodCount[log.foodName] ?? 0) + 1;
                  if (!foodData.containsKey(log.foodName)) {
                    foodData[log.foodName] = {
                      'emoji': log.foodEmoji,
                      'grams': log.grams,
                    };
                  }
                }
                
                // Sort by count and take top 5
                final sortedFoods = foodCount.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                final topFoods = sortedFoods.take(5).toList();
                
                if (topFoods.isEmpty) {
                  return const SizedBox.shrink();
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Foods',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A342E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: topFoods.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final entry = topFoods[index];
                          final foodName = entry.key;
                          final data = foodData[foodName]!;
                          
                          return Consumer<FoodProvider>(
                            builder: (context, foodProvider, _) {
                              final food = foodProvider.foods.firstWhere(
                                (f) => f.name == foodName,
                                orElse: () => foodProvider.foods.first,
                              );
                              
                              return ActionChip(
                                avatar: Text(data['emoji'] ?? '🍽️'),
                                label: Text(foodName),
                                onPressed: () {
                                  setState(() {
                                    _selectedFood = food;
                                    _gramsController.text = data['grams'].toString();
                                    _calculateMacros();
                                  });
                                },
                                backgroundColor: Colors.grey.shade100,
                                side: BorderSide.none,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),

            // Food Autocomplete with Create New Button
            Consumer<FoodProvider>(
              builder: (context, foodProvider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Autocomplete<FoodAsset>(
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return foodProvider.foods;
                        }
                        return foodProvider.searchFoods(textEditingValue.text);
                      },
                      displayStringForOption: (food) => '${food.emoji} ${food.name}',
                      onSelected: (food) {
                        setState(() {
                          _selectedFood = food;
                          _calculateMacros();
                        });
                      },
                      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'Select Food',
                            hintText: 'Type to search...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _openAddFoodSheet,
                      icon: const Icon(Icons.add),
                      label: const Text('Create New Food'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFF27D52),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Grams Input
            TextField(
              controller: _gramsController,
              keyboardType: TextInputType.number,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: const Color(0xFFF27D52),
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'Grams',
                hintText: '100',
                suffixText: 'g',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                filled: true,
                fillColor: const Color(0xFFFFFDF9),
              ),
            ),
            const SizedBox(height: 24),

            // Macro Display
            if (_selectedFood != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calories (main display)
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '🔥 ${_calculatedCalories.toStringAsFixed(0)} kcal',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFFF27D52),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Macro breakdown
                        Text(
                          'P: ${_calculatedProtein.toStringAsFixed(1)}g | C: ${_calculatedCarbs.toStringAsFixed(1)}g | F: ${_calculatedFat.toStringAsFixed(1)}g',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF4A342E).withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // Add Button
            ElevatedButton(
              onPressed: () => _addEntry(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF27D52),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: const Text(
                'Add to Log',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

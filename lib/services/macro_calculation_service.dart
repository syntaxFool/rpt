import 'package:red_panda_tracker/models/index.dart';

/// Service for calculating nutritional macros from log entries
/// Decouples LogProvider from direct FoodProvider dependency
class MacroCalculationService {
  /// Calculate macros for a list of log entries
  /// foodLookup should be a function that takes a food name and returns the FoodAsset
  static Map<String, double> calculateMacros(
    List<LogEntry> logs,
    FoodAsset? Function(String) foodLookup,
  ) {
    double protein = 0.0;
    double carbs = 0.0;
    double fat = 0.0;

    for (final log in logs) {
      final food = foodLookup(log.foodName);
      if (food != null) {
        protein += food.calculateProtein(log.grams);
        carbs += food.calculateCarbs(log.grams);
        fat += food.calculateFat(log.grams);
      }
    }

    return {
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  /// Calculate total calories from macros using standard conversion
  /// Protein: 4 cal/g, Carbs: 4 cal/g, Fat: 9 cal/g
  static double calculateCaloriesFromMacros(Map<String, double> macros) {
    final protein = macros['protein'] ?? 0.0;
    final carbs = macros['carbs'] ?? 0.0;
    final fat = macros['fat'] ?? 0.0;
    
    return (protein * 4) + (carbs * 4) + (fat * 9);
  }
}

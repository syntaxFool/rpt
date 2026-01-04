import 'package:hive/hive.dart';

part 'food_asset.g.dart';

@HiveType(typeId: 10)
class FoodAsset extends HiveObject {
  @HiveField(0)
  String name; // e.g., "Rice", "Chicken Breast"

  @HiveField(1)
  double caloriesPer100g; // Calories per 100 grams

  @HiveField(2)
  String emoji; // Visual identifier

  @HiveField(3)
  double proteinPer100g; // Protein in grams per 100g

  @HiveField(4)
  double carbsPer100g; // Carbs in grams per 100g

  @HiveField(5)
  double fatPer100g; // Fat in grams per 100g

  FoodAsset({
    required this.name,
    required this.caloriesPer100g,
    required this.emoji,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
  });

  /// Calculate calories for a given weight in grams
  double calculateCalories(double grams) {
    return (grams / 100) * caloriesPer100g;
  }

  /// Calculate protein for a given weight in grams
  double calculateProtein(double grams) {
    return (grams / 100) * proteinPer100g;
  }

  /// Calculate carbs for a given weight in grams
  double calculateCarbs(double grams) {
    return (grams / 100) * carbsPer100g;
  }

  /// Calculate fat for a given weight in grams
  double calculateFat(double grams) {
    return (grams / 100) * fatPer100g;
  }

  @override
  String toString() => '$emoji $name ($caloriesPer100g cal/100g)';
}

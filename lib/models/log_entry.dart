import 'package:hive/hive.dart';

part 'log_entry.g.dart';

@HiveType(typeId: 11)
class LogEntry extends HiveObject {
  @HiveField(0)
  String id; // Unique identifier

  @HiveField(1)
  String foodName; // Name of the food

  @HiveField(2)
  String foodEmoji; // Emoji for display

  @HiveField(3)
  double grams; // Amount in grams

  @HiveField(4)
  double calories; // Calculated calories

  @HiveField(5)
  DateTime timestamp; // When logged

  @HiveField(6)
  bool synced; // Whether synced to server

  @HiveField(7)
  String mealCategory; // Breakfast, Lunch, Dinner, Snack

  LogEntry({
    required this.id,
    required this.foodName,
    required this.foodEmoji,
    required this.grams,
    required this.calories,
    DateTime? timestamp,
    this.synced = false,
    this.mealCategory = 'Other',
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create a copy with updated fields
  LogEntry copyWith({
    String? id,
    String? foodName,
    String? foodEmoji,
    double? grams,
    double? calories,
    DateTime? timestamp,
    bool? synced,
    String? mealCategory,
  }) {
    return LogEntry(
      id: id ?? this.id,
      foodName: foodName ?? this.foodName,
      foodEmoji: foodEmoji ?? this.foodEmoji,
      grams: grams ?? this.grams,
      calories: calories ?? this.calories,
      timestamp: timestamp ?? this.timestamp,
      synced: synced ?? this.synced,
      mealCategory: mealCategory ?? this.mealCategory,
    );
  }

  @override
  String toString() => '$foodEmoji $foodName: ${grams}g = ${calories.toStringAsFixed(0)} kcal';
}

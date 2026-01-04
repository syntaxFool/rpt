import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:red_panda_tracker/models/index.dart';
import 'package:red_panda_tracker/services/index.dart';

/// Provider for managing Food database
class FoodProvider extends ChangeNotifier {
  late Box<FoodAsset> _foodBox;
  List<FoodAsset> _foods = [];

  FoodProvider() {
    _foodBox = HiveService.getFoodBox();
    _loadFoods();
  }

  /// Get all foods
  List<FoodAsset> get foods => _foods;

  /// Load all foods from Hive
  void _loadFoods() {
    _foods = _foodBox.values.toList();
    notifyListeners();
  }

  /// Get a specific food by name
  FoodAsset? getFoodByName(String name) {
    try {
      return _foods.firstWhere((f) => f.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  /// Add a new food
  Future<void> addFood(FoodAsset food) async {
    try {
      await _foodBox.put(food.name, food);
      _loadFoods();
    } catch (e) {
      rethrow;
    }
  }

  /// Search foods by name
  List<FoodAsset> searchFoods(String query) {
    if (query.isEmpty) return _foods;
    return _foods
        .where((f) => f.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Update an existing food
  Future<void> updateFood(String oldName, FoodAsset updatedFood) async {
    try {
      // Delete old entry if name changed
      if (oldName != updatedFood.name) {
        await _foodBox.delete(oldName);
      }
      await _foodBox.put(updatedFood.name, updatedFood);
      _loadFoods();
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a food
  Future<void> deleteFood(String name) async {
    try {
      await _foodBox.delete(name);
      _loadFoods();
    } catch (e) {
      rethrow;
    }
  }
}

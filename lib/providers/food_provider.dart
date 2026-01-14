import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:red_panda_tracker/models/index.dart';
import 'package:red_panda_tracker/services/index.dart';

/// Provider for managing Food database
class FoodProvider extends ChangeNotifier {
  late Box<FoodAsset> _foodBox;
  final SheetApi _sheetApi = SheetApi();
  List<FoodAsset> _foods = [];
  bool _isSyncing = false;
  bool _initialSyncFailed = false;

  FoodProvider() {
    _foodBox = HiveService.getFoodBox();
    _loadFoods();
    // Pull any remote pantry items shortly after startup
    _refreshFromSheetsInitial().catchError((e) {
      print('FoodProvider: Initial sync failed: $e');
      _initialSyncFailed = true;
      notifyListeners();
      // Continue with local data
    });
  }

  /// Initial sync that fetches data from API
  Future<int> _refreshFromSheetsInitial() async {
    final response = await _sheetApi.fetchAll();
    if (response == null) return 0;
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return refreshFromSheets(data);
  }

  /// Get all foods
  List<FoodAsset> get foods => _foods;

  /// Whether a sync is in progress
  bool get isSyncing => _isSyncing;
  
  /// Whether the initial sync failed (indicates offline/backend issues)
  bool get initialSyncFailed => _initialSyncFailed;

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
      await _sheetApi.upsertFood(food);
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
      if (oldName != updatedFood.name) {
        await _sheetApi.deleteFood(oldName);
      }
      await _sheetApi.upsertFood(updatedFood);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a food
  Future<void> deleteFood(String name) async {
    try {
      await _foodBox.delete(name);
      _loadFoods();
      await _sheetApi.deleteFood(name);
    } catch (e) {
      rethrow;
    }
  }

  /// Pull foods from the Apps Script backend and merge into Hive
  Future<int> refreshFromSheets(Map<String, dynamic> data) async {
    if (_isSyncing) return 0;

    _isSyncing = true;
    notifyListeners();

    try {
      final remoteFoods = (data['foods'] as List?) ?? [];
      if (remoteFoods.isEmpty) {
        return 0;
      }

      // Merge remote foods into local map keyed by name
      final merged = <String, FoodAsset>{
        for (final food in _foods) food.name: food,
      };

      int updatedCount = 0;
      for (final entry in remoteFoods) {
        final name = (entry['name'] ?? '').toString().trim();
        if (name.isEmpty) continue;

        final candidate = FoodAsset(
          name: name,
          emoji: (entry['emoji'] ?? '🍱').toString(),
          caloriesPer100g: _asDouble(entry['caloriesPer100g']),
          proteinPer100g: _asDouble(entry['proteinPer100g']),
          carbsPer100g: _asDouble(entry['carbsPer100g']),
          fatPer100g: _asDouble(entry['fatPer100g']),
        );

        final existing = merged[name];
        if (existing == null || !_foodsEqual(existing, candidate)) {
          merged[name] = candidate;
          updatedCount++;
        }
      }

      await _foodBox.clear();
      await _foodBox.putAll(merged);
      _loadFoods();

      return updatedCount;
    } catch (_) {
      return 0;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  bool _foodsEqual(FoodAsset a, FoodAsset b) {
    return a.caloriesPer100g == b.caloriesPer100g &&
        a.proteinPer100g == b.proteinPer100g &&
        a.carbsPer100g == b.carbsPer100g &&
        a.fatPer100g == b.fatPer100g &&
        a.emoji == b.emoji &&
        a.name.toLowerCase() == b.name.toLowerCase();
  }
}

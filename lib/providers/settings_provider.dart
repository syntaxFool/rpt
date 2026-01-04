import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:red_panda_tracker/models/index.dart';
import 'package:red_panda_tracker/services/index.dart';

/// Provider for managing app settings
class SettingsProvider extends ChangeNotifier {
  late Box<AppSettings> _settingsBox;
  AppSettings _settings = AppSettings();

  SettingsProvider() {
    _settingsBox = HiveService.getSettingsBox();
    _loadSettings();
  }

  /// Get current settings
  AppSettings get settings => _settings;

  /// Load settings from Hive
  void _loadSettings() {
    final saved = _settingsBox.get('app_settings');
    if (saved != null) {
      _settings = saved;
    } else {
      // Save default settings
      _saveSettings();
    }
    notifyListeners();
  }

  /// Save settings to Hive
  Future<void> _saveSettings() async {
    try {
      await _settingsBox.put('app_settings', _settings);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Update daily calorie target
  Future<void> updateDailyCalorieTarget(double value) async {
    _settings = _settings.copyWith(dailyCalorieTarget: value);
    await _saveSettings();
  }

  /// Update protein target
  Future<void> updateProteinTarget(double value) async {
    _settings = _settings.copyWith(proteinTarget: value);
    await _saveSettings();
  }

  /// Update carbs target
  Future<void> updateCarbsTarget(double value) async {
    _settings = _settings.copyWith(carbsTarget: value);
    await _saveSettings();
  }

  /// Update fat target
  Future<void> updateFatTarget(double value) async {
    _settings = _settings.copyWith(fatTarget: value);
    await _saveSettings();
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:red_panda_tracker/models/index.dart';
import 'package:red_panda_tracker/services/index.dart';

typedef SettingsConflictResolver = Future<bool> Function(
  AppSettings local,
  AppSettings remote,
);

/// Provider for managing app settings
class SettingsProvider extends ChangeNotifier {
  late Box<AppSettings> _settingsBox;
  AppSettings _settings = AppSettings();
  final SheetApi _sheetApi = SheetApi();
  bool _isSyncing = false;
  bool _initialSyncFailed = false;

  SettingsProvider() {
    _settingsBox = HiveService.getSettingsBox();
    _loadSettings();
  }

  /// Get current settings
  AppSettings get settings => _settings;

  bool get isSyncing => _isSyncing;
  
  /// Whether the initial sync failed (indicates offline/backend issues)
  bool get initialSyncFailed => _initialSyncFailed;

  /// Load settings from Hive
  void _loadSettings() {
    final saved = _settingsBox.get('app_settings');
    if (saved != null) {
      _settings = saved;
    } else {
      // Save default settings
      // Persist defaults locally, but DO NOT push to remote here.
      _saveSettings(pushRemote: false);
    }
    notifyListeners();
  }

  /// Save settings to Hive
  Future<void> _saveSettings({bool pushRemote = false}) async {
    try {
      await _settingsBox.put('app_settings', _settings);
      if (pushRemote) {
        // Push settings to Sheets; ignore failure to preserve offline behavior
        try {
          await _sheetApi.updateSettings(_settings);
        } catch (_) {}
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Update daily calorie target
  Future<void> updateDailyCalorieTarget(double value) async {
    _settings = _settings.copyWith(dailyCalorieTarget: value);
    await _saveSettings(pushRemote: true);
  }

  /// Update protein target
  Future<void> updateProteinTarget(double value) async {
    _settings = _settings.copyWith(proteinTarget: value);
    await _saveSettings(pushRemote: true);
  }

  /// Update carbs target
  Future<void> updateCarbsTarget(double value) async {
    _settings = _settings.copyWith(carbsTarget: value);
    await _saveSettings(pushRemote: true);
  }

  /// Update fat target
  Future<void> updateFatTarget(double value) async {
    _settings = _settings.copyWith(fatTarget: value);
    await _saveSettings(pushRemote: true);
  }

  /// Pull settings from backend payload (timestamp-based merge, newest wins)
  Future<bool> refreshFromSheets(Map<String, dynamic> data) async {
    if (_isSyncing) return false;

    _isSyncing = true;
    notifyListeners();

    try {
      // If 'settings' key doesn't exist in payload, it means no settings were saved to Sheets yet
      // Do NOT push local defaults automatically; wait until user updates a setting.
      if (!data.containsKey('settings')) {
        return false;
      }

      final settingsMap = data['settings'];
      if (settingsMap == null || settingsMap is! Map) return false;

      final remoteLastModified = _asDate(settingsMap['lastModified']);
      
      final fetched = AppSettings(
        dailyCalorieTarget: _asDouble(settingsMap['dailyCalorieTarget'], fallback: _settings.dailyCalorieTarget),
        proteinTarget: _asDouble(settingsMap['proteinTarget'], fallback: _settings.proteinTarget),
        carbsTarget: _asDouble(settingsMap['carbsTarget'], fallback: _settings.carbsTarget),
        fatTarget: _asDouble(settingsMap['fatTarget'], fallback: _settings.fatTarget),
        lastModified: remoteLastModified,
      );

      final differs = !_settingsEquals(_settings, fetched);
      if (!differs) return false;

      // Timestamp-based merge: newest wins
      if (remoteLastModified != null && remoteLastModified.isAfter(_settings.lastModified)) {
        // Remote is newer - use it
        _settings = fetched;
        await _settingsBox.put('app_settings', _settings);
        notifyListeners();
        print('✓ Settings synced from cloud (remote newer)');
        return true;
      } else {
        // Local is newer or same - push to cloud
        try {
          await _sheetApi.updateSettings(_settings);
          print('✓ Settings pushed to cloud (local newer)');
        } catch (_) {}
        return false;
      }
    } catch (_) {
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  double _asDouble(dynamic value, {required double fallback}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  DateTime? _asDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  bool _settingsEquals(AppSettings a, AppSettings b) {
    return a.dailyCalorieTarget == b.dailyCalorieTarget &&
        a.proteinTarget == b.proteinTarget &&
        a.carbsTarget == b.carbsTarget &&
        a.fatTarget == b.fatTarget;
  }
}

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:red_panda_tracker/models/index.dart';
import 'package:red_panda_tracker/services/hive_service.dart';
import 'package:red_panda_tracker/services/sheet_api.dart';

/// Provider for managing Log entries
class LogProvider extends ChangeNotifier {
  late Box<LogEntry> _logBox;
  final SheetApi _sheetApi = SheetApi();
  List<LogEntry> _logs = [];
  bool _isSyncing = false;

  LogProvider() {
    _logBox = HiveService.getLogBox();
    _loadLogs();
  }

  /// Get all logs
  List<LogEntry> get logs => _logs;
  
  /// Whether sync is currently in progress
  bool get isSyncing => _isSyncing;

  /// Load all logs from Hive
  void _loadLogs() {
    _logs = _logBox.values.toList();
    _logs.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Newest first
    notifyListeners();
  }

  /// Add a new log entry
  Future<void> addLog(LogEntry log) async {
    try {
      await _logBox.put(log.id, log);
      _loadLogs();
      final sent = await _sheetApi.sendLog(log);
      if (sent) {
        await _logBox.put(log.id, log.copyWith(synced: true));
        _loadLogs();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a log entry
  Future<void> deleteLog(String id) async {
    try {
      await _logBox.delete(id);
      _loadLogs();
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing log entry
  Future<void> updateLog(LogEntry log) async {
    try {
      await _logBox.put(log.id, log);
      _loadLogs();
    } catch (e) {
      rethrow;
    }
  }

  /// Get total calories for today
  double getTodayCalories() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _logs
        .where((log) => log.timestamp.isAfter(startOfDay) && log.timestamp.isBefore(endOfDay))
        .fold(0.0, (sum, log) => sum + log.calories);
  }

  /// Get logs for today
  List<LogEntry> getTodayLogs() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _logs
        .where((log) => log.timestamp.isAfter(startOfDay) && log.timestamp.isBefore(endOfDay))
        .toList();
  }

  /// Get today's macros from FoodProvider
  Map<String, double> getTodayMacros(List<LogEntry> todayLogs, foodProvider) {
    double protein = 0.0;
    double carbs = 0.0;
    double fat = 0.0;

    for (final log in todayLogs) {
      final food = foodProvider.getFoodByName(log.foodName);
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

  /// Get unsynced logs
  List<LogEntry> getUnsyncedLogs() {
    return _logs.where((log) => !log.synced).toList();
  }

  /// Mark log as synced
  Future<void> markAsSynced(String id) async {
    try {
      final log = _logBox.get(id);
      if (log != null) {
        final updatedLog = log.copyWith(synced: true);
        await _logBox.put(id, updatedLog);
        _loadLogs();
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Sync unsynced logs to backend
  Future<int> syncLogs() async {
    if (_isSyncing) return 0;

    _isSyncing = true;
    notifyListeners();

    try {
      int syncedCount = 0;
      final unsynced = getUnsyncedLogs();
      for (final log in unsynced) {
        final sent = await _sheetApi.sendLog(log);
        if (sent) {
          await _logBox.put(log.id, log.copyWith(synced: true));
          syncedCount++;
        }
      }
      _loadLogs();
      return syncedCount;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
  
  /// Get count of unsynced logs
  int get unsyncedCount => _logs.where((log) => !log.synced).length;
}

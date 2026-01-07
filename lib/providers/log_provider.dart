import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:red_panda_tracker/models/index.dart';
import 'package:red_panda_tracker/services/hive_service.dart';
import 'package:red_panda_tracker/services/sheet_api.dart';
import 'package:red_panda_tracker/services/macro_calculation_service.dart';

/// Provider for managing Log entries
class LogProvider extends ChangeNotifier {
  late Box<LogEntry> _logBox;
  final SheetApi _sheetApi = SheetApi();
  List<LogEntry> _logs = [];
  bool _isSyncing = false;
  bool _initialSyncFailed = false;

  LogProvider() {
    _logBox = HiveService.getLogBox();
    _loadLogs();
    // Pull remote logs shortly after startup
    refreshFromSheets({}).catchError((e) {
      print('LogProvider: Initial sync failed: $e');
      _initialSyncFailed = true;
      notifyListeners();
    });
  }

  /// Get all logs
  List<LogEntry> get logs => _logs;
  
  /// Whether sync is currently in progress
  bool get isSyncing => _isSyncing;
  
  /// Whether the initial sync failed (indicates offline/backend issues)
  bool get initialSyncFailed => _initialSyncFailed;

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
      final log = _logBox.get(id);
      await _logBox.delete(id);
      _loadLogs();
      
      // Sync deletion to backend (best effort, fire-and-forget)
      if (log != null) {
        unawaited(_sheetApi.deleteLog(id));
      }
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
    return MacroCalculationService.calculateMacros(
      todayLogs,
      (foodName) => foodProvider.getFoodByName(foodName),
    );
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

  /// Pull logs from backend payload and merge into Hive
  Future<int> refreshFromSheets(Map<String, dynamic> data) async {
    if (_isSyncing) return 0;

    _isSyncing = true;
    notifyListeners();

    try {
      final remoteLogs = (data['logs'] as List?) ?? [];
      if (remoteLogs.isEmpty) {
        return 0;
      }

      // Merge remote logs into local map keyed by id
      final merged = <String, LogEntry>{
        for (final log in _logs) log.id: log,
      };

      int updatedCount = 0;
      for (final raw in remoteLogs) {
        final id = (raw['id'] ?? '').toString();
        if (id.isEmpty) continue;

        final candidate = LogEntry(
          id: id,
          foodName: (raw['foodName'] ?? '').toString(),
          foodEmoji: (raw['foodEmoji'] ?? '🍱').toString(),
          grams: _asDouble(raw['grams']),
          calories: _asDouble(raw['calories']),
          timestamp: _asDate(raw['timestamp']) ?? DateTime.now(),
          synced: true,
          mealCategory: (raw['mealCategory'] ?? 'Other').toString(),
        );

        final existing = merged[id];
        if (existing == null || !_logsEqual(existing, candidate)) {
          merged[id] = candidate;
          updatedCount++;
        }
      }

      await _logBox.clear();
      await _logBox.putAll(merged);
      _loadLogs();

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

  DateTime? _asDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  bool _logsEqual(LogEntry a, LogEntry b) {
    return a.foodName == b.foodName &&
        a.foodEmoji == b.foodEmoji &&
        a.grams == b.grams &&
        a.calories == b.calories &&
        a.mealCategory == b.mealCategory &&
        a.timestamp.toIso8601String() == b.timestamp.toIso8601String();
  }
}

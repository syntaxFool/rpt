import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service to handle initial app startup sync
/// Ensures all data is pulled from backend on app launch
class StartupSyncService {
  static final StartupSyncService _instance = StartupSyncService._internal();

  factory StartupSyncService() {
    return _instance;
  }

  StartupSyncService._internal();

  bool _hasSynced = false;
  bool get hasSynced => _hasSynced;

  /// Perform initial sync with backend on app startup
  /// Call from home screen after all providers are ready
  Future<void> performStartupSync({
    required Future<Map<String, dynamic>?> Function() fetchData,
    required Future<int> Function(Map<String, dynamic>) syncLogs,
    required Future<int> Function(Map<String, dynamic>) syncFoods,
    required Future<void> Function(Map<String, dynamic>) syncSettings,
  }) async {
    if (_hasSynced) return; // Only sync once per app session

    try {
      print('🔄 StartupSyncService: Beginning app startup sync...');

      // Fetch all data from backend in one call
      final data = await fetchData();
      if (data == null) {
        print('⚠️ StartupSyncService: Failed to fetch data from backend');
        return;
      }

      print('✓ StartupSyncService: Data fetched, syncing all providers...');

      // Sync in parallel for speed
      final results = await Future.wait([
        syncLogs(data),
        syncFoods(data),
      ]);

      await syncSettings(data);

      print('✓ StartupSyncService: Sync complete');
      print('  - Logs: ${results[0]} updated');
      print('  - Foods: ${results[1]} updated');

      _hasSynced = true;
    } catch (e) {
      print('❌ StartupSyncService: Sync failed: $e');
      // Don't rethrow - let app continue with local data
    }
  }

  /// Reset sync state (useful for testing or manual refresh)
  void reset() {
    _hasSynced = false;
  }
}

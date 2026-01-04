import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:red_panda_tracker/models/log_entry.dart';
import 'package:red_panda_tracker/services/hive_service.dart';

/// Service for syncing log entries to Google Apps Script backend
class SyncService {
  // TODO: Replace with actual Google Apps Script deployment URL
  static const String _syncEndpoint = 'YOUR_GOOGLE_APPS_SCRIPT_URL';
  
  SyncService();
  
  /// Sync all unsynced log entries to the backend
  /// Returns the number of successfully synced entries
  Future<int> syncLogs() async {
    try {
      final logBox = HiveService.getLogBox();
      
      // Get all unsynced logs
      final unsyncedLogs = logBox.values
          .where((log) => !log.synced)
          .toList();
      
      if (unsyncedLogs.isEmpty) {
        return 0;
      }
      
      int syncedCount = 0;
      
      // Sync each log entry
      for (final log in unsyncedLogs) {
        final success = await _syncSingleLog(log);
        if (success) {
          // Mark as synced in local database
          final updatedLog = log.copyWith(synced: true);
          await logBox.put(log.id, updatedLog);
          syncedCount++;
        }
      }
      
      return syncedCount;
    } catch (e) {
      // Log error but don't throw - allow offline operation
      return 0;
    }
  }
  
  /// Sync a single log entry to the backend
  Future<bool> _syncSingleLog(LogEntry log) async {
    try {
      final response = await http.post(
        Uri.parse(_syncEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': log.id,
          'foodName': log.foodName,
          'grams': log.grams,
          'calories': log.calories,
          'timestamp': log.timestamp.toIso8601String(),
          'foodEmoji': log.foodEmoji,
        }),
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Check if device has internet connectivity
  Future<bool> hasConnectivity() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.google.com'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Attempt to sync if online, otherwise skip
  Future<int> syncIfOnline() async {
    final isOnline = await hasConnectivity();
    if (!isOnline) {
      return 0;
    }
    
    return await syncLogs();
  }
}

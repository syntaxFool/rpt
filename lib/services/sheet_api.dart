import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:red_panda_tracker/models/index.dart';

/// Lightweight client for Apps Script sheet backend
class SheetApi {
  // Use Netlify proxy to avoid CORS in production; falls back to direct if needed
  static const String _baseUrl = '/api/exec';

  Uri get _uri => Uri.parse(_baseUrl);

  Future<bool> initSheets() async {
    return _post({'action': 'init'});
  }

  Future<bool> sendLog(LogEntry log) async {
    return _post({
      'action': 'addLog',
      'id': log.id,
      'timestamp': log.timestamp.toIso8601String(),
      'foodName': log.foodName,
      'foodEmoji': log.foodEmoji,
      'grams': log.grams,
      'calories': log.calories,
      'mealCategory': log.mealCategory,
    });
  }

  Future<bool> sendNote(DailyNote note) async {
    return _post({
      'action': 'addNote',
      'date': note.date,
      'note': note.note,
      'lastModified': note.lastModified.toIso8601String(),
    });
  }

  Future<bool> _post(Map<String, dynamic> payload) async {
    try {
      final res = await http
          .post(
            _uri,
            // No custom headers to avoid CORS preflight; Apps Script reads raw body
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

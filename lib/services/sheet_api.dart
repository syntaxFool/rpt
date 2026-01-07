import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:red_panda_tracker/models/index.dart';

/// Lightweight client for Apps Script sheet backend
class SheetApi {
  // Netlify proxy avoids CORS
  Uri get _uri {
    final origin = html.window.location.origin;
    // For localhost/dev: use absolute production URL to bypass CORS
    if (origin.contains('localhost') || origin.contains('127.0.0.1')) {
      return Uri.parse('https://5012rpt.netlify.app/api/exec');
    }
    // For production (Netlify): use relative path so proxy intercepts
    return Uri.parse('$origin/api/exec');
  }

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

  Future<bool> upsertFood(FoodAsset food) async {
    return _post({
      'action': 'addOrUpdateFood',
      'name': food.name,
      'emoji': food.emoji,
      'caloriesPer100g': food.caloriesPer100g,
      'proteinPer100g': food.proteinPer100g,
      'carbsPer100g': food.carbsPer100g,
      'fatPer100g': food.fatPer100g,
    });
  }

  Future<bool> deleteFood(String name) async {
    return _post({
      'action': 'deleteFood',
      'name': name,
    });
  }

  Future<bool> deleteLog(String id) async {
    return _post({
      'action': 'deleteLog',
      'id': id,
    });
  }

  Future<bool> updateSettings(AppSettings settings) async {
    return _post({
      'action': 'updateSettings',
      'dailyCalorieTarget': settings.dailyCalorieTarget,
      'proteinTarget': settings.proteinTarget,
      'carbsTarget': settings.carbsTarget,
      'fatTarget': settings.fatTarget,
    });
  }

  Future<Map<String, dynamic>?> fetchAll() async {
    try {
      final res = await http
          .post(
            _uri,
            body: jsonEncode({'action': 'list'}),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        print('SheetApi.fetchAll non-200: ${res.statusCode} body: ${res.body}');
      }
    } catch (e, stackTrace) {
      print('SheetApi.fetchAll error: $e');
      print('StackTrace: $stackTrace');
    }
    return null;
  }

  /// Optional: fetch by date range or paginate logs (requires backend support)
  Future<Map<String, dynamic>?> fetchRange({
    DateTime? start,
    DateTime? end,
    int? page,
    int? pageSize,
  }) async {
    final payload = {
      'action': 'list',
      if (start != null) 'startDate': start.toIso8601String(),
      if (end != null) 'endDate': end.toIso8601String(),
      if (page != null) 'page': page,
      if (pageSize != null) 'pageSize': pageSize,
    };
    try {
      final res = await http
          .post(
            _uri,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e, stackTrace) {
      print('SheetApi.fetchRange error: $e');
      print('StackTrace: $stackTrace');
    }
    return null;
  }

  Future<bool> _post(Map<String, dynamic> payload) async {
    const maxRetries = 3;
    const initialDelay = Duration(milliseconds: 500);
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final res = await http
            .post(
              _uri,
              // No custom headers to avoid CORS preflight; Apps Script reads raw body
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 10));
        
        if (res.statusCode == 200) {
          return true;
        }
        
        // Non-200 response, don't retry on client errors (4xx)
        if (res.statusCode >= 400 && res.statusCode < 500) {
          print('SheetApi._post [${payload['action']}]: Client error ${res.statusCode} body: ${res.body}');
          return false;
        }
        
        // Server error (5xx), retry
        if (attempt < maxRetries - 1) {
          final delay = initialDelay * (1 << attempt); // Exponential: 500ms, 1s, 2s
          print('SheetApi._post [${payload['action']}]: Retry ${attempt + 1}/$maxRetries after ${delay.inMilliseconds}ms');
          await Future.delayed(delay);
        }
      } catch (e, stackTrace) {
        if (attempt == maxRetries - 1) {
          // Last attempt failed, log and give up
          print('SheetApi._post error [${payload['action']}]: $e');
          print('StackTrace: $stackTrace');
          return false;
        }
        
        // Retry on network errors
        final delay = initialDelay * (1 << attempt);
        print('SheetApi._post [${payload['action']}]: Network error, retry ${attempt + 1}/$maxRetries after ${delay.inMilliseconds}ms');
        await Future.delayed(delay);
      }
    }
    
    return false;
  }
}

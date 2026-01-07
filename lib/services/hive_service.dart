import 'package:hive/hive.dart';
import 'package:red_panda_tracker/models/index.dart';
import 'package:red_panda_tracker/constants/adapter_type_ids.dart';

/// Service for managing Hive database initialization and box management
class HiveService {
  static const String foodBoxName = 'foods';
  static const String logBoxName = 'logs';
  static const String settingsBoxName = 'settings';

  static late Box<FoodAsset> _foodBox;
  static late Box<LogEntry> _logBox;
  static late Box<AppSettings> _settingsBox;

  /// Initialize Hive and register adapters
  static Future<void> init() async {
    try {
      // Register Hive adapters for type serialization
      if (!Hive.isAdapterRegistered(AdapterTypeIds.foodAsset)) {
        Hive.registerAdapter(FoodAssetAdapter());
      }
      if (!Hive.isAdapterRegistered(AdapterTypeIds.logEntry)) {
        Hive.registerAdapter(LogEntryAdapter());
      }
      if (!Hive.isAdapterRegistered(AdapterTypeIds.appSettings)) {
        Hive.registerAdapter(AppSettingsAdapter());
      }

      // Open boxes
      _foodBox = await Hive.openBox<FoodAsset>(foodBoxName);
      _logBox = await Hive.openBox<LogEntry>(logBoxName);
      _settingsBox = await Hive.openBox<AppSettings>(settingsBoxName);
    } catch (e) {
      rethrow;
    }
  }

  /// Get the Food box
  static Box<FoodAsset> getFoodBox() {
    return _foodBox;
  }

  /// Get the Log box
  static Box<LogEntry> getLogBox() {
    return _logBox;
  }

  /// Get the Settings box
  static Box<AppSettings> getSettingsBox() {
    return _settingsBox;
  }

  /// Close all boxes (useful for testing or app shutdown)
  static Future<void> closeBoxes() async {
    await _foodBox.close();
    await _logBox.close();
    await _settingsBox.close();
  }

  /// Clear all data (useful for testing or full reset)
  static Future<void> clearAll() async {
    await _foodBox.clear();
    await _logBox.clear();
    await _settingsBox.clear();
  }
}

import 'package:hive/hive.dart';
import 'package:red_panda_tracker/models/index.dart';

/// Service for managing Hive database initialization and box management
class HiveService {
  static const String foodBoxName = 'foods';
  static const String logBoxName = 'logs';
  static const String settingsBoxName = 'settings';
  static const String dailyNoteBoxName = 'dailyNotes';

  static late Box<FoodAsset> _foodBox;
  static late Box<LogEntry> _logBox;
  static late Box<AppSettings> _settingsBox;
  static late Box<DailyNote> _dailyNoteBox;

  /// Initialize Hive and register adapters
  static Future<void> init() async {
    try {
      // Register Hive adapters for type serialization
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(FoodAssetAdapter());
      }
      if (!Hive.isAdapterRegistered(11)) {
        Hive.registerAdapter(LogEntryAdapter());
      }
      if (!Hive.isAdapterRegistered(12)) {
        Hive.registerAdapter(AppSettingsAdapter());
      }
      if (!Hive.isAdapterRegistered(15)) {
        Hive.registerAdapter(DailyNoteAdapter());
      }

      // Open boxes
      _foodBox = await Hive.openBox<FoodAsset>(foodBoxName);
      _logBox = await Hive.openBox<LogEntry>(logBoxName);
      _settingsBox = await Hive.openBox<AppSettings>(settingsBoxName);
      _dailyNoteBox = await Hive.openBox<DailyNote>(dailyNoteBoxName);
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

  /// Get the DailyNote box
  static Box<DailyNote> getDailyNoteBox() {
    return _dailyNoteBox;
  }

  /// Close all boxes (useful for testing or app shutdown)
  static Future<void> closeBoxes() async {
    await _foodBox.close();
    await _logBox.close();
    await _settingsBox.close();
    await _dailyNoteBox.close();
  }

  /// Clear all data (useful for testing)
  static Future<void> clearAll() async {
    await _foodBox.clear();
    await _logBox.clear();
  }
}

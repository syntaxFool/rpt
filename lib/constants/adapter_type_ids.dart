/// Central registry for Hive adapter type IDs
/// Prevents accidental ID conflicts when adding new models
class AdapterTypeIds {
  /// FoodAsset model adapter
  static const int foodAsset = 10;
  
  /// LogEntry model adapter
  static const int logEntry = 11;
  
  /// AppSettings model adapter
  static const int appSettings = 12;
  
  /// DailyNote model adapter
  static const int dailyNote = 15;
  
  // Reserve 13-14 for future use
  // When adding new models:
  // 1. Add constant here first
  // 2. Update model's @HiveType annotation
  // 3. Update HiveService.init() registration
}

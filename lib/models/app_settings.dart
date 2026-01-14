import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 12)
class AppSettings extends HiveObject {
  @HiveField(0)
  double dailyCalorieTarget;

  @HiveField(1)
  double proteinTarget;

  @HiveField(2)
  double carbsTarget;

  @HiveField(3)
  double fatTarget;

  @HiveField(4)
  DateTime lastModified;

  AppSettings({
    this.dailyCalorieTarget = 2000.0,
    this.proteinTarget = 150.0,
    this.carbsTarget = 250.0,
    this.fatTarget = 65.0,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();

  AppSettings copyWith({
    double? dailyCalorieTarget,
    double? proteinTarget,
    double? carbsTarget,
    double? fatTarget,
    DateTime? lastModified,
  }) {
    return AppSettings(
      dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
      proteinTarget: proteinTarget ?? this.proteinTarget,
      carbsTarget: carbsTarget ?? this.carbsTarget,
      fatTarget: fatTarget ?? this.fatTarget,
      lastModified: lastModified ?? DateTime.now(),
    );
  }
}

import 'package:hive/hive.dart';
import 'package:red_panda_tracker/constants/adapter_type_ids.dart';

part 'profile.g.dart';

@HiveType(typeId: AdapterTypeIds.userProfile)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int age;

  @HiveField(2)
  String gender; // 'male', 'female', 'other'

  @HiveField(3)
  double heightCm;

  @HiveField(4)
  double currentWeightKg;

  @HiveField(5)
  double goalWeightKg;

  @HiveField(6)
  DateTime? lastWeightCheckIn;

  @HiveField(7)
  List<WeightEntry> weightHistory;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime lastModified;

  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.currentWeightKg,
    required this.goalWeightKg,
    this.lastWeightCheckIn,
    List<WeightEntry>? weightHistory,
    DateTime? createdAt,
    DateTime? lastModified,
  })  : weightHistory = weightHistory ?? [],
        createdAt = createdAt ?? DateTime.now(),
        lastModified = lastModified ?? DateTime.now();

  // Calculate BMI
  double get bmi => currentWeightKg / ((heightCm / 100) * (heightCm / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // Weight progress
  double get weightProgress {
    if (goalWeightKg == currentWeightKg) return 100;
    final initialWeight = weightHistory.isNotEmpty 
        ? weightHistory.first.weight 
        : currentWeightKg;
    final totalToLose = (initialWeight - goalWeightKg).abs();
    final lostSoFar = (initialWeight - currentWeightKg).abs();
    return totalToLose > 0 ? (lostSoFar / totalToLose * 100).clamp(0, 100) : 0;
  }

  // Weight change from first entry
  String get weightChange {
    if (weightHistory.isEmpty) return '0.0 kg';
    final initialWeight = weightHistory.first.weight;
    final change = currentWeightKg - initialWeight;
    final sign = change > 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)} kg';
  }

  // Check if weekly check-in is due
  bool get isWeeklyCheckInDue {
    if (lastWeightCheckIn == null) return true;
    return DateTime.now().difference(lastWeightCheckIn!).inDays >= 7;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'gender': gender,
        'heightCm': heightCm,
        'currentWeightKg': currentWeightKg,
        'goalWeightKg': goalWeightKg,
        'lastWeightCheckIn': lastWeightCheckIn?.toIso8601String(),
        'weightHistory': weightHistory.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'lastModified': lastModified.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'],
        age: json['age'],
        gender: json['gender'],
        heightCm: (json['heightCm'] as num).toDouble(),
        currentWeightKg: (json['currentWeightKg'] as num).toDouble(),
        goalWeightKg: (json['goalWeightKg'] as num).toDouble(),
        lastWeightCheckIn: json['lastWeightCheckIn'] != null && 
            json['lastWeightCheckIn'].toString().isNotEmpty
            ? DateTime.parse(json['lastWeightCheckIn'])
            : null,
        weightHistory: (json['weightHistory'] as List?)
                ?.map((e) => WeightEntry.fromJson(e))
                .toList() ??
            [],
        createdAt: DateTime.parse(json['createdAt']),
        lastModified: DateTime.parse(json['lastModified']),
      );
}

@HiveType(typeId: AdapterTypeIds.weightEntry)
class WeightEntry extends HiveObject {
  @HiveField(0)
  double weight;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String? note;

  WeightEntry({
    required this.weight,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'weight': weight,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory WeightEntry.fromJson(Map<String, dynamic> json) => WeightEntry(
        weight: (json['weight'] as num).toDouble(),
        date: DateTime.parse(json['date']),
        note: json['note'],
      );
}

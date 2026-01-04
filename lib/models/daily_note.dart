import 'package:hive/hive.dart';

part 'daily_note.g.dart';

@HiveType(typeId: 15)
class DailyNote extends HiveObject {
  @HiveField(0)
  String date; // yyyy-MM-dd format

  @HiveField(1)
  String note;

  @HiveField(2)
  DateTime lastModified;

  DailyNote({
    required this.date,
    required this.note,
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();
}

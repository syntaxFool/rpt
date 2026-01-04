import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:red_panda_tracker/models/index.dart';
import 'package:red_panda_tracker/services/hive_service.dart';
import 'package:red_panda_tracker/services/sheet_api.dart';

class NoteProvider with ChangeNotifier {
  late Box<DailyNote> _noteBox;
  final SheetApi _sheetApi = SheetApi();

  NoteProvider() {
    _noteBox = HiveService.getDailyNoteBox();
  }

  /// Get note for a specific date (yyyy-MM-dd format)
  DailyNote? getNote(String date) {
    return _noteBox.get(date);
  }

  /// Get note for today
  DailyNote? getTodayNote() {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return getNote(dateKey);
  }

  /// Save or update a note
  Future<void> saveNote(DailyNote note) async {
    await _noteBox.put(note.date, note);
    // Fire-and-forget send to sheet; ignore failure to preserve offline behavior
    // If it succeeds, nothing else needed because data already stored locally
    unawaited(_sheetApi.sendNote(note));
    notifyListeners();
  }

  /// Delete a note
  Future<void> deleteNote(String date) async {
    await _noteBox.delete(date);
    notifyListeners();
  }

  /// Get all notes
  List<DailyNote> getAllNotes() {
    return _noteBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get notes for a specific month
  List<DailyNote> getMonthNotes(int year, int month) {
    final monthKey = '$year-${month.toString().padLeft(2, '0')}';
    return _noteBox.values
        .where((note) => note.date.startsWith(monthKey))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}

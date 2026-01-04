import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_panda_tracker/models/index.dart';
import 'package:red_panda_tracker/providers/index.dart';

class DailyNoteCard extends StatefulWidget {
  const DailyNoteCard({super.key});

  @override
  State<DailyNoteCard> createState() => _DailyNoteCardState();
}

class _DailyNoteCardState extends State<DailyNoteCard> {
  late TextEditingController _noteController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _getTodayDateKey() {
    final today = DateTime.now();
    return '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, _) {
        final todayNote = noteProvider.getTodayNote();
        
        if (!_isEditing && todayNote != null) {
          _noteController.text = todayNote.note;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.note_alt_outlined,
                      color: Color(0xFFF27D52),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Daily Note',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A342E),
                      ),
                    ),
                    const Spacer(),
                    if (todayNote != null && !_isEditing)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () {
                              setState(() {
                                _isEditing = true;
                              });
                            },
                            color: const Color(0xFFF27D52),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: () {
                              noteProvider.deleteNote(_getTodayDateKey());
                              _noteController.clear();
                            },
                            color: Colors.red.shade300,
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_isEditing || todayNote == null)
                  Column(
                    children: [
                      TextField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'How was your day? Any insights about your nutrition?',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_isEditing)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  if (todayNote != null) {
                                    _noteController.text = todayNote.note;
                                  } else {
                                    _noteController.clear();
                                  }
                                });
                              },
                              child: const Text('Cancel'),
                            ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (_noteController.text.trim().isNotEmpty) {
                                final note = DailyNote(
                                  date: _getTodayDateKey(),
                                  note: _noteController.text.trim(),
                                  lastModified: DateTime.now(),
                                );
                                noteProvider.saveNote(note);
                                setState(() {
                                  _isEditing = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Note saved! 📝'),
                                    backgroundColor: Color(0xFFF27D52),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF27D52),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Text(
                    todayNote!.note,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4A342E),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

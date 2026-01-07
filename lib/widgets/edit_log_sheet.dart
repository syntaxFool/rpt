import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_panda_tracker/models/index.dart';
import 'package:red_panda_tracker/providers/index.dart';

class EditLogSheet extends StatefulWidget {
  final LogEntry log;

  const EditLogSheet({super.key, required this.log});

  @override
  State<EditLogSheet> createState() => _EditLogSheetState();
}

class _EditLogSheetState extends State<EditLogSheet> {
  late TextEditingController _gramsController;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _gramsController = TextEditingController(text: widget.log.grams.toStringAsFixed(0));
    _selectedDateTime = widget.log.timestamp;
  }

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  void _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _saveChanges() {
    final grams = double.tryParse(_gramsController.text);
    if (grams == null || grams <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Color(0xFFE53935),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final foodProvider = context.read<FoodProvider>();
    final food = foodProvider.getFoodByName(widget.log.foodName);

    if (food == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Food not found'),
          backgroundColor: Color(0xFFE53935),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final updatedLog = LogEntry(
      id: widget.log.id,
      foodName: widget.log.foodName,
      foodEmoji: widget.log.foodEmoji,
      grams: grams,
      calories: food.calculateCalories(grams),
      timestamp: _selectedDateTime,
      synced: false,
    );

    context.read<LogProvider>().updateLog(updatedLog);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Log updated! ✅'),
        backgroundColor: Color(0xFFF27D52),
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = context.read<FoodProvider>();
    final food = foodProvider.getFoodByName(widget.log.foodName);

    if (food == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Text('Food not found'),
      );
    }

    final grams = double.tryParse(_gramsController.text) ?? widget.log.grams;
    final calories = food.calculateCalories(grams);
    final protein = food.calculateProtein(grams);
    final carbs = food.calculateCarbs(grams);
    final fat = food.calculateFat(grams);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDF9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Row(
              children: [
                Text(
                  food.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Edit ${food.name}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A342E),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Grams Input
            TextField(
              controller: _gramsController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount (grams)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Date/Time Picker
            InkWell(
              onTap: _selectDateTime,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFFF27D52)),
                    const SizedBox(width: 12),
                    Text(
                      '${_selectedDateTime.day.toString().padLeft(2, '0')} ${_selectedDateTime.month.toString().padLeft(2, '0')} ${_selectedDateTime.year} '
                      '${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Nutrition Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF27D52).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNutritionItem('🔥', calories.toStringAsFixed(0), 'kcal'),
                      _buildNutritionItem('💪', protein.toStringAsFixed(1), 'g'),
                      _buildNutritionItem('🌾', carbs.toStringAsFixed(1), 'g'),
                      _buildNutritionItem('🥑', fat.toStringAsFixed(1), 'g'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF27D52),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A342E),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

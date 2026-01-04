import 'package:flutter/material.dart';
import 'package:red_panda_tracker/models/index.dart';

class LogEntryCard extends StatelessWidget {
  final LogEntry log;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const LogEntryCard({
    super.key,
    required this.log,
    required this.onDelete,
    this.onEdit,
  });

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Food Emoji
            Text(
              log.foodEmoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),

            // Food Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        log.foodName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF4A342E),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (log.mealCategory != 'Other') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(log.mealCategory),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getCategoryEmoji(log.mealCategory),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${log.grams.toStringAsFixed(0)}g',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF4A342E).withValues(alpha: 0.6),
                            ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${_formatTime(log.timestamp)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF4A342E).withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Calories & Actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  log.calories.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFFF27D52),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                        color: const Color(0xFFF27D52),
                        iconSize: 20,
                      ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      color: const Color(0xFFE53935),
                      iconSize: 20,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Breakfast':
        return Colors.orange.withValues(alpha: 0.2);
      case 'Lunch':
        return Colors.blue.withValues(alpha: 0.2);
      case 'Dinner':
        return Colors.purple.withValues(alpha: 0.2);
      case 'Snack':
        return Colors.green.withValues(alpha: 0.2);
      default:
        return Colors.grey.withValues(alpha: 0.2);
    }
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'Breakfast':
        return '🌅';
      case 'Lunch':
        return '☀️';
      case 'Dinner':
        return '🌙';
      case 'Snack':
        return '🍿';
      default:
        return '🍽️';
    }
  }
}

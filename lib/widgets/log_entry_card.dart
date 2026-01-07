import 'package:flutter/material.dart';
import 'dart:ui' show FontFeature;
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
    final now = DateTime.now();
    final isToday = dateTime.year == now.year && 
                    dateTime.month == now.month && 
                    dateTime.day == now.day;
    
    if (isToday) {
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } else {
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${dateTime.day.toString().padLeft(2, '0')} ${dateTime.month.toString().padLeft(2, '0')} ${dateTime.year} $displayHour:$minute $period';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A342E).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            // Food Emoji
            Text(
              log.foodEmoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 18),

            // Food Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Tooltip(
                          message: log.foodName,
                          waitDuration: const Duration(milliseconds: 300),
                          child: Text(
                            log.foodName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 15,
                                  height: 1.2,
                                  color: const Color(0xFF4A342E),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${log.grams.toStringAsFixed(0)}g',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF4A342E).withValues(alpha: 0.6),
                              fontSize: 13,
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
                SizedBox(
                  width: 44,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      log.calories.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            color: const Color(0xFFF27D52),
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                        color: const Color(0xFFF27D52),
                        iconSize: 18,
                      ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      color: const Color(0xFFE53935),
                      iconSize: 18,
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

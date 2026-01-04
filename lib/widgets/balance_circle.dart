import 'package:flutter/material.dart';
import 'dart:math' as math;

class BalanceCircle extends StatelessWidget {
  final double current;
  final double target;

  const BalanceCircle({
    super.key,
    required this.current,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / target).clamp(0.0, 1.0);
    final remaining = (target - current).clamp(0.0, target);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background Circle
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CustomPaint(
                      painter: _CirclePainter(
                        progress: progress,
                        color: const Color(0xFFF27D52),
                        backgroundColor: const Color(0xFFFFFDF9),
                      ),
                    ),
                  ),
                  // Center Text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        current.toStringAsFixed(0),
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: const Color(0xFF4A342E),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'kcal',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: const Color(0xFF4A342E).withValues(alpha: 0.6),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        remaining > 0
                            ? '${remaining.toStringAsFixed(0)} left'
                            : 'Over target!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: remaining > 0
                                  ? const Color(0xFFF27D52)
                                  : const Color(0xFFE53935),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Target: ${target.toStringAsFixed(0)} kcal',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF4A342E).withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _CirclePainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

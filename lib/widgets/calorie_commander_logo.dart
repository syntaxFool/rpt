import 'package:flutter/material.dart';

class CalorieCommanderLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const CalorieCommanderLogo({
    super.key,
    this.size = 64,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF9),
            borderRadius: BorderRadius.circular(size * 0.15),
            border: Border.all(
              color: const Color(0xFFF27D52),
              width: size * 0.04,
            ),
          ),
          child: Center(
            child: Image.asset(
              'web/icons/favicon.png',
              width: size * 0.72,
              height: size * 0.72,
              fit: BoxFit.contain,
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            'Calorie Commander',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF4A342E),
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

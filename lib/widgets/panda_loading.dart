import 'package:flutter/material.dart';

/// Animated panda loading indicator
class PandaLoading extends StatefulWidget {
  final double size;
  final String? message;
  final bool showMessage;

  const PandaLoading({
    super.key,
    this.size = 120,
    this.message,
    this.showMessage = true,
  });

  @override
  State<PandaLoading> createState() => _PandaLoadingState();
}

class _PandaLoadingState extends State<PandaLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _floatAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -25)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -25, end: 0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _shadowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.7)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.7, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size + 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Floating panda
              AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: Image.asset(
                      'icons/favicon.png',
                      width: widget.size,
                      height: widget.size,
                    ),
                  );
                },
              ),
              // Shadow
              Positioned(
                bottom: 0,
                child: AnimatedBuilder(
                  animation: _shadowAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _shadowAnimation.value,
                      child: Container(
                        width: widget.size * 0.7,
                        height: widget.size * 0.08,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF27D52).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (widget.showMessage) ...[
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 2000),
            tween: Tween(begin: 0.5, end: 1.0),
            curve: Curves.easeInOut,
            builder: (context, opacity, child) {
              return Opacity(
                opacity: opacity,
                child: Text(
                  widget.message ?? 'Loading...',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A342E),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

/// Full-screen panda loading overlay
class PandaLoadingOverlay extends StatelessWidget {
  final String? message;

  const PandaLoadingOverlay({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFDF9),
            Color(0xFFFFF5EB),
          ],
        ),
      ),
      child: Center(
        child: PandaLoading(
          message: message ?? 'Calorie Commander',
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A floating island widget that shows sync status
class SyncIsland extends StatefulWidget {
  final bool isVisible;
  final String message;
  final SyncStatus status;
  final VoidCallback? onTap;

  const SyncIsland({
    super.key,
    required this.isVisible,
    this.message = 'Syncing...',
    this.status = SyncStatus.syncing,
    this.onTap,
  });

  @override
  State<SyncIsland> createState() => _SyncIslandState();
}

class _SyncIslandState extends State<SyncIsland>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(SyncIsland oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible && _controller.isDismissed) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 16,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: _getGradient(),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: _getColor().withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIcon(),
                    const SizedBox(width: 12),
                    Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (widget.status) {
      case SyncStatus.syncing:
        return SizedBox(
          width: 18,
          height: 18,
          child: _SpinningIcon(
            icon: Icons.sync_rounded,
            color: Colors.white,
          ),
        );
      case SyncStatus.success:
        return const Icon(
          Icons.check_circle_rounded,
          color: Colors.white,
          size: 18,
        );
      case SyncStatus.error:
        return const Icon(
          Icons.error_rounded,
          color: Colors.white,
          size: 18,
        );
      case SyncStatus.offline:
        return const Icon(
          Icons.cloud_off_rounded,
          color: Colors.white,
          size: 18,
        );
    }
  }

  Color _getColor() {
    switch (widget.status) {
      case SyncStatus.syncing:
        return const Color(0xFF4A90E2);
      case SyncStatus.success:
        return const Color(0xFF4CAF50);
      case SyncStatus.error:
        return const Color(0xFFE74C3C);
      case SyncStatus.offline:
        return const Color(0xFF95A5A6);
    }
  }

  LinearGradient _getGradient() {
    final color = _getColor();
    return LinearGradient(
      colors: [
        color,
        Color.lerp(color, Colors.black, 0.2)!,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

/// Spinning icon animation widget
class _SpinningIcon extends StatefulWidget {
  final IconData icon;
  final Color color;

  const _SpinningIcon({
    required this.icon,
    required this.color,
  });

  @override
  State<_SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<_SpinningIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: Icon(
            widget.icon,
            color: widget.color,
            size: 18,
          ),
        );
      },
    );
  }
}

enum SyncStatus {
  syncing,
  success,
  error,
  offline,
}

import 'package:flutter/material.dart';
import 'dart:math';

class WaveAnimation extends StatefulWidget {
  final bool isActive;
  final Color color;
  
  const WaveAnimation({
    super.key,
    required this.isActive,
    this.color = const Color(0xFF6C63FF),
  });

  @override
  State<WaveAnimation> createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<WaveAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isActive) _controller.repeat();
  }

  @override
  void didUpdateWidget(WaveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return const SizedBox(height: 40);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(20, (i) {
              final progress = (_controller.value + i / 20) % 1.0;
              final height = 10 + sin(progress * pi * 2) * 15;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 3,
                height: height.abs(),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.5 + progress * 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppBackground({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(-0.9, -1),
          end: const Alignment(0.95, 1),
          colors: isDark
              ? [
                  const Color(0xFF070B13),
                  const Color(0xFF101A2A),
                  const Color(0xFF0A111D),
                ]
              : [
                  const Color(0xFFEAF1FF),
                  const Color(0xFFF3F8FF),
                  const Color(0xFFE9EFFA),
                ],
        ),
      ),
      child: Stack(
        children: [
          _GlowOrb(
            alignment: const Alignment(-0.85, -0.95),
            color: theme.colorScheme.primary.withValues(
              alpha: isDark ? 0.21 : 0.2,
            ),
            size: 340,
          ),
          _GlowOrb(
            alignment: const Alignment(1.05, -0.55),
            color: theme.colorScheme.tertiary.withValues(
              alpha: isDark ? 0.15 : 0.13,
            ),
            size: 280,
          ),
          _GlowOrb(
            alignment: const Alignment(0.78, 0.95),
            color: theme.colorScheme.secondary.withValues(
              alpha: isDark ? 0.14 : 0.1,
            ),
            size: 360,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: isDark ? 0.03 : 0.25),
                      Colors.transparent,
                      Colors.black.withValues(alpha: isDark ? 0.12 : 0.02),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final double size;

  const _GlowOrb({
    required this.alignment,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 56, sigmaY: 56),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ),
      ),
    );
  }
}

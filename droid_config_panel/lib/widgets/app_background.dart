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
          begin: const Alignment(-0.3, -1),
          end: const Alignment(0.7, 1),
          colors: isDark
              ? [
                  const Color(0xFF0F1923),
                  const Color(0xFF142130),
                  const Color(0xFF101B27),
                ]
              : [
                  const Color(0xFFF9FCFF),
                  const Color(0xFFF3F8FD),
                  const Color(0xFFEEF5FC),
                ],
        ),
      ),
      child: Stack(
        children: [
          _GlowOrb(
            alignment: const Alignment(-0.9, -0.95),
            color: theme.colorScheme.primary.withValues(
              alpha: isDark ? 0.14 : 0.12,
            ),
            size: 300,
          ),
          _GlowOrb(
            alignment: const Alignment(1.05, -0.7),
            color: theme.colorScheme.tertiary.withValues(
              alpha: isDark ? 0.1 : 0.08,
            ),
            size: 240,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: isDark ? 0.03 : 0.38),
                      Colors.transparent,
                      Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
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
          imageFilter: ImageFilter.blur(sigmaX: 52, sigmaY: 52),
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

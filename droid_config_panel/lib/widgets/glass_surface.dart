import 'dart:ui';

import 'package:flutter/material.dart';

class GlassSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? tintColor;
  final Color? borderColor;
  final List<Color>? gradientColors;
  final bool showInnerGlow;
  final double shadowOpacity;

  const GlassSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 24,
    this.blur = 18,
    this.tintColor,
    this.borderColor,
    this.gradientColors,
    this.showInnerGlow = true,
    this.shadowOpacity = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final media = MediaQuery.maybeOf(context);
    final disableAnimations = media?.disableAnimations ?? false;
    final highContrast = media?.highContrast ?? false;
    final radius = BorderRadius.circular(borderRadius);
    final effectiveBlur = disableAnimations ? 0.0 : blur;
    final resolvedBorderColor =
        borderColor ??
        theme.colorScheme.outlineVariant.withValues(
          alpha: isDark ? 0.46 : 0.52,
        );

    final colors =
        gradientColors ??
        [
          Colors.white.withValues(alpha: isDark ? 0.08 : 0.58),
          Colors.white.withValues(alpha: isDark ? 0.02 : 0.26),
        ];

    final resolvedTintColor =
        tintColor ??
        theme.colorScheme.surfaceContainer.withValues(
          alpha: isDark ? 0.7 : 0.94,
        );

    final colorBoost = highContrast ? (isDark ? 0.12 : 0.14) : 0.0;
    final borderBoost = highContrast ? 0.18 : 0.0;

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: resolvedTintColor.withValues(
          alpha: (resolvedTintColor.a + colorBoost).clamp(0.0, 1.0),
        ),
        border: Border.all(
          color: resolvedBorderColor.withValues(
            alpha: (resolvedBorderColor.a + borderBoost).clamp(0.0, 1.0),
          ),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          if (showInnerGlow && !highContrast)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: isDark ? 0.08 : 0.18),
                        Colors.white.withValues(alpha: isDark ? 0.02 : 0.06),
                        Colors.transparent.withValues(alpha: 0.4),
                      ],
                      stops: const [0, 0.35, 1],
                    ),
                  ),
                ),
              ),
            ),
          child,
        ],
      ),
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            blurRadius: isDark ? 22 : 16,
            spreadRadius: -10,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(
              alpha: (isDark ? 0.2 : 0.06) * shadowOpacity,
            ),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: effectiveBlur > 0
            ? BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: effectiveBlur,
                  sigmaY: effectiveBlur,
                ),
                child: content,
              )
            : content,
      ),
    );
  }
}

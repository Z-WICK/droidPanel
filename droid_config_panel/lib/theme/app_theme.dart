import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color accent = Color(0xFF2F7BF6);
  static const Color success = Color(0xFF1FA971);
  static const Color warning = Color(0xFFE19A22);
  static const Color danger = Color(0xFFD64A58);
  static const Color info = Color(0xFF2490C8);

  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: brightness,
        ).copyWith(
          primary: accent,
          onPrimary: Colors.white,
          secondary: isDark ? const Color(0xFF9FB5C8) : const Color(0xFF375368),
          tertiary: isDark ? const Color(0xFF57C4D8) : const Color(0xFF1D8FA7),
          error: danger,
          surface: isDark ? const Color(0xFF111A24) : const Color(0xFFF7FAFD),
          onSurface: isDark ? const Color(0xFFF1F6FB) : const Color(0xFF17202B),
          outline: isDark ? const Color(0xFF5E7083) : const Color(0xFFA4B3C1),
          outlineVariant: isDark
              ? const Color(0xFF3C4C5F)
              : const Color(0xFFD5E0E9),
          surfaceContainer: isDark
              ? const Color(0xFF16222F)
              : const Color(0xFFEEF4FA),
          surfaceContainerHigh: isDark
              ? const Color(0xFF1C2A38)
              : const Color(0xFFE8F0F7),
          surfaceContainerHighest: isDark
              ? const Color(0xFF243343)
              : const Color(0xFFE0EAF3),
        );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: GoogleFonts.dmSans().fontFamily,
    );

    final heading = GoogleFonts.spaceGroteskTextTheme(base.textTheme);
    final body = GoogleFonts.dmSansTextTheme(base.textTheme);
    final textTheme = body.copyWith(
      displayLarge: heading.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
      ),
      displayMedium: heading.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      displaySmall: heading.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      headlineMedium: heading.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineSmall: heading.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.35,
      ),
      titleLarge: heading.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.24,
      ),
      titleMedium: heading.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      bodyLarge: body.bodyLarge?.copyWith(height: 1.45),
      bodyMedium: body.bodyMedium?.copyWith(height: 1.45),
      bodySmall: body.bodySmall?.copyWith(height: 1.4),
      labelLarge: body.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.macOS: _GlassPageTransitionsBuilder(),
          TargetPlatform.iOS: _GlassPageTransitionsBuilder(),
          TargetPlatform.android: _GlassPageTransitionsBuilder(),
          TargetPlatform.windows: _GlassPageTransitionsBuilder(),
          TargetPlatform.linux: _GlassPageTransitionsBuilder(),
          TargetPlatform.fuchsia: _GlassPageTransitionsBuilder(),
        },
      ),
      focusColor: scheme.primary.withValues(alpha: isDark ? 0.34 : 0.22),
      hoverColor: scheme.primary.withValues(alpha: isDark ? 0.14 : 0.1),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer.withValues(alpha: isDark ? 0.7 : 0.9),
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.24 : 0.06),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(
              alpha: isDark ? 0.42 : 0.52,
            ),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: isDark ? 0.58 : 0.52),
        ),
        selectedColor: scheme.primary.withValues(alpha: isDark ? 0.24 : 0.14),
        checkmarkColor: scheme.primary,
        backgroundColor: scheme.surfaceContainer.withValues(
          alpha: isDark ? 0.6 : 0.93,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer.withValues(alpha: isDark ? 0.54 : 1),
        labelStyle: textTheme.labelLarge?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(
              alpha: isDark ? 0.62 : 0.58,
            ),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: scheme.primary.withValues(alpha: 0.9),
            width: 1.45,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: scheme.error.withValues(alpha: 0.85),
            width: 1.25,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
      ),
      dividerColor: scheme.outlineVariant.withValues(alpha: 0.36),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerHigh.withValues(
          alpha: isDark ? 0.95 : 0.98,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainer.withValues(
          alpha: isDark ? 0.94 : 0.98,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 42),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          foregroundColor: scheme.onSurface,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 42),
          elevation: 0,
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 42),
          backgroundColor: scheme.surfaceContainer.withValues(
            alpha: isDark ? 0.54 : 0.92,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(
              alpha: isDark ? 0.58 : 0.54,
            ),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(40, 40),
          foregroundColor: scheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: scheme.surfaceContainerHigh.withValues(
          alpha: isDark ? 0.96 : 0.99,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          minimumSize: WidgetStateProperty.all(const Size(48, 36)),
          side: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return BorderSide(
              color: selected
                  ? scheme.primary.withValues(alpha: 0.74)
                  : scheme.outlineVariant.withValues(
                      alpha: isDark ? 0.58 : 0.56,
                    ),
            );
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            if (selected) {
              return scheme.primary.withValues(alpha: isDark ? 0.22 : 0.12);
            }
            return scheme.surfaceContainer.withValues(
              alpha: isDark ? 0.7 : 0.94,
            );
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant;
          }),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

class _GlassPageTransitionsBuilder extends PageTransitionsBuilder {
  const _GlassPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) {
      return child;
    }

    final incoming = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final outgoing = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.012, 0),
      ).animate(outgoing),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0.02, 1, curve: Curves.easeOut),
        ),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.025, 0),
            end: Offset.zero,
          ).animate(incoming),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.988, end: 1).animate(incoming),
            child: child,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _seed = Color(0xFF0A84FF);
  static const Color _surfaceLight = Color(0xFFF1F5FF);
  static const Color _surfaceDark = Color(0xFF090E17);

  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
      surface: isDark ? _surfaceDark : _surfaceLight,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: 'SF Pro Text',
    );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
        .copyWith(
          headlineSmall: base.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          titleLarge: base.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.28,
          ),
          titleMedium: base.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.35),
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
        color: scheme.surface.withValues(alpha: isDark ? 0.62 : 0.74),
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.34 : 0.12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
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
          color: scheme.outlineVariant.withValues(alpha: isDark ? 0.55 : 0.42),
        ),
        selectedColor: scheme.primaryContainer.withValues(
          alpha: isDark ? 0.32 : 0.54,
        ),
        backgroundColor: scheme.surface.withValues(alpha: isDark ? 0.25 : 0.42),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(
          alpha: isDark ? 0.24 : 0.32,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.46),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: scheme.primary.withValues(alpha: 0.9),
            width: 1.35,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dividerColor: scheme.outlineVariant.withValues(alpha: 0.34),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface.withValues(alpha: isDark ? 0.84 : 0.94),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface.withValues(alpha: isDark ? 0.86 : 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          foregroundColor: scheme.onSurface,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary.withValues(
            alpha: isDark ? 0.72 : 0.86,
          ),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(
              alpha: isDark ? 0.56 : 0.42,
            ),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: scheme.surface.withValues(alpha: isDark ? 0.9 : 0.94),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

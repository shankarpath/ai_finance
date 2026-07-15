import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// FinCoach design system.
///
/// Dark-first fintech look: deep charcoal surfaces, a single electric-mint
/// accent, soft violet secondary, generous radii, Manrope type. Light theme
/// derives from the same tokens so both modes feel like one product.
class AppTheme {
  AppTheme._();

  // ---- Core tokens ---------------------------------------------------------
  static const mint = Color(0xFF4ADE80);
  static const mintDeep = Color(0xFF16A34A);
  static const violet = Color(0xFF8B7CF6);
  static const coral = Color(0xFFFF6B6B);
  static const amber = Color(0xFFFFB74D);
  static const sky = Color(0xFF4DABF7);

  // Dark surfaces
  static const bgDark = Color(0xFF0B0F14);
  static const surfaceDark = Color(0xFF121820);
  static const surfaceAltDark = Color(0xFF1A222D);
  static const outlineDark = Color(0xFF243040);

  static const radius = 20.0;

  /// The hero gradient used on the safe-to-spend gauge card.
  static const heroGradient = LinearGradient(
    colors: [Color(0xFF10331F), Color(0xFF0E1A2B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const dangerGradient = LinearGradient(
    colors: [Color(0xFF3A1416), Color(0xFF20101E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: mint,
      brightness: Brightness.dark,
    ).copyWith(
      primary: mint,
      onPrimary: const Color(0xFF06230F),
      secondary: violet,
      surface: surfaceDark,
      surfaceContainerHighest: surfaceAltDark,
      surfaceContainerHigh: surfaceAltDark,
      surfaceContainerLow: surfaceDark,
      outlineVariant: outlineDark,
      error: coral,
    );
    return _base(scheme, bgDark);
  }

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: mintDeep,
      brightness: Brightness.light,
    ).copyWith(
      primary: mintDeep,
      secondary: const Color(0xFF6D5BD0),
      error: const Color(0xFFD64545),
    );
    return _base(scheme, const Color(0xFFF6F8FA));
  }

  static ThemeData _base(ColorScheme scheme, Color background) {
    final textTheme = GoogleFonts.manropeTextTheme(
      ThemeData(brightness: scheme.brightness).textTheme,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: scheme.outlineVariant, width: 0.6),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: background,
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 0.6,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
    );
  }
}

/// A reusable rounded panel with the FinCoach card look.
class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final body = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? scheme.surface : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: scheme.outlineVariant, width: 0.6),
      ),
      child: child,
    );
    if (onTap == null) return body;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: body,
      ),
    );
  }
}

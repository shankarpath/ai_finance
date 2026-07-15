import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';

/// A compact proactive AI insight card: an accent icon chip + one coaching
/// line, with a shimmer while loading and a graceful fallback when the coach
/// isn't configured. Shared across the dashboard, budgets, and reports screens.
class CoachInsightCard extends StatelessWidget {
  /// The insight text: null while loading is handled by [loading]; a null
  /// *data* value means "AI not configured" and shows [emptyText].
  final AsyncValue<String?> insight;
  final IconData icon;
  final Color accent;
  final String emptyText;
  final VoidCallback? onTap;

  const CoachInsightCard({
    super.key,
    required this.insight,
    required this.icon,
    required this.accent,
    this.emptyText = 'Add your Gemini key in Settings to unlock AI coaching.',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Panel(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: insight.when(
            loading: () => const SkeletonBox(height: 16),
            error: (_, __) => Text('Coach is offline right now.',
                style: theme.textTheme.bodyMedium),
            data: (text) => Text(
              text ?? emptyText,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600, height: 1.3),
            ),
          ),
        ),
        if (onTap != null) const Icon(Icons.chevron_right, size: 18),
      ]),
    );
  }
}

/// An amount that counts up from 0 when it first appears (and re-animates when
/// the value changes) — the "expensive app" feel.
class CountUpText extends StatelessWidget {
  final double value;
  final String Function(double) format;
  final TextStyle? style;
  final Duration duration;

  const CountUpText({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Text(format(v), style: style),
    );
  }
}

/// The safe-to-spend radial gauge: a 240° arc that fills with the fraction of
/// budget remaining, sweeping in on build.
class SafeToSpendGauge extends StatelessWidget {
  /// 0..1 — fraction of the month's budget still unspent.
  final double remainingFraction;
  final Widget center;
  final double size;

  const SafeToSpendGauge({
    super.key,
    required this.remainingFraction,
    required this.center,
    this.size = 148,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: remainingFraction.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOutCubic,
        builder: (context, v, child) => CustomPaint(
          painter: _GaugePainter(
            fraction: v,
            track: scheme.outlineVariant,
            low: v < 0.2,
          ),
          child: Center(child: child),
        ),
        child: center,
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double fraction;
  final Color track;
  final bool low;

  _GaugePainter({required this.fraction, required this.track, required this.low});

  static const _sweep = 240.0;
  static const _start = 150.0; // degrees; leaves the gap at the bottom

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = rect.deflate(11);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round;

    // Track
    stroke.color = track;
    canvas.drawArc(
        inset, _rad(_start), _rad(_sweep), false, stroke);

    // Value arc with a gradient sweep
    final colors = low
        ? [AppTheme.coral, AppTheme.amber]
        : [AppTheme.mintDeep, AppTheme.mint];
    stroke.shader = SweepGradient(
      startAngle: _rad(_start),
      endAngle: _rad(_start + _sweep),
      colors: colors,
      transform: const GradientRotation(0),
    ).createShader(inset);
    canvas.drawArc(
        inset, _rad(_start), _rad(_sweep * fraction), false, stroke);
  }

  double _rad(double deg) => deg * math.pi / 180;

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.fraction != fraction || old.low != low || old.track != track;
}

/// A grey shimmer block used as a loading skeleton.
class SkeletonBox extends StatefulWidget {
  final double height;
  final double? width;
  final BorderRadius? radius;

  const SkeletonBox({super.key, required this.height, this.width, this.radius});

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return FadeTransition(
      opacity: Tween(begin: 0.45, end: 1.0).animate(_c),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: base,
          borderRadius: widget.radius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}

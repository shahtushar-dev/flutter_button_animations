import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// The initial pill-shaped share button.
///
/// Morphs from full pill → circle as [morphProgress] goes 0→1.
/// Displays a breathing glow via [glowProgress] (repeating animation).
/// Shows a ripple burst at [rippleProgress] on tap.
class ShareButton extends StatelessWidget {
  const ShareButton({
    super.key,
    required this.morphProgress,
    required this.glowProgress,
    required this.rippleProgress,
    required this.onTap,
  });

  /// 0.0 = full pill  →  1.0 = perfect circle
  final double morphProgress;

  /// 0.0 → 1.0 → 0.0 looping — drives the idle breathing glow
  final double glowProgress;

  /// 0.0 → 1.0 — tap ripple expands and fades
  final double rippleProgress;

  final VoidCallback onTap;

  // Geometry constants
  static const double _pillWidth = 180.0;
  static const double _circleSize = 58.0;
  static const double _height = 58.0;

  @override
  Widget build(BuildContext context) {
    // Interpolate width: pill → circle
    final width = _pillWidth - (_pillWidth - _circleSize) * morphProgress;

    // Interpolate border radius: pill (half-height) → perfect circle
    final borderRadius = _height / 2;

    // Text fades out very quickly at the start of the morph
    final textOpacity = (1.0 - (morphProgress * 5)).clamp(0.0, 1.0);

    // Breathing glow: oscillates between soft and bright
    final glowBlur = 12.0 + (glowProgress * 14.0);
    final glowSpread = glowProgress * 4.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: _pillWidth + 60, // extra room for ripple
        height: _height + 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Ripple layer ─────────────────────────────────────────────────
            if (rippleProgress > 0)
              Positioned.fill(
                child: CustomPaint(
                  painter: _RipplePaint(
                    progress: rippleProgress,
                    color: AppColors.primary,
                    maxRadius: (_pillWidth / 2) + 40,
                  ),
                ),
              ),

            // ── The button itself ─────────────────────────────────────────────
            AnimatedContainer(
              duration: Duration.zero,
              width: width,
              height: _height,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGlow,
                    blurRadius: glowBlur,
                    spreadRadius: glowSpread,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                // ── Icon + Text in a Row — no Stack tricks ─────────────────
                // As textOpacity goes 0→1 and button width shrinks,
                // the gap + text collapse naturally leaving the icon centered.
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.share_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      if (textOpacity > 0.0) ...[
                        // Gap shrinks as text fades
                        SizedBox(width: 8.0 * textOpacity),
                        Opacity(
                          opacity: textOpacity,
                          child: const Text(
                            'Share',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Inline ripple painter to keep ShareButton self-contained
class _RipplePaint extends CustomPainter {
  const _RipplePaint({
    required this.progress,
    required this.color,
    required this.maxRadius,
  });

  final double progress;
  final Color color;
  final double maxRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = maxRadius * progress;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: opacity * 0.22)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      center,
      radius * 1.12,
      Paint()
        ..color = color.withValues(alpha: opacity * 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_RipplePaint old) => old.progress != progress;
}

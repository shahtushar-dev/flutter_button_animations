import 'package:flutter/material.dart';

/// Paints an expanding ripple burst on tap.
///
/// [progress] drives both radius (0→maxRadius) and opacity fade (1→0).
/// Uses two layers: a filled inner circle + a faint outer ring stroke.
class RipplePainter extends CustomPainter {
  const RipplePainter({
    required this.progress,
    required this.color,
    required this.maxRadius,
  });

  final double progress;
  final Color color;
  final double maxRadius;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = maxRadius * progress;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    // Inner fill — soft and subtle
    final fillPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.25)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, fillPaint);

    // Outer ring — crisp edge
    final ringPaint = Paint()
      ..color = color.withValues(alpha: opacity * 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, radius * 1.15, ringPaint);
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

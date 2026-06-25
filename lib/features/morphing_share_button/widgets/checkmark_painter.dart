import 'package:flutter/material.dart';

/// Draws a checkmark stroke-by-stroke using [PathMetrics].
///
/// [progress] 0.0 → 1.0 draws the path incrementally,
/// giving the premium "pen drawing" effect.
class CheckmarkPainter extends CustomPainter {
  const CheckmarkPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 2.5,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.22;

    // Define checkmark with two segments:
    // Segment A: short down-left stroke (the "tick" base)
    // Segment B: longer up-right stroke (the main arm)
    final path = Path()
      ..moveTo(cx - r * 0.55, cy + r * 0.05)
      ..lineTo(cx - r * 0.05, cy + r * 0.55)
      ..lineTo(cx + r * 0.65, cy - r * 0.55);

    // Use PathMetrics to draw only [progress]% of the total path
    final metrics = path.computeMetrics().toList();
    final totalLength = metrics.fold<double>(
      0.0,
      (sum, m) => sum + m.length,
    );

    final drawUpTo = totalLength * progress;
    double drawn = 0.0;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final metric in metrics) {
      final remaining = drawUpTo - drawn;
      if (remaining <= 0) break;

      final segment = metric.extractPath(
        0,
        remaining.clamp(0.0, metric.length),
      );
      canvas.drawPath(segment, paint);
      drawn += metric.length;
    }
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

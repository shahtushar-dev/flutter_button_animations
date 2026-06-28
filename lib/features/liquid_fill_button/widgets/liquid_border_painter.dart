import 'package:flutter/material.dart';

/// Paints a stadium (pill) border that fills with color 
/// matching the exact liquid level.
class LiquidBorderPainter extends CustomPainter {
  const LiquidBorderPainter({
    required this.fillLevel,
    required this.emptyColor,
    required this.filledColor,
    required this.borderWidth,
  });

  final double fillLevel;
  final Color emptyColor;
  final Color filledColor;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2));

    // At 0% or 100%, we don't need a gradient, just a solid color for performance
    if (fillLevel <= 0.0) {
      _drawSolidBorder(canvas, rrect, emptyColor);
      return;
    }
    if (fillLevel >= 1.0) {
      _drawSolidBorder(canvas, rrect, filledColor);
      return;
    }

    // Calculate the exact pixel height where the liquid is currently sitting
    final liquidTop = size.height * (1.0 - fillLevel);

    // Create a hard-stop gradient that switches instantly from empty to filled color
    // exactly at the liquid's surface level.
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        emptyColor,
        emptyColor,
        filledColor,
        filledColor,
      ],
      stops: [
        0.0,
        liquidTop / size.height,
        liquidTop / size.height,
        1.0,
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawRRect(rrect, paint);
  }

  void _drawSolidBorder(Canvas canvas, RRect rrect, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(LiquidBorderPainter old) =>
      fillLevel != old.fillLevel ||
      emptyColor != old.emptyColor ||
      filledColor != old.filledColor ||
      borderWidth != old.borderWidth;
}

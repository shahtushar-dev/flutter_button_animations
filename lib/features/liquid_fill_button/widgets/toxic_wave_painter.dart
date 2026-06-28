import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Paints a thick, toxic sludge fill with bubbling physics.
class ToxicWavePainter extends CustomPainter {
  const ToxicWavePainter({
    required this.fillLevel,
    required this.wavePhase,
    required this.successProgress,
    required this.color,
  });

  final double fillLevel;
  final double wavePhase;
  final double successProgress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (fillLevel <= 0.001) return;

    final liquidTop = size.height * (1.0 - fillLevel);

    // Toxic sludge is thick and barely ripples, flattens out on success
    final amplitude = 3.0 * 
        (1.0 - fillLevel * 0.5).clamp(0.2, 1.0) *
        (1.0 - successProgress);

    // ── Dark Green Back Sludge ──────────────────────────────────────────────
    _drawSludge(
      canvas: canvas,
      size: size,
      liquidTop: liquidTop,
      amplitude: amplitude * 1.5,
      phaseOffset: wavePhase * 0.5, // Moves very slow
      paint: Paint()
        ..color = Color.lerp(const Color(0xFF00C853).withValues(alpha: 0.5), color.withValues(alpha: 0.5), successProgress)!
        ..style = PaintingStyle.fill,
    );

    // ── Bright Neon Green Front Sludge ──────────────────────────────────────
    _drawSludge(
      canvas: canvas,
      size: size,
      liquidTop: liquidTop,
      amplitude: amplitude,
      phaseOffset: wavePhase * -0.6,
      paint: Paint()
        ..color = Color.lerp(const Color(0xFF00E676), color, successProgress)!
        ..style = PaintingStyle.fill,
      drawGloss: true,
    );

    // ── Floating Toxic Bubbles ──────────────────────────────────────────────
    // Use the wavePhase to predictably spawn floating bubbles
    _drawBubbles(canvas, size, liquidTop);
  }

  void _drawSludge({
    required Canvas canvas,
    required Size size,
    required double liquidTop,
    required double amplitude,
    required double phaseOffset,
    required Paint paint,
    bool drawGloss = false,
  }) {
    final path = Path();
    final surfacePath = Path();

    path.moveTo(0, size.height);
    path.lineTo(0, liquidTop);

    final startY = liquidTop + amplitude * math.sin(phaseOffset);
    surfacePath.moveTo(0, startY);

    for (double x = 0; x <= size.width; x += 2.0) {
      final y = liquidTop + amplitude * math.sin((x / size.width * math.pi * 1.5) + phaseOffset);
      path.lineTo(x, y);
      surfacePath.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);

    if (drawGloss && fillLevel > 0.05 && fillLevel < 0.95) {
      final glossPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(surfacePath, glossPaint);
    }
  }

  void _drawBubbles(Canvas canvas, Size size, double liquidTop) {
    if (fillLevel < 0.1) return;
    
    final paint = Paint()
      ..color = const Color(0xFFB9F6CA).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Pseudo-random but deterministic bubbles based on the wavePhase time
    for (int i = 0; i < 6; i++) {
      // Fake random values using prime numbers
      final startX = (i * 37.0) % size.width;
      
      // Bubble rises based on wavePhase. (wavePhase goes 0 -> 2pi in 1.5s, meaning it loops rapidly)
      // To make bubbles travel all the way up continuously, we need a continuously growing time,
      // but wavePhase resets. For this aesthetic, we'll just loop them.
      // A trick to make it look continuous:
      final verticalProgress = ((wavePhase * (1.0 + i * 0.2)) / (math.pi * 2)) % 1.0;
      
      // Calculate Y from bottom of tank up to the liquid top
      final currentY = size.height - ((size.height - liquidTop) * verticalProgress);
      
      // Wobble X slightly
      final currentX = startX + math.sin(wavePhase * 2.0 + i) * 5.0;
      
      // Size fades out near the top
      final radius = (4.0 + (i % 3)) * (1.0 - verticalProgress);

      if (currentY > liquidTop + 2) {
        canvas.drawCircle(Offset(currentX, currentY), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(ToxicWavePainter old) =>
      fillLevel != old.fillLevel || 
      wavePhase != old.wavePhase ||
      successProgress != old.successProgress ||
      color != old.color;
}

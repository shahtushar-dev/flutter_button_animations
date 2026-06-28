import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Paints an animated, chaotic fire fill inside the button.
///
/// Uses overlapping sine waves with heavily randomized/chaotic
/// frequencies to simulate the sharp, jagged edges of flames.
class FireWavePainter extends CustomPainter {
  const FireWavePainter({
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

    // Flames flatten out during the success state
    final amplitude = 12.0 * 
        (1.0 - fillLevel * 0.5).clamp(0.2, 1.0) *
        (1.0 - successProgress);

    // ── Deep Red (Background Flames) ─────────────────────────────────────────
    _drawFlames(
      canvas: canvas,
      size: size,
      liquidTop: liquidTop - amplitude * 0.5,
      amplitude: amplitude * 1.5,
      phaseOffset: wavePhase * 1.5,
      complexity: 4.0,
      paint: Paint()
        ..color = Color.lerp(const Color(0xFFD32F2F), color, successProgress)!
        ..style = PaintingStyle.fill,
    );

    // ── Bright Orange (Mid Flames) ─────────────────────────────────────────
    _drawFlames(
      canvas: canvas,
      size: size,
      liquidTop: liquidTop,
      amplitude: amplitude * 1.2,
      phaseOffset: wavePhase * -1.2 + math.pi, // Move opposite direction
      complexity: 3.5,
      paint: Paint()
        ..color = Color.lerp(const Color(0xFFFF5722), color, successProgress)!
        ..style = PaintingStyle.fill,
    );

    // ── Yellow/White (Front Hot Flames) ─────────────────────────────────────
    _drawFlames(
      canvas: canvas,
      size: size,
      liquidTop: liquidTop + amplitude * 0.5,
      amplitude: amplitude * 0.8,
      phaseOffset: wavePhase * 2.0,
      complexity: 5.0,
      paint: Paint()
        ..color = Color.lerp(const Color(0xFFFFC107), color, successProgress)!
        ..style = PaintingStyle.fill,
      drawGloss: true,
    );
  }

  void _drawFlames({
    required Canvas canvas,
    required Size size,
    required double liquidTop,
    required double amplitude,
    required double phaseOffset,
    required double complexity,
    required Paint paint,
    bool drawGloss = false,
  }) {
    final path = Path();
    final surfacePath = Path();

    path.moveTo(0, size.height);
    path.lineTo(0, liquidTop);

    // Initial Y for surface path
    final initialWave1 = math.sin(phaseOffset);
    final initialWave2 = math.cos(-phaseOffset * 1.5) * 0.5;
    final initialWave3 = math.sin(phaseOffset * 2.0) * 0.25;
    final initialY = liquidTop + amplitude * -(initialWave1 + initialWave2 + initialWave3).abs();
    surfacePath.moveTo(0, initialY);

    for (double x = 0; x <= size.width; x += 2.0) {
      final normalizedX = x / size.width;
      
      final wave1 = math.sin(normalizedX * math.pi * complexity + phaseOffset);
      final wave2 = math.cos(normalizedX * math.pi * (complexity * 2.5) - phaseOffset * 1.5) * 0.5;
      final wave3 = math.sin(normalizedX * math.pi * (complexity * 4.0) + phaseOffset * 2.0) * 0.25;

      final combinedWave = -(wave1 + wave2 + wave3).abs();
      final y = liquidTop + amplitude * combinedWave;
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

  @override
  bool shouldRepaint(FireWavePainter old) =>
      fillLevel != old.fillLevel || 
      wavePhase != old.wavePhase ||
      successProgress != old.successProgress ||
      color != old.color;
}

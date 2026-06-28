import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Paints the animated liquid wave fill inside the button.
///
/// Uses two layered sine waves (a back wave at lower opacity and a front
/// wave at full opacity) to create an organic, liquid depth effect.
///
/// [fillLevel] 0.0 = empty, 1.0 = fully filled.
/// [wavePhase] continuously increments from the wave controller loop,
/// causing the wave to travel across the surface.
class LiquidWavePainter extends CustomPainter {
  const LiquidWavePainter({
    required this.fillLevel,
    required this.wavePhase,
    required this.successProgress,
    required this.color,
  });

  final double fillLevel;
  final double wavePhase;
  final double successProgress;
  final Color color;

  // Visual tuning constants
  static const double _maxAmplitude = 8.0; // Increased for taller, more aggressive sea waves
  static const double _waveFrequencyFactor = 3.5; // Increased for more wave peaks across the button

  @override
  void paint(Canvas canvas, Size size) {
    if (fillLevel <= 0.001) return;

    // Liquid surface Y coordinate (top of the liquid pool).
    // At fillLevel=0, liquidTop = size.height (bottom). At 1, it = 0 (top).
    final liquidTop = size.height * (1.0 - fillLevel);

    // Amplitude shrinks as the button fills up, so the surface calms down.
    // It also flattens out entirely based on successProgress (inertia at 100%).
    final amplitude = _maxAmplitude * 
        (1.0 - fillLevel * 0.85).clamp(0.1, 1.0) *
        (1.0 - successProgress);

    // ── Back wave ───────────────────────────────────────────────────────────
    // Offset by π to travel in the opposite direction, creating depth.
    _drawWave(
      canvas: canvas,
      size: size,
      liquidTop: liquidTop,
      amplitude: amplitude,
      phaseOffset: wavePhase + math.pi,
      paint: Paint()
        ..color = color.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill,
    );

    // ── Front wave (primary) ────────────────────────────────────────────────
    _drawWave(
      canvas: canvas,
      size: size,
      liquidTop: liquidTop,
      amplitude: amplitude,
      phaseOffset: wavePhase,
      paint: Paint()
        ..color = color
        ..style = PaintingStyle.fill,
      drawGloss: true,
    );
  }

  void _drawWave({
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

    // Initial Y for the surface path
    final startSinInput = phaseOffset;
    final startY = liquidTop + amplitude * math.sin(startSinInput);
    surfacePath.moveTo(0, startY);

    // Step across the width, sampling the sine function for each pixel.
    // Using step=1.5 for perfect smoothness with minimal CPU overhead.
    for (double x = 0; x <= size.width; x += 1.5) {
      final sinInput =
          (x / size.width * _waveFrequencyFactor * math.pi * 2) + phaseOffset;
      final y = liquidTop + amplitude * math.sin(sinInput);
      path.lineTo(x, y);
      surfacePath.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    
    // Draw the liquid body
    canvas.drawPath(path, paint);

    // Draw the surface reflection highlight
    if (drawGloss && fillLevel > 0.05 && fillLevel < 0.95) {
      final glossPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(surfacePath, glossPaint);
    }
  }

  @override
  bool shouldRepaint(LiquidWavePainter old) =>
      fillLevel != old.fillLevel ||
      wavePhase != old.wavePhase ||
      successProgress != old.successProgress ||
      color != old.color;
}

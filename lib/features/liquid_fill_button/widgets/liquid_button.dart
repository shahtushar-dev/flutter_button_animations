import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/download_state.dart';
import '../models/fill_style.dart';
import 'liquid_wave_painter.dart';
import 'fire_wave_painter.dart';
import 'toxic_wave_painter.dart';
import 'liquid_border_painter.dart';
import '../../morphing_share_button/widgets/checkmark_painter.dart';
import 'dart:math' as math;

import '../animations/liquid_animation.dart';

/// The interactive Liquid Download Button widget.
///
/// Handles the visual representation and state machine for a simulated download.
class LiquidButton extends StatefulWidget {
  const LiquidButton({
    super.key,
    required this.style,
  });

  /// The styling variation (water, fire, toxic)
  final FillStyle style;

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton> with TickerProviderStateMixin {
  // ── State ───────────────────────────────────────────────────────────────────
  DownloadState _state = DownloadState.idle;

  // ── Controllers ─────────────────────────────────────────────────────────────
  late final AnimationController _fillController;
  late final AnimationController _waveController;
  late final AnimationController _bounceController;

  late final LiquidAnimations _liquidAnims;
  late final Animation<double> _bounceAnim;
  late final Animation<double> _successAnim;

  static const double _buttonWidth = 220.0;
  static const double _buttonHeight = 64.0;

  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  void _setupControllers() {
    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500), // Increased from 3.5s to 5.5s
    );
    _liquidAnims = LiquidAnimations.from(_fillController);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), // Increased from 1.5s to 2.5s
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Increased from 400ms to 600ms
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0).chain(CurveTween(curve: Curves.bounceOut)), weight: 60),
    ]).animate(_bounceController);

    _successAnim = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fillController.dispose();
    _waveController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _startDownload() async {
    if (_state != DownloadState.idle) return;

    setState(() => _state = DownloadState.filling);

    _waveController.repeat();
    await _fillController.forward();

    if (!mounted) return;
    
    setState(() => _state = DownloadState.complete);
    
    await _bounceController.forward(from: 0.0);

    await Future.delayed(const Duration(seconds: 3)); // Hold for 3s instead of 2s
    if (!mounted) return;

    _waveController.stop();
    _fillController.reset();
    _bounceController.reset(); // Reset success animation
    setState(() => _state = DownloadState.idle);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _fillController,
        _waveController,
        _bounceController,
      ]),
      builder: (context, _) {
        final fillLevel = _liquidAnims.fillProgress.value;
        final wavePhase = _waveController.value * 6.28318;
        final labelOpacity = 1.0 - _liquidAnims.labelFadeOut.value;
        final buttonScale = _bounceAnim.value;

        final isIdle = _state == DownloadState.idle;
        final Color themeColor = switch (widget.style) {
          FillStyle.water => const Color(0xFF6C63FF),
          FillStyle.fire => const Color(0xFFFF5722),
          FillStyle.toxic => const Color(0xFF00E676),
        };
        // Pressure physics: The button slightly bulges as it fills, releasing at 100%
        final pressureScale = 1.0 + (math.sin(fillLevel * math.pi) * 0.03);
        final finalScale = buttonScale * pressureScale;

        final borderWidth = isIdle ? 1.0 : 2.5;

    return GestureDetector(
      onTap: _startDownload,
      behavior: HitTestBehavior.opaque,
      child: Transform.scale(
        scale: finalScale,
        child: CustomPaint(
          foregroundPainter: LiquidBorderPainter(
            fillLevel: fillLevel,
            emptyColor: AppColors.primaryDim,
            filledColor: themeColor,
            borderWidth: borderWidth,
          ),
          child: Container(
            width: _buttonWidth,
            height: _buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_buttonHeight / 2),
              // Slight glow when complete
            boxShadow: _state == DownloadState.complete
                ? [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_buttonHeight / 2 - borderWidth),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── The Fill Animation ─────────────────────────────────────────
                if (_state != DownloadState.idle)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: switch (widget.style) {
                        FillStyle.water => LiquidWavePainter(
                            fillLevel: fillLevel,
                            wavePhase: wavePhase,
                            successProgress: _successAnim.value,
                            color: themeColor,
                          ),
                        FillStyle.fire => FireWavePainter(
                            fillLevel: fillLevel,
                            wavePhase: wavePhase,
                            successProgress: _successAnim.value,
                            color: themeColor,
                          ),
                        FillStyle.toxic => ToxicWavePainter(
                            fillLevel: fillLevel,
                            wavePhase: wavePhase,
                            successProgress: _successAnim.value,
                            color: themeColor,
                          ),
                      },
                    ),
                  ),

                // ── Idle State Content ──────────────────────────────────────
                if (labelOpacity > 0.0)
                  Opacity(
                    opacity: labelOpacity,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_download_outlined,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Download',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Filling State Progress Text ─────────────────────────────
                if (_state == DownloadState.filling && labelOpacity == 0.0)
                  Text(
                    '${(fillLevel * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),

                // ── Complete State Checkmark ────────────────────────────────
                if (_state == DownloadState.complete)
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CustomPaint(
                          painter: CheckmarkPainter(
                            progress: 1.0,
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Completed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      ), // close GestureDetector
    ); // close return statement
      },
    );
  }
}

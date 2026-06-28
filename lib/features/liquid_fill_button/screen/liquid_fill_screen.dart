import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/download_state.dart';
import '../models/fill_style.dart';
import '../animations/liquid_animation.dart';
import '../widgets/liquid_button.dart';

/// Episode 02 — Liquid Fill Button
///
/// Orchestrates the animation state machine for a simulated download.
/// Uses multiple [AnimationController]s:
/// - [_fillController]: drives the 0→100% progress and label fade.
/// - [_waveController]: continuously loops to drive the sine wave phase.
/// - [_bounceController]: triggers the success pop when download completes.
class LiquidFillScreen extends StatelessWidget {
  const LiquidFillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBackground(),
          _buildHeader(),
          Center(child: _buildAnimationStage()),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              const Color(0xFF6C63FF).withValues(alpha: 0.1),
              AppColors.background,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Text(
                'Episode 02',
                style: TextStyle(
                  color: Color(0xFF6C63FF),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Elemental\nDownload Button',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Physics · CustomPainters · Morphing',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationStage() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LiquidButton(style: FillStyle.water),
        SizedBox(height: 32),
        LiquidButton(style: FillStyle.fire),
        SizedBox(height: 32),
        LiquidButton(style: FillStyle.toxic),
      ],
    );
  }
}

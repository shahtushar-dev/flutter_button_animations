import 'package:flutter/material.dart';
import '../models/share_platform.dart';
import '../widgets/share_icon_item.dart';
import '../widgets/checkmark_painter.dart';
import '../../../../core/constants/app_colors.dart';

/// The expanded share hub — central circle + 4 arc-positioned icons.
///
/// Also handles the confirming state (checkmark drawing).
/// All animation values are passed in from the parent screen
/// so this widget stays purely presentational.
class ShareHub extends StatelessWidget {
  const ShareHub({
    super.key,
    required this.hubScale,
    required this.glowProgress,
    required this.iconProgress,
    required this.selectedPlatform,
    required this.checkmarkProgress,
    required this.checkmarkCircleScale,
    required this.checkmarkOpacity,
    required this.dropProgress,
    required this.isConfirming,
    required this.onPlatformSelected,
  });

  /// 0.0→1.0 scale of the central hub circle
  final double hubScale;

  /// Breathing glow intensity
  final double glowProgress;

  /// Per-platform icon animation progress
  final Map<SharePlatform, double> iconProgress;

  /// Currently selected platform (null = none)
  final SharePlatform? selectedPlatform;

  /// Checkmark stroke draw progress
  final double checkmarkProgress;

  /// Checkmark circle scale (0→1)
  final double checkmarkCircleScale;

  /// Checkmark overall opacity (for fade-out on reset)
  final double checkmarkOpacity;

  /// Drop progress (0→1) of the selected icon
  final double dropProgress;

  /// Whether we are in the confirming state
  final bool isConfirming;

  final ValueChanged<SharePlatform> onPlatformSelected;

  static const double _hubSize = 58.0;
  static const double _arcRadius = 105.0;

  @override
  Widget build(BuildContext context) {
    final isAnySelected = selectedPlatform != null;

    // Glow color shifts to selected platform brand color
    final glowColor = isAnySelected
        ? selectedPlatform!.glowColor
        : AppColors.primaryGlow;

    final hubColor = isAnySelected
        ? Color.lerp(AppColors.primary, selectedPlatform!.brandColor, 0.4)!
        : AppColors.primary;

    final glowBlur = 14.0 + glowProgress * 12.0;

    return SizedBox(
      // Large enough to contain the full arc + labels
      width: (_arcRadius + _hubSize) * 2 + 60,
      height: (_arcRadius + _hubSize) * 2 + 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Social platform icons (arc) ──────────────────────────────────
          ...[
            ...SharePlatform.values.where((p) => p != selectedPlatform),
            if (selectedPlatform != null) selectedPlatform!,
          ].map(
            (platform) => ShareIconItem(
              platform: platform,
              progress: iconProgress[platform] ?? 0.0,
              arcRadius: _arcRadius,
              isSelected: selectedPlatform == platform,
              isAnySelected: isAnySelected,
              onTap: () => onPlatformSelected(platform),
            ),
          ),

          // ── Central hub circle ───────────────────────────────────────────
          if (!isConfirming)
            Transform.scale(
              scale: hubScale,
              child: Container(
                width: _hubSize,
                height: _hubSize,
                decoration: BoxDecoration(
                  color: hubColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: glowColor,
                      blurRadius: glowBlur,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.share_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),

          // ── Checkmark confirm state ──────────────────────────────────────
          if (isConfirming)
            Opacity(
              opacity: (1.0 - checkmarkOpacity).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: checkmarkCircleScale,
                child: Container(
                  width: _hubSize,
                  height: _hubSize,
                  decoration: BoxDecoration(
                    color: isAnySelected
                        ? Color.lerp(AppColors.primary, selectedPlatform!.brandColor, dropProgress)
                        : AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isAnySelected
                            ? Color.lerp(AppColors.primaryGlow, selectedPlatform!.glowColor, dropProgress)!
                            : AppColors.primaryGlow,
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: CheckmarkPainter(
                      progress: checkmarkProgress,
                      color: Colors.white,
                      strokeWidth: 2.4,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

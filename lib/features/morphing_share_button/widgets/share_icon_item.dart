import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/share_platform.dart';
import '../../../../core/constants/app_colors.dart';

/// A single social platform icon rendered in its arc position.
///
/// Handles its own scale + position animation via [progress]
/// and selection highlight.
class ShareIconItem extends StatelessWidget {
  const ShareIconItem({
    super.key,
    required this.platform,
    required this.progress,
    required this.arcRadius,
    required this.isSelected,
    required this.isAnySelected,
    required this.onTap,
  });

  final SharePlatform platform;

  /// 0.0 = collapsed at center  →  1.0 = at arc position (also drives scale/opacity)
  final double progress;

  /// Radius of the arc in logical pixels
  final double arcRadius;

  /// Whether this specific icon is the selected one
  final bool isSelected;

  /// Whether ANY icon is selected (used to dim others)
  final bool isAnySelected;

  final VoidCallback onTap;

  static const double _iconContainerSize = 54.0;
  static const double _selectedScaleFactor = 1.18;

  @override
  Widget build(BuildContext context) {
    final angleRad = platform.arcAngleDeg * (math.pi / 180.0);

    // Arc position offset from center
    final dx = arcRadius * math.cos(angleRad) * progress;
    final dy = arcRadius * math.sin(angleRad) * progress;

    // Scale: start at 1.0, they are physically hidden behind the center button
    final scale = 1.0;

    // Opacity: always fully opaque
    final opacity = 1.0;

    // Brand color fills on selection, white icon otherwise
    final iconColor = isSelected ? Colors.white : Colors.white;
    final containerColor =
        isSelected ? platform.brandColor : AppColors.primary;

    final selectedScale = isSelected ? _selectedScaleFactor : 1.0;

    return Transform.translate(
      offset: Offset(dx, dy),
      child: AnimatedOpacity(
        opacity: opacity.clamp(0.0, 1.0),
        duration: const Duration(milliseconds: 200),
        child: Transform.scale(
          scale: scale * selectedScale,
          child: _IconCircle(
            platform: platform,
            size: _iconContainerSize,
            color: containerColor,
            iconColor: iconColor,
            isSelected: isSelected,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

/// The circular icon container.
class _IconCircle extends StatelessWidget {
  const _IconCircle({
    required this.platform,
    required this.size,
    required this.color,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  final SharePlatform platform;
  final double size;
  final Color color;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: platform.glowColor,
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.primaryGlow,
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.26), // slightly more padding for the PNGs
          child: Image.asset(
            platform.assetPath,
            color: iconColor,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

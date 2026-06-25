import 'package:flutter/animation.dart';
import '../models/share_platform.dart';

/// All animation objects for the icon expansion phase.
///
/// Each platform icon has its own staggered [Animation<double>] (0→1)
/// representing combined scale + position progress. Labels fade in
/// after all icons have settled.
final class ExpansionAnimations {
  ExpansionAnimations._({
    required this.iconProgress,
    required this.hubGlowIntensity,
    required this.centralCircleScale,
  });

  factory ExpansionAnimations.from(AnimationController controller) {
    // Stagger: each icon starts 0.08 later than the previous.
    // Increased duration to make the pop-out much smoother and visible.
    const baseStart = 0.30;
    const baseDuration = 0.45;
    const stagger = 0.08;

    final platforms = SharePlatform.values;
    final iconProgress = <SharePlatform, Animation<double>>{};

    for (var i = 0; i < platforms.length; i++) {
      final start = baseStart + i * stagger;
      final end = (start + baseDuration).clamp(0.0, 1.0);
      iconProgress[platforms[i]] = CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeOutBack),
      );
    }

    return ExpansionAnimations._(
      iconProgress: iconProgress,
      // Hub glow pulses in once circle is formed.
      hubGlowIntensity: CurvedAnimation(
        parent: controller,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
      ),
      // Central circle scales from morph end to settled hub size.
      centralCircleScale: CurvedAnimation(
        parent: controller,
        curve: const Interval(0.30, 0.50, curve: Curves.easeOutBack),
      ),
    );
  }

  /// Per-platform animation: 0.0 = at center  →  1.0 = at arc position.
  /// Also drives scale (0→1) and opacity (0→1).
  final Map<SharePlatform, Animation<double>> iconProgress;

  /// Glow intensity around the central hub
  final Animation<double> hubGlowIntensity;

  /// Scale of the central circle hub
  final Animation<double> centralCircleScale;
}

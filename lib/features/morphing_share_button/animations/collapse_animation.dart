import 'package:flutter/animation.dart';

/// All animation objects for the collapse + checkmark confirm phase.
///
/// Driven by its own dedicated [AnimationController] since the
/// collapse is a separate interaction from the open sequence.
final class CollapseAnimations {
  CollapseAnimations._({
    required this.checkmarkCircleScale,
    required this.checkmarkPathProgress,
    required this.checkmarkOpacity,
  });

  factory CollapseAnimations.from(AnimationController controller) {
    return CollapseAnimations._(
      // Circle pops in with spring overshoot.
      checkmarkCircleScale: CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOutBack),
      ),
      // Checkmark stroke draws from 0% to 100% of path length.
      checkmarkPathProgress: CurvedAnimation(
        parent: controller,
        curve: const Interval(0.30, 0.85, curve: Curves.easeInOut),
      ),
      // Entire checkmark fades out before reset.
      checkmarkOpacity: CurvedAnimation(
        parent: controller,
        curve: const Interval(0.88, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  /// 0.0 = invisible  →  1.0 = full circle (with spring)
  final Animation<double> checkmarkCircleScale;

  /// 0.0 = no stroke  →  1.0 = complete checkmark drawn
  final Animation<double> checkmarkPathProgress;

  /// 1.0 = visible  →  0.0 = faded (for reset transition)
  final Animation<double> checkmarkOpacity;
}

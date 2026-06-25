import 'package:flutter/animation.dart';

/// All animation objects for the pill → circle morph phase.
///
/// Driven by a single [AnimationController] via [Interval]s so that
/// only one controller is needed for the entire open sequence.
final class MorphAnimations {
  MorphAnimations._({
    required this.widthFactor,
    required this.textOpacity,
    required this.borderRadius,
    required this.iconCenterOffset,
  });

  factory MorphAnimations.from(AnimationController controller) {
    return MorphAnimations._(
      // Width collapses from full pill to circle size.
      widthFactor: CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.38, curve: Curves.easeInOutCubic),
      ),
      // Text fades faster — gone before circle is complete.
      textOpacity: CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.18, curve: Curves.easeIn),
      ),
      // Border radius animates from pill (small relative) to circle (50%).
      borderRadius: CurvedAnimation(
        parent: controller,
        curve: const Interval(0.05, 0.38, curve: Curves.easeInOutCubic),
      ),
      // Share icon nudges to exact center as width collapses.
      iconCenterOffset: CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.38, curve: Curves.easeInOut),
      ),
    );
  }

  /// 0.0 = full pill width  →  1.0 = circle width
  final Animation<double> widthFactor;

  /// 1.0 = visible  →  0.0 = hidden
  final Animation<double> textOpacity;

  /// 0.0 = pill corner radius  →  1.0 = full circle
  final Animation<double> borderRadius;

  /// Tracks share icon centering during shrink
  final Animation<double> iconCenterOffset;
}

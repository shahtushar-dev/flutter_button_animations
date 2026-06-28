import 'package:flutter/animation.dart';

/// All animation objects for the Liquid Fill Button.
///
/// Driven by a single [AnimationController] that goes 0→1
/// representing the fill progression from empty to full.
final class LiquidAnimations {
  LiquidAnimations._({
    required this.fillProgress,
    required this.labelFadeOut,
  });

  factory LiquidAnimations.from(AnimationController controller) {
    // Simulate realistic network download: fast start, slow middle, pause, fast finish
    final fillSequence = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.35).chain(CurveTween(curve: Curves.easeOut)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.35, end: 0.45).chain(CurveTween(curve: Curves.easeInOut)), weight: 40),
      TweenSequenceItem(tween: ConstantTween(0.45), weight: 10), // The pause
      TweenSequenceItem(tween: Tween(begin: 0.45, end: 0.85).chain(CurveTween(curve: Curves.fastOutSlowIn)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 10),
    ]);

    return LiquidAnimations._(
      fillProgress: fillSequence.animate(controller),
      // Label fades out in the first 20% of the fill animation.
      labelFadeOut: CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.20, curve: Curves.easeOut),
      ),
    );
  }

  /// 0.0 = empty  →  1.0 = completely full
  final Animation<double> fillProgress;

  /// 0.0 = label invisible  →  1.0 = label fully visible
  /// (inverted: use `1 - labelFadeOut.value` to get visible opacity)
  final Animation<double> labelFadeOut;
}

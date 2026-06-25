/// Centralized animation durations.
/// Single source of truth — change here and it propagates everywhere.
abstract final class AppDurations {
  // ─── Morphing Share Button ───────────────────────────────────────────────────
  static const Duration glowPulse = Duration(milliseconds: 2000);
  static const Duration morphExpand = Duration(milliseconds: 1300);
  static const Duration selectionFeedback = Duration(milliseconds: 350);
  static const Duration checkmarkDraw = Duration(milliseconds: 650);
  static const Duration rippleBurst = Duration(milliseconds: 450);
  static const Duration dropIcon = Duration(milliseconds: 400);
  static const Duration confirmHold = Duration(milliseconds: 1400);
  static const Duration resetDelay = Duration(milliseconds: 600);
}

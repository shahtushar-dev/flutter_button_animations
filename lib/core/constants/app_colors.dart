import 'package:flutter/material.dart';

/// Centralized color palette for the entire app.
/// All colors are defined as static constants for compile-time safety.
abstract final class AppColors {
  // ─── Backgrounds ────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceElevated = Color(0xFF222222);

  // ─── Primary brand ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF00E5A0);
  static const Color primaryGlow = Color(0x5500E5A0);
  static const Color primaryDim = Color(0x2200E5A0);

  // ─── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color textTertiary = Color(0xFF4A4A4A);

  // ─── UI chrome ──────────────────────────────────────────────────────────────
  static const Color border = Color(0xFF252525);
  static const Color divider = Color(0xFF1E1E1E);

  // ─── Platform brand colors ───────────────────────────────────────────────────
  static const Color whatsApp = Color(0xFF25D366);
  static const Color facebook = Color(0xFF1877F2);
  static const Color twitterX = Color(0xFFE7E7E7);
  static const Color linkedIn = Color(0xFF0A66C2);

  // ─── Glows for platform colors ───────────────────────────────────────────────
  static const Color whatsAppGlow = Color(0x4425D366);
  static const Color facebookGlow = Color(0x441877F2);
  static const Color twitterXGlow = Color(0x44E7E7E7);
  static const Color linkedInGlow = Color(0x440A66C2);
}

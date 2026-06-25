import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Represents a social sharing platform with all its metadata.
enum SharePlatform {
  facebook,
  whatsApp,
  twitterX,
  linkedIn;

  String get assetPath => switch (this) {
        SharePlatform.facebook => 'assets/facebook.png',
        SharePlatform.whatsApp => 'assets/whatsapp.png',
        SharePlatform.twitterX => 'assets/twitter.png',
        SharePlatform.linkedIn => 'assets/linkedin.png',
      };

  Color get brandColor => switch (this) {
        SharePlatform.facebook => AppColors.facebook,
        SharePlatform.whatsApp => AppColors.whatsApp,
        SharePlatform.twitterX => AppColors.twitterX,
        SharePlatform.linkedIn => AppColors.linkedIn,
      };

  Color get glowColor => switch (this) {
        SharePlatform.facebook => AppColors.facebookGlow,
        SharePlatform.whatsApp => AppColors.whatsAppGlow,
        SharePlatform.twitterX => AppColors.twitterXGlow,
        SharePlatform.linkedIn => AppColors.linkedInGlow,
      };

  /// Angle in degrees for positioning.
  /// 180 is left, 270 is top, 0/360 is right.
  /// By spanning 210 to 330, they form an arc *above* the central button.
  double get arcAngleDeg => switch (this) {
        SharePlatform.facebook => 210.0,
        SharePlatform.whatsApp => 250.0,
        SharePlatform.twitterX => 290.0,
        SharePlatform.linkedIn => 330.0,
      };
}

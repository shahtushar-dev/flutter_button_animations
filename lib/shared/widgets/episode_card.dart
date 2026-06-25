import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Metadata for a single animation episode.
///
/// Used by [HomeScreen] to render the episode grid.
/// Adding a new episode = create one [EpisodeMeta] + add to the list.
class EpisodeMeta {
  const EpisodeMeta({
    required this.episodeNumber,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.screen,
    this.isComingSoon = false,
  });

  final int episodeNumber;
  final String title;
  final String subtitle;
  final Color accentColor;
  final Widget screen;
  final bool isComingSoon;
}

/// Episode card displayed on the home screen grid.
class EpisodeCard extends StatefulWidget {
  const EpisodeCard({
    super.key,
    required this.meta,
  });

  final EpisodeMeta meta;

  @override
  State<EpisodeCard> createState() => _EpisodeCardState();
}

class _EpisodeCardState extends State<EpisodeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _hoverController.forward();
  void _onTapUp(_) => _hoverController.reverse();
  void _onTapCancel() => _hoverController.reverse();

  void _navigate() {
    if (widget.meta.isComingSoon) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => widget.meta.screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = widget.meta;

    return GestureDetector(
      onTap: _navigate,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Color.lerp(
                    AppColors.border,
                    meta.accentColor.withValues(alpha: 0.5),
                    _glowAnim.value,
                  )!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: meta.accentColor
                        .withValues(alpha: 0.08 + _glowAnim.value * 0.12),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Episode number + status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ep ${meta.episodeNumber.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: meta.accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (meta.isComingSoon)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Soon',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: meta.accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: meta.accentColor.withValues(alpha: 0.5),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              // Accent bar
              Container(
                width: 24,
                height: 2.5,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: meta.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Text(
                meta.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),

              // Subtitle
              Text(
                meta.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),

              if (!meta.isComingSoon) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Try it',
                      style: TextStyle(
                        color: meta.accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: meta.accentColor,
                      size: 11,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../features/morphing_share_button/screen/morphing_share_screen.dart';
import 'episode_card.dart';

/// The showcase home screen.
///
/// Displays all animation episodes as a grid of [EpisodeCard]s.
/// Adding a new episode: create its screen, add an [EpisodeMeta] to [_episodes].
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<EpisodeMeta> _episodes = [
    EpisodeMeta(
      episodeNumber: 1,
      title: 'Morphing Share Button',
      subtitle: 'Pill morphs into social share hub with arc icons',
      accentColor: AppColors.primary,
      screen: MorphingShareScreen(),
    ),
    EpisodeMeta(
      episodeNumber: 2,
      title: 'Liquid Fill Button',
      subtitle: 'ClipPath wave animation fills the button on press',
      accentColor: Color(0xFF6C63FF),
      screen: SizedBox.shrink(),
      isComingSoon: true,
    ),
    EpisodeMeta(
      episodeNumber: 3,
      title: 'Magnetic Hover',
      subtitle: 'Button follows your finger using spring physics',
      accentColor: Color(0xFFFF6B6B),
      screen: SizedBox.shrink(),
      isComingSoon: true,
    ),
    EpisodeMeta(
      episodeNumber: 4,
      title: 'Particle Burst',
      subtitle: 'Tap triggers a physics-based particle explosion',
      accentColor: Color(0xFFFFB347),
      screen: SizedBox.shrink(),
      isComingSoon: true,
    ),
    EpisodeMeta(
      episodeNumber: 5,
      title: '3D Flip Button',
      subtitle: 'Matrix4 perspective flip reveals hidden state',
      accentColor: Color(0xFF4FC3F7),
      screen: SizedBox.shrink(),
      isComingSoon: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildEpisodeGrid(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverSafeArea(
      bottom: false,
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDim,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.animation_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Code In Motion',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Title
              const Text(
                'Button\nAnimations',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pure Flutter SDK · No packages · 60fps',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEpisodeGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => EpisodeCard(meta: _episodes[index]),
          childCount: _episodes.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 40, 24, 40),
        child: Column(
          children: [
            Divider(color: AppColors.divider),
            SizedBox(height: 20),
            Text(
              'New episodes added regularly.\nFollow @codeinmotionlabs for updates.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
                height: 1.6,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

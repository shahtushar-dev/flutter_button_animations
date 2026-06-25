import 'package:flutter/material.dart';
import '../animations/morph_animation.dart';
import '../animations/expansion_animation.dart';
import '../animations/collapse_animation.dart';
import '../models/share_platform.dart';
import '../widgets/share_button.dart';
import '../widgets/share_hub.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_durations.dart';

/// The five distinct states of the share button lifecycle.
enum _ShareState { idle, morphing, expanded, selected, confirming }

/// Episode 01 — Morphing Share Button
///
/// Orchestrates four [AnimationController]s:
/// - [_glowController]    : looping idle breathing glow
/// - [_morphController]   : pill → circle → icons expanded
/// - [_selectionController]: selection feedback per icon tap
/// - [_checkmarkController]: checkmark stroke draw + fade
///
/// All animation *objects* are lazily built via the animation bundle
/// classes in /animations/, keeping this screen focused on coordination.
class MorphingShareScreen extends StatefulWidget {
  const MorphingShareScreen({super.key});

  @override
  State<MorphingShareScreen> createState() => _MorphingShareScreenState();
}

class _MorphingShareScreenState extends State<MorphingShareScreen>
    with TickerProviderStateMixin {
  // ── State ───────────────────────────────────────────────────────────────────
  _ShareState _state = _ShareState.idle;
  SharePlatform? _selectedPlatform;

  // ── Controllers ─────────────────────────────────────────────────────────────

  /// Continuous idle glow pulse — loops forever
  late final AnimationController _glowController;

  /// Main open/close animation (pill ↔ expanded hub)
  late final AnimationController _morphController;

  /// Brief selection feedback on icon tap
  late final AnimationController _selectionController;

  /// Draws checkmark + fades out before reset
  late final AnimationController _checkmarkController;

  // ── Animation bundles ───────────────────────────────────────────────────────
  late final MorphAnimations _morphAnims;
  late final ExpansionAnimations _expansionAnims;
  late final CollapseAnimations _collapseAnims;

  // ── Ripple ───────────────────────────────────────────────────────────────────
  late final AnimationController _rippleController;
  late final Animation<double> _rippleAnim;

  // ── Drop Selected Icon ───────────────────────────────────────────────────────
  late final AnimationController _dropController;
  late final Animation<double> _dropAnim;

  // ── Glow ────────────────────────────────────────────────────────────────────
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _setupControllers();
    _setupAnimations();
    // Start idle glow immediately
    _glowController.repeat(reverse: true);
  }

  void _setupControllers() {
    _glowController = AnimationController(
      vsync: this,
      duration: AppDurations.glowPulse,
    );

    _morphController = AnimationController(
      vsync: this,
      duration: AppDurations.morphExpand,
    );

    _selectionController = AnimationController(
      vsync: this,
      duration: AppDurations.selectionFeedback,
    );

    _checkmarkController = AnimationController(
      vsync: this,
      duration: AppDurations.checkmarkDraw,
    );

    _dropController = AnimationController(
      vsync: this,
      duration: AppDurations.dropIcon,
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: AppDurations.rippleBurst,
    );
  }

  void _setupAnimations() {
    _morphAnims = MorphAnimations.from(_morphController);
    _expansionAnims = ExpansionAnimations.from(_morphController);
    _collapseAnims = CollapseAnimations.from(_checkmarkController);

    _glowAnim = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    );

    _dropAnim = CurvedAnimation(
      parent: _dropController,
      curve: Curves.easeInBack, // Starts slow, speeds up and dives in
    );

    _rippleAnim = CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _morphController.dispose();
    _selectionController.dispose();
    _checkmarkController.dispose();
    _dropController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  // ── Interaction Handlers ────────────────────────────────────────────────────

  Future<void> _onShareButtonTapped() async {
    if (_state != _ShareState.idle) return;

    // 1. Trigger ripple burst
    _rippleController
      ..reset()
      ..forward();

    setState(() => _state = _ShareState.morphing);

    // 2. Morph + expand
    await _morphController.forward();

    if (mounted) setState(() => _state = _ShareState.expanded);
  }

  Future<void> _onPlatformSelected(SharePlatform platform) async {
    if (_state == _ShareState.selected || _state == _ShareState.confirming) {
      return;
    }

    setState(() {
      _selectedPlatform = platform;
      _state = _ShareState.selected;
    });

    // Brief selection hold — visually shows selection highlight
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    await _startConfirmSequence();
  }

  Future<void> _startConfirmSequence() async {
    setState(() => _state = _ShareState.confirming);

    // 1. Vacuum unselected icons (they follow _morphController in reverse)
    _morphController.reverse();
    // Wait for the vacuum to finish. Icons finish reversing around 800ms.
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    // 2. Drop the selected icon into the center
    await _dropController.forward();
    if (!mounted) return;

    // 3. Small delay then draw checkmark
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    await _checkmarkController.forward();
    if (!mounted) return;

    // Hold checkmark visible
    await Future.delayed(AppDurations.confirmHold);
    if (!mounted) return;

    // Reset everything back to idle
    await _resetToIdle();
  }

  Future<void> _resetToIdle() async {
    _dropController.reset();
    _checkmarkController.reset();
    _morphController.reset();

    setState(() {
      _state = _ShareState.idle;
      _selectedPlatform = null;
    });
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Background gradient ──────────────────────────────────────────
          _buildBackground(),

          // ── Header ──────────────────────────────────────────────────────
          _buildHeader(),

          // ── Center — the animation stage ─────────────────────────────────
          Center(child: _buildAnimationStage()),

          // ── Bottom hint ──────────────────────────────────────────────────
          _buildBottomHint(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              AppColors.primaryDim,
              AppColors.background,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Episode badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primaryDim,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Text(
                'Episode 01',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Morphing\nShare Button',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Pure Flutter SDK · No packages',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationStage() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _morphController,
        _glowController,
        _rippleController,
        _checkmarkController,
        _selectionController,
        _dropController,
      ]),
      builder: (context, _) {
        final morphProgress = _morphAnims.widthFactor.value;
        final glowValue = _glowAnim.value;
        final rippleValue = _rippleAnim.value;

        final isExpandedOrSelected = _state == _ShareState.expanded ||
            _state == _ShareState.selected;
        final isConfirming = _state == _ShareState.confirming;
        final showHub = isExpandedOrSelected ||
            isConfirming ||
            _state == _ShareState.morphing && morphProgress > 0.5;

        final showButton = !isExpandedOrSelected && !isConfirming;

        return SizedBox(
          width: 400,
          height: 400,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Pill / morphing button ──────────────────────────────────
              if (showButton)
                ShareButton(
                  morphProgress: morphProgress,
                  glowProgress: glowValue,
                  rippleProgress: rippleValue,
                  onTap: _onShareButtonTapped,
                ),

              // ── Hub (expanded) ──────────────────────────────────────────
              if (showHub)
                ShareHub(
                  hubScale: _expansionAnims.centralCircleScale.value,
                  glowProgress: glowValue,
                  iconProgress: {
                    for (final p in SharePlatform.values)
                      p: (_selectedPlatform == p && (_state == _ShareState.selected || _state == _ShareState.confirming))
                          ? 1.0 - _dropAnim.value // Keeps it at 1.0 until dropAnim runs
                          : _expansionAnims.iconProgress[p]!.value,
                  },
                  selectedPlatform: _selectedPlatform,
                  checkmarkProgress: _collapseAnims.checkmarkPathProgress.value,
                  checkmarkCircleScale:
                      _collapseAnims.checkmarkCircleScale.value,
                  checkmarkOpacity: _collapseAnims.checkmarkOpacity.value,
                  dropProgress: _dropAnim.value,
                  isConfirming: isConfirming,
                  onPlatformSelected: _onPlatformSelected,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomHint() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: _state == _ShareState.idle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: const Column(
          children: [
            Icon(
              Icons.keyboard_arrow_up_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
            SizedBox(height: 4),
            Text(
              'Tap the button',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

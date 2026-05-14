import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/ui/constants/app_constants.dart';
import 'package:calm_mind/viewmodels/relaxing_music_view_model.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen>
    with TickerProviderStateMixin {
  late final RelaxingMusicViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<RelaxingMusicViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _viewModel.selectedSong != null && !_viewModel.isPlaying) {
        _viewModel.loadAudio();
      }
    });
  }

  @override
  void dispose() {
    Future.microtask(() {
      _viewModel.cleanup();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RelaxingMusicViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.selectedSong == null) {
            return const Center(child: Text('No hay canción seleccionada'));
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // Background gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppConstants.musicGradient,
                  ),
                ),
              ),

              // Subtle pattern overlay
              Positioned.fill(
                child: Opacity(
                  opacity: 0.03,
                  child: CustomPaint(
                    painter: _WavePatternPainter(),
                  ),
                ),
              ),

              SafeArea(
                top: true,
                bottom: false,
                child: Column(
                  children: [
                    // Top bar
                    _buildTopBar(context, viewModel),

                    // Album art / animation area
                    Expanded(
                      child: _buildArtworkSection(viewModel),
                    ),

                    // Controls
                    _buildControlsPanel(context, viewModel),
                  ],
                ),
              ),

              // Loading overlay
              if (viewModel.loadingAudio) _buildLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, RelaxingMusicViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft02,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          if (viewModel.isCurrentSongCached)
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.download_done_rounded, color: Colors.white70, size: 18),
                SizedBox(width: 4),
                Text(
                  'Offline',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildArtworkSection(RelaxingMusicViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Album art container
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.15),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                  // Lottie animation
                  Lottie.asset(
                    AppConstants.musicAnimation,
                    fit: BoxFit.cover,
                    animate: viewModel.isPlaying,
                    repeat: true,
                  ),
                  // Vinyl-like overlay ring
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        viewModel.isPlaying ? Icons.graphic_eq : Icons.music_note_rounded,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Song title
          Hero(
            tag: "music-${viewModel.selectedSong?.name ?? 'unknown'}",
            child: Material(
              color: Colors.transparent,
              child: Text(
                viewModel.selectedSong?.name ?? 'Desconocido',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Author
          Text(
            viewModel.selectedSong?.author ?? 'Artista desconocido',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),

          // Category badge
          if (viewModel.selectedSong?.category != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                viewModel.selectedSong!.category,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          // Animated bars when playing
          if (viewModel.isPlaying) ...[
            const SizedBox(height: 20),
            SizedBox(
              height: 32,
              child: _EqualizerBars(isPlaying: viewModel.isPlaying),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlsPanel(
      BuildContext context, RelaxingMusicViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                    thumbColor: Colors.white,
                    overlayColor: Colors.white.withValues(alpha: 0.15),
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8),
                    overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 18),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    min: 0.0,
                    max: viewModel.duration.inSeconds > 0
                        ? viewModel.duration.inSeconds.toDouble()
                        : 0.0,
                    value: viewModel.position.inSeconds <
                            viewModel.duration.inSeconds
                        ? viewModel.position.inSeconds.toDouble()
                        : viewModel.duration.inSeconds.toDouble(),
                    onChanged: viewModel.handleSeek,
                  ),
                ),

                // Time labels
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        viewModel.formatDuration(viewModel.position),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        viewModel.formatDuration(viewModel.duration),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Previous
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded,
                          size: 40, color: Colors.white),
                      onPressed: () => viewModel.previousSong(),
                    ),
                    const SizedBox(width: 24),

                    // Play/Pause
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          viewModel.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: AppConstants.musicGradient[1],
                          size: 40,
                        ),
                        iconSize: 52,
                        onPressed: () => viewModel.togglePlayPause(),
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Next
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded,
                          size: 40, color: Colors.white),
                      onPressed: () => viewModel.nextSong(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/audio_loading.json',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando audio...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Equalizer bars ──
class _EqualizerBars extends StatefulWidget {
  final bool isPlaying;
  const _EqualizerBars({required this.isPlaying});

  @override
  State<_EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<_EqualizerBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final int barCount = 5;
  late final List<double> _heights;

  @override
  void initState() {
    super.initState();
    _heights = List.generate(barCount, (_) => 0.0);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _controller.addListener(_updateHeights);
  }

  void _updateHeights() {
    final rng = Random();
    for (int i = 0; i < barCount; i++) {
      _heights[i] = 0.3 + 0.7 * (_controller.value * (0.6 + 0.4 * rng.nextDouble()));
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(barCount, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 4,
          height: 32 * _heights[i],
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

// ── Subtle wave pattern painter ──
class _WavePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final path = Path();
    const waveCount = 4;
    final waveHeight = size.height / waveCount;

    for (int w = 0; w < waveCount; w++) {
      final baseY = w * waveHeight + waveHeight / 2;
      path.reset();
      path.moveTo(0, baseY);

      for (double x = 0; x <= size.width; x += 2) {
        final dx = x / size.width;
        final y = baseY + sin(dx * 3 * pi + w * 1.5) * 4;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
    }

    // Draw circles pattern
    final circlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 60) {
      for (double y = 0; y < size.height; y += 60) {
        canvas.drawCircle(Offset(x, y), 20, circlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

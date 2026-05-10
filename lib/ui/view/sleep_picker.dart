import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/models/sleep_content_model.dart';
import 'package:calm_mind/viewmodels/sleep_view_model.dart';
import 'package:calm_mind/ui/widgets/skeleton_loader.dart';

class SleepPicker extends StatefulWidget {
  const SleepPicker({super.key});

  @override
  State<SleepPicker> createState() => _SleepPickerState();
}

class _SleepPickerState extends State<SleepPicker> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('🌙', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text('Dormir', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        toolbarHeight: 48,
        actions: [
          Consumer<SleepViewModel>(
            builder: (context, vm, _) => IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              tooltip: 'Regenerar todo',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Regenerar audio'),
                    content: const Text(
                      '¿Regenerar todo el audio? Esto eliminará el audio guardado y generará nuevo contenido con IA.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          vm.regenerateAll();
                        },
                        child: const Text('Regenerar'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<SleepViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    WSkeletonLoader(height: 120, borderRadius: BorderRadius.circular(16)),
                    const SizedBox(height: 16),
                    Row(children: [Expanded(child: WSkeletonLoader(height: 100, borderRadius: BorderRadius.circular(16))), const SizedBox(width: 12), Expanded(child: WSkeletonLoader(height: 100, borderRadius: BorderRadius.circular(16)))]),
                    const SizedBox(height: 16),
                    Row(children: [Expanded(child: WSkeletonLoader(height: 100, borderRadius: BorderRadius.circular(16))), const SizedBox(width: 12), Expanded(child: WSkeletonLoader(height: 100, borderRadius: BorderRadius.circular(16)))]),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle('Sonidos Ambiente', '🌿'),
                const SizedBox(height: 12),
                _buildAmbientGrid(vm),
                const SizedBox(height: 24),
                _buildSectionTitle('Historias para Dormir', '📚'),
                const SizedBox(height: 12),
                ...vm.sleepStories.map((s) => _buildStoryCard(s, vm)),
                const SizedBox(height: 80),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String emoji) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildAmbientGrid(SleepViewModel vm) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.78,
      children: vm.ambientSounds.map((sound) => _buildAmbientCard(sound, vm)).toList(),
    );
  }

  Widget _buildAmbientCard(SleepContentModel sound, SleepViewModel vm) {
    final isSelected = vm.selectedContent?.id == sound.id && vm.isPlaying;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        vm.selectContent(sound);
        Navigator.push(context, MaterialPageRoute(builder: (_) => SleepPlayer(content: sound)));
      },
      child: AnimatedContainer(
        clipBehavior: Clip.antiAlias,
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [sound.startColor, sound.endColor],
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: sound.startColor.withValues(alpha: 0.5), blurRadius: 16, offset: const Offset(0, 6))]
              : [BoxShadow(color: sound.startColor.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))],
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Stack(
          children: [
            if (isSelected)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow, size: 14, color: Colors.black),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(sound.icon, style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 8),
                  Text(
                    sound.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCard(SleepContentModel story, SleepViewModel vm) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          vm.selectContent(story);
          Navigator.push(context, MaterialPageRoute(builder: (_) => SleepPlayer(content: story)));
        },
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [story.startColor, story.endColor],
            ),
            boxShadow: [BoxShadow(color: story.startColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(story.icon, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 8),
                      Text(story.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(story.subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    const Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
                    const SizedBox(height: 4),
                    Text('${story.durationMinutes} min', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SleepPlayer extends StatefulWidget {
  final SleepContentModel content;

  const SleepPlayer({super.key, required this.content});

  @override
  State<SleepPlayer> createState() => _SleepPlayerState();
}

class _SleepPlayerState extends State<SleepPlayer> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<SleepViewModel>();
      vm.generateAndPlay(widget.content);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.content;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [content.startColor, content.endColor],
          ),
        ),
        child: SafeArea(
          child: Consumer<SleepViewModel>(
            builder: (context, vm, child) {
              return Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.white70),
                              tooltip: 'Regenerar audio',
                              onPressed: () {
                                _showRegenerateDialog(context, vm);
                              },
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnim.value,
                            child: Column(
                              children: [
                                Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.1),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withValues(alpha: 0.15 * _pulseAnim.value),
                                        blurRadius: 40 * _pulseAnim.value,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(content.icon, style: const TextStyle(fontSize: 64)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        content.title,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        content.subtitle,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      if (vm.timerActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer, color: Colors.white70, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Se apaga en ${vm.formattedTime}',
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      if (vm.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                          child: Text(
                            vm.errorMessage!,
                            style: const TextStyle(color: Colors.orangeAccent, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          children: [
                            if (vm.duration.inSeconds > 0)
                              SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                                  thumbColor: Colors.white,
                                  overlayColor: Colors.white.withValues(alpha: 0.1),
                                ),
                                child: Slider(
                                  min: 0.0,
                                  max: vm.duration.inSeconds.toDouble(),
                                  value: vm.position.inSeconds.clamp(0, vm.duration.inSeconds).toDouble(),
                                  onChanged: vm.handleSeek,
                                ),
                              ),
                            if (vm.duration.inSeconds > 0)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(vm.formatDuration(vm.position),
                                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                    Text(vm.formatDuration(vm.duration),
                                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildTimerOption(vm, 15),
                                  const SizedBox(width: 12),
                                  _buildTimerOption(vm, 30),
                                  const SizedBox(width: 12),
                                  _buildTimerOption(vm, 45),
                                  const SizedBox(width: 12),
                                  _buildTimerOption(vm, 60),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.volume_down, color: Colors.white70, size: 20),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      trackHeight: 4,
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                      activeTrackColor: Colors.white,
                                      inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                                      thumbColor: Colors.white,
                                      overlayColor: Colors.white.withValues(alpha: 0.1),
                                    ),
                                    child: Slider(
                                      value: vm.volume,
                                      onChanged: vm.setVolume,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.volume_up, color: Colors.white70, size: 20),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.skip_previous, color: Colors.white70, size: 36),
                                  onPressed: vm.loadingAudio || vm.isGenerating ? null : () => vm.playPrevious(),
                                ),
                                const SizedBox(width: 24),
                                GestureDetector(
                                  onTap: vm.loadingAudio || vm.isGenerating
                                      ? null
                                      : () {
                                          HapticFeedback.mediumImpact();
                                          vm.handlePlayPause();
                                        },
                                  child: Container(
                                    width: 72,
                                    height: 72,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4))],
                                    ),
                                    child: Icon(
                                      vm.isPlaying ? Icons.pause : Icons.play_arrow,
                                      color: content.startColor,
                                      size: 40,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                IconButton(
                                  icon: const Icon(Icons.skip_next, color: Colors.white70, size: 36),
                                  onPressed: vm.loadingAudio || vm.isGenerating ? null : () => vm.playNext(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton.icon(
                                  onPressed: vm.timerActive ? null : () => vm.startSleepTimer(),
                                  icon: Icon(
                                    vm.timerActive ? Icons.timer_off : Icons.bedtime,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                  label: Text(
                                    vm.timerActive ? 'Timer activo' : 'Timer para dormir',
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                  if (vm.isGenerating || vm.loadingAudio)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              vm.isGenerating ? 'Generando audio con IA...' : 'Cargando...',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showRegenerateDialog(BuildContext context, SleepViewModel vm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Regenerar audio'),
        content: const Text(
          '¿Regenerar todo el audio? Esto eliminará el audio guardado y generará nuevo contenido con IA.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              vm.regenerateAll();
            },
            child: const Text('Regenerar'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerOption(SleepViewModel vm, int minutes) {
    final isSelected = vm.timerMinutes == minutes && !vm.timerActive;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        vm.setTimerMinutes(minutes);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$minutes min',
          style: TextStyle(
            color: isSelected ? widget.content.startColor : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

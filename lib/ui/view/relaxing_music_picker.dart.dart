import 'package:flutter/material.dart';
import 'package:flutter_animate_on_scroll/flutter_animate_on_scroll.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/models/relaxing_music_model.dart';
import 'package:calm_mind/ui/view/music_player_screen.dart';
import 'package:calm_mind/viewmodels/relaxing_music_view_model.dart';

class RelaxingMusicPicker extends StatefulWidget {
  const RelaxingMusicPicker({super.key});

  @override
  State<RelaxingMusicPicker> createState() => _RelaxingMusicPickerState();
}

class _RelaxingMusicPickerState extends State<RelaxingMusicPicker> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<RelaxingMusicViewModel>(
        
          builder: (context, viewModel, child) {
            
            var _state = viewModel.state;
            
            if (_state == RelaxingMusicState.loading) {
              return Column(

                mainAxisAlignment: MainAxisAlignment.center,
                
                children: [

                  Center(child: Lottie.asset('assets/animations/audio_loading.json')),
                  Center(
                    child: Text(
                      'Obteniendo canciones espera...',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                ],
              );
            }
            if (_state == RelaxingMusicState.error) {
              return Center(
                child: Column(
                  children: [
                    Align(
                    alignment: Alignment.topLeft,
                    child: const Icon(Icons.arrow_back),
                    ),
                    Text(
                      'Error: ${viewModel.errorMessage}'
                    ),
                    FilledButton(
                      onPressed: viewModel.getMusic,
                      child: Text('Reintentar'),
                    )
                  ],
                )
              );
            }
            if (viewModel.musicList.isEmpty){
              return Center(
                child: Text(
                  'No hay musica para mostrar',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }         
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Align(
                    
                     alignment: Alignment.topLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back)
                      ),
                      ),
                ),
                Text(
                  'Selecciona la cancion que deseas escuchar',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10,),
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.musicList.length,
                    itemBuilder: (context, index) {
                
                      return FadeInDown(
                        config: BaseAnimationConfig(
                          child: _PulsatingMusicTile(
                            song: viewModel.musicList[index],
                            onTap: () => _navigateToAudioScreen(viewModel.musicList[index]),
                            heroTag: "music-${viewModel.musicList[index].name}",
                          ),
                        )
                      );
                    },
                  ),
                ),
              ],
            );
          }
        ),
      )
    );
  }
  void _navigateToAudioScreen (RelaxingMusicModel song) {
    context.read<RelaxingMusicViewModel>().setSelectedSong(song);
    Navigator.push(context, MaterialPageRoute(builder: (context) => MusicPlayerScreen()));
  }
}

class _PulsatingMusicTile extends StatefulWidget {
  final RelaxingMusicModel song;
  final VoidCallback onTap;
  final String heroTag;

  const _PulsatingMusicTile({
    required this.song,
    required this.onTap,
    required this.heroTag,
  });

  @override
  State<_PulsatingMusicTile> createState() => _PulsatingMusicTileState();
}

class _PulsatingMusicTileState extends State<_PulsatingMusicTile> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.deepOrange, Colors.orange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.music_note, color: Colors.white),
                  ),
                  title: Hero(
                    tag: widget.heroTag,
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        widget.song.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  subtitle: Text(
                    widget.song.author,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Text(
                    widget.song.duration, 
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

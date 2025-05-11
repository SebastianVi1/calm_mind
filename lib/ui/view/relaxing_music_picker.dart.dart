import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/models/relaxing_music_model.dart';
import 'package:re_mind/ui/view/music_player_screen.dart';
import 'package:re_mind/viewmodels/relaxing_music_view_model.dart';

class RelaxingMusicPicker extends StatefulWidget {
  const RelaxingMusicPicker({super.key});

  @override
  State<RelaxingMusicPicker> createState() => _RelaxingMusicPickerState();
}

class _RelaxingMusicPickerState extends State<RelaxingMusicPicker> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 30,
        actions: [
          IconButton(
            icon: Icon(Icons.replay_outlined),
            onPressed: context.read<RelaxingMusicViewModel>().getMusic,
          )
        ],
      ),
      body: Consumer<RelaxingMusicViewModel>(

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
              Text(
                'Selecciona la cancion que deseas escuchar',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: viewModel.musicList.length,
                  itemBuilder: (context, index) {
              
                    return Card(
                    
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        onTap: (){_navigateToAudioScreen(viewModel.musicList[index]);},
                        title: Text(viewModel.musicList[index].name),
                        subtitle: Text(viewModel.musicList[index].author),
                        trailing: Text(viewModel.musicList[index].duration),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      )
    );
  }
  void _navigateToAudioScreen (RelaxingMusicModel song) {
    context.read<RelaxingMusicViewModel>().setSelectedSong(song);
    Navigator.push(context, MaterialPageRoute(builder: (context) => MusicPlayerScreen()));
  }
}
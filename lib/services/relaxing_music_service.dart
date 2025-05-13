import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:calm_mind/models/relaxing_music_model.dart';

class RelaxingMusicService {
  final String musicApiUrl = 'https://magicloops.dev/api/loop/66ff2c88-88ec-4427-9d34-cdc56011083c/run';
  
  Future<List<RelaxingMusicModel>> getMeditations() async {
    try {
      final response = await http.get(Uri.parse(musicApiUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Check the api structure
        if (jsonData is Map<String, dynamic> && 
            jsonData.containsKey('results') && 
            jsonData['results'] is Map<String, dynamic> && 
            jsonData['results'].containsKey('audio_files')) {
          
          final List<dynamic> musicList = jsonData['results']['audio_files'] ?? [];
          return musicList
            .map((song) => RelaxingMusicModel.fromJson(song))
            .toList();
        } else {
          throw Exception('Formato de respuesta inválido: no se encontraron audio_files en results');
        }
      } else {
        throw Exception('Error al cargar la música. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getMeditations: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> triggerMagicLoopsAPI({String message = 'manual API call to start the loop'}) async {
    try {
      final url = Uri.parse('https://magicloops.dev/api/loop/66ff2c88-88ec-4427-9d34-cdc56011083c/run');
        
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'trigger': message,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al activar Magic Loops API. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en triggerMagicLoopsAPI: $e');
      throw e; // Re-lanzamos la excepción para que el ViewModel la maneje
    }
  }
}

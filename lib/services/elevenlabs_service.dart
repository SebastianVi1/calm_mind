import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ElevenLabsService {
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';
  static const String _voiceId = 'htFfPSZGJwjBv1CL0aMD';
  static const String _model = 'eleven_multilingual_v2';

  final String _apiKey;

  ElevenLabsService()
      : _apiKey = dotenv.env['ELEVENLABS_API_KEY'] ?? '' {
    if (_apiKey.isEmpty) {
      throw Exception('ElevenLabs API key not found in .env file');
    }
  }

  Future<List<int>> generateSpeech(String text) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/text-to-speech/$_voiceId'),
      headers: {
        'Content-Type': 'application/json',
        'xi-api-key': _apiKey,
      },
      body: jsonEncode({
        'text': text,
        'model_id': _model,
        'voice_settings': {
          'stability': 0.5,
          'similarity_boost': 0.75,
        },
      }),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception(
        'ElevenLabs TTS error: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<List<int>> generateSoundEffect(String prompt) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/sound-generation'),
      headers: {
        'Content-Type': 'application/json',
        'xi-api-key': _apiKey,
      },
      body: jsonEncode({
        'text': prompt,
        'duration_seconds': 30,
        'prompt_influence': 0.3,
      }),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception(
        'ElevenLabs sound effect error: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

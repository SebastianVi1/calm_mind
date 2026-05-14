import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:calm_mind/services/ai/i_ai_service.dart';
import 'package:calm_mind/services/elevenlabs_service.dart';
import 'package:calm_mind/models/sleep_content_model.dart';

class SleepContentGenerator {
  final IAIService _deepSeek;
  final ElevenLabsService _elevenLabs;

  SleepContentGenerator(this._deepSeek, this._elevenLabs);

  static const String _sleepStoryPrompt = '''
Eres un escritor creativo especializado en cuentos e historias para dormir en español.
Escribe historias relajantes, descriptivas y envolventes que ayuden a conciliar el sueño.
Usa un lenguaje suave, poético y tranquilo. Evita temas estresantes o emocionantes.
La historia debe tener una duración adecuada para leer en voz alta durante el tiempo especificado.
Responde ÚNICAMENTE con el texto de la historia, sin introducciones ni notas adicionales.
No uses formato markdown ni caracteres especiales. Solo texto plano en español.''';

  static const String _meditationScriptPrompt = '''
Eres un guionista de meditaciones guiadas en español.
Escribe una meditación guiada completa, relajante y envolvente.
Usa un tono calmado, pausado y profesional.
Incluye instrucciones de respiración, visualización y relajación progresiva.
La meditación debe tener una duración adecuada para leer en voz alta durante el tiempo especificado.
Responde ÚNICAMENTE con el texto de la meditación, sin introducciones ni notas adicionales.
No uses formato markdown ni caracteres especiales. Solo texto plano en español.''';

  Future<Directory> get _cacheDir async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(
      '${base.path}${Platform.pathSeparator}sleep_audio_cache',
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<bool> isCached(String contentId) async {
    final dir = await _cacheDir;
    final file = File('${dir.path}${Platform.pathSeparator}$contentId.mp3');
    final exists = await file.exists();
    return exists && (await file.length()) > 0;
  }

  Future<File> getCachedFile(String contentId) async {
    final dir = await _cacheDir;
    final file = File('${dir.path}${Platform.pathSeparator}$contentId.mp3');
    if (await file.exists() && (await file.length()) > 0) {
      return file;
    }
    throw Exception('No cached audio found for $contentId');
  }

  Future<File> generateCachedAudio({
    required String cacheId,
    required Future<List<int>> Function() generator,
  }) async {
    final dir = await _cacheDir;
    final file = File('${dir.path}${Platform.pathSeparator}$cacheId.mp3');

    if (await file.exists() && (await file.length()) > 0) {
      return file;
    }

    final audioBytes = await generator();
    await file.writeAsBytes(audioBytes, flush: true);
    return file;
  }

  Future<File> generateStoryAudio(SleepContentModel content) async {
    final durationMinutes = content.durationMinutes ?? 10;
    final userPrompt = '''
Escribe una historia para dormir en español sobre: ${content.storyTopic}.
La historia debe durar aproximadamente $durationMinutes minutos cuando se lee en voz alta.
Hazla tranquila, descriptiva y relajante. Sin diálogos rápidos ni acción intensa.''';

    return generateCachedAudio(
      cacheId: content.id,
      generator: () async {
        final script = await _deepSeek.generateContent(
          systemPrompt: _sleepStoryPrompt,
          userPrompt: userPrompt,
          maxTokens: durationMinutes * 200,
        );
        return _elevenLabs.generateSpeech(script);
      },
    );
  }

  Future<File> generateAmbientAudio(SleepContentModel content) async {
    return generateCachedAudio(
      cacheId: content.id,
      generator: () => _elevenLabs.generateSoundEffect(content.audioPrompt),
    );
  }

  Future<File> generateMeditationAudio({
    required String cacheId,
    required String storyTopic,
    required int durationMinutes,
  }) async {
    final userPrompt = '''
Escribe una meditación guiada en español sobre: $storyTopic.
La meditación debe durar aproximadamente $durationMinutes minutos cuando se lee en voz alta.
Incluye pausas naturales, instrucciones de respiración y visualizaciones guiadas.''';

    return generateCachedAudio(
      cacheId: cacheId,
      generator: () async {
        final script = await _deepSeek.generateContent(
          systemPrompt: _meditationScriptPrompt,
          userPrompt: userPrompt,
          maxTokens: durationMinutes * 200,
        );
        return _elevenLabs.generateSpeech(script);
      },
    );
  }

  Future<void> clearAllCache() async {
    final dir = await _cacheDir;
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      await dir.create(recursive: true);
    }
  }
}

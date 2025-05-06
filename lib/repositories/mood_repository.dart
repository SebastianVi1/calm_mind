import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:re_mind/models/mood_model.dart';

class MoodRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Método para registrar un estado de ánimo en un documento único por usuario
  Future<void> registerMood(String userId, MoodModel mood) async {
    try {
      final userMoodDoc = _db.collection("mood_history").doc(userId);

      // Obtener el documento del usuario
      final docSnapshot = await userMoodDoc.get();

      if (!docSnapshot.exists) {
        // Create a new document if it does not exist
        await userMoodDoc.set({
          'userId': userId,
          'moods': [mood.toJson()],
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        // Update the existing document
        final data = docSnapshot.data() as Map<String, dynamic>;
        final moods = List<Map<String, dynamic>>.from(data['moods'] ?? []);
        moods.add(mood.toJson());

        await userMoodDoc.update({
          'moods': moods,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      
    } catch (error) {
      throw Exception("Error al registrar el mood: $error");
    }
  }

  // Método para obtener el historial de estados de ánimo de un usuario
  Future<List<MoodModel>> getMoodHistory(String userId) async {
    try {
      final docSnapshot = await _db.collection("mood_history").doc(userId).get();

      if (!docSnapshot.exists) return [];

      final data = docSnapshot.data() as Map<String, dynamic>;
      final moods = List<Map<String, dynamic>>.from(data['moods'] ?? []);

      return moods.map((mood) => MoodModel.fromJson(mood)).toList();
    } catch (error) {
  
      throw Exception("Error al obtener el historial de moods: $error");
    }
  }

  Future<void> deleteMood(userId, MoodModel mood) async {
    try {
      final userMoodDoc = _db.collection("mood_history").doc(userId);

      // get the user document
      final docSnapshot = await userMoodDoc.get();

      if (!docSnapshot.exists) {
        throw Exception("El documento no existe");
      } else {
        // Update the existing document
        final data = docSnapshot.data() as Map<String, dynamic>;
        final moods = List<Map<String, dynamic>>.from(data['moods'] ?? []);
        moods.removeWhere((m) => m['timestamp'] == mood.timestamp.millisecondsSinceEpoch);

        await userMoodDoc.update({
          'moods': moods,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (error) {
      throw Exception("Error al eliminar el mood: $error");
    }
  }
}
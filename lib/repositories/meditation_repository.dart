import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calm_mind/models/meditation_audio_model.dart';

class MeditationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'meditations';

  /// Fetches all meditation sessions from Firestore
  Future<List<MeditationAudioModel>> getMeditations() async {
    try {
      final snapshot = await _db.collection(_collection).get();
      
      return snapshot.docs
          .map((doc) => MeditationAudioModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching meditations from Firestore: $e');
      return [];
    }
  }

  /// Fetches meditations by category
  Future<List<MeditationAudioModel>> getMeditationsByCategory(String category) async {
    try {
      final snapshot = await _db
          .collection(_collection)
          .where('category', isEqualTo: category)
          .get();
      
      return snapshot.docs
          .map((doc) => MeditationAudioModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching meditations by category: $e');
      return [];
    }
  }
}

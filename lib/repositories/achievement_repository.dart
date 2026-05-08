import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:calm_mind/models/achievement_model.dart';

class AchievementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _achievementsCollection =>
      _firestore.collection('user_achievements');

  DocumentReference get _userAchievementsDoc {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuario no autenticado');
    return _achievementsCollection.doc(userId);
  }

  Future<void> initializeUserAchievements() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final doc = await _userAchievementsDoc.get();
      if (!doc.exists) {
        await _userAchievementsDoc.set({
          'userId': userId,
          'unlockedAchievements': <String>[],
          'unlockedAt': <String, String>{},
        });
      }
    } catch (e) {
      debugPrint('Error initializing user achievements: $e');
    }
  }

  Future<List<String>> getUnlockedAchievementIds() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final doc = await _userAchievementsDoc.get();
      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>;
      return List<String>.from(data['unlockedAchievements'] ?? []);
    } catch (e) {
      debugPrint('Error getting unlocked achievements: $e');
      return [];
    }
  }

  Future<void> unlockAchievement(String achievementId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final doc = await _userAchievementsDoc.get();
      final data = doc.exists ? doc.data() as Map<String, dynamic> : <String, dynamic>{};
      final unlockedList = List<String>.from(data['unlockedAchievements'] ?? []);

      if (!unlockedList.contains(achievementId)) {
        unlockedList.add(achievementId);
        final unlockedAt = Map<String, String>.from(data['unlockedAt'] ?? {});
        unlockedAt[achievementId] = DateTime.now().toIso8601String();

        await _userAchievementsDoc.set({
          'userId': userId,
          'unlockedAchievements': unlockedList,
          'unlockedAt': unlockedAt,
        });
      }
    } catch (e) {
      debugPrint('Error unlocking achievement: $e');
    }
  }

  Future<DateTime?> getUnlockedDate(String achievementId) async {
    try {
      final doc = await _userAchievementsDoc.get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      final unlockedAt = Map<String, String>.from(data['unlockedAt'] ?? {});
      final dateStr = unlockedAt[achievementId];
      return dateStr != null ? DateTime.parse(dateStr) : null;
    } catch (e) {
      debugPrint('Error getting unlocked date: $e');
      return null;
    }
  }

  Future<bool> isAchievementUnlocked(String achievementId) async {
    final unlocked = await getUnlockedAchievementIds();
    return unlocked.contains(achievementId);
  }

  Future<void> syncUnlockedAchievements(
    List<Achievement> allAchievements,
    bool Function(Achievement) shouldBeUnlocked,
  ) async {
    try {
      for (final achievement in allAchievements) {
        if (shouldBeUnlocked(achievement)) {
          await unlockAchievement(achievement.id);
        }
      }
    } catch (e) {
      debugPrint('Error syncing achievements: $e');
    }
  }
}
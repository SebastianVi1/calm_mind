import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:calm_mind/models/journal_model.dart';

class JournalRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _journalCollection => _firestore.collection('journals');

  DocumentReference get _userJournalDoc {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuario no autenticado');
    return _journalCollection.doc(userId);
  }

  Future<void> saveEntry(JournalEntry entry) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final doc = await _userJournalDoc.get();
      final data = doc.exists ? doc.data() as Map<String, dynamic> : <String, dynamic>{};
      final entries = Map<String, dynamic>.from(data['entries'] ?? {});

      entries[entry.id] = entry.toJson();

      await _userJournalDoc.set({
        'userId': userId,
        'entries': entries,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving journal entry: $e');
      rethrow;
    }
  }

  Future<List<JournalEntry>> getEntries({int limit = 50}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final doc = await _userJournalDoc.get();
      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>;
      final entries = Map<String, dynamic>.from(data['entries'] ?? {});

      final journalEntries = entries.values
          .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
          .toList();

      journalEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return journalEntries.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting journal entries: $e');
      return [];
    }
  }

  Future<JournalEntry?> getEntry(String entryId) async {
    try {
      final entries = await getEntries(limit: 500);
      return entries.firstWhere(
        (e) => e.id == entryId,
        orElse: () => throw Exception('Entry not found'),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteEntry(String entryId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final doc = await _userJournalDoc.get();
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      final entries = Map<String, dynamic>.from(data['entries'] ?? {});

      entries.remove(entryId);

      await _userJournalDoc.update({
        'entries': entries,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error deleting journal entry: $e');
      rethrow;
    }
  }

  Future<void> updateEntryAnalysis(String entryId, String aiAnalysis, List<JournalInsight> insights, int? sentimentScore) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final doc = await _userJournalDoc.get();
      if (!doc.exists) return;

      final data = doc.data() as Map<String, dynamic>;
      final entries = Map<String, dynamic>.from(data['entries'] ?? {});

      if (entries.containsKey(entryId)) {
        final entry = JournalEntry.fromJson(entries[entryId]);
        final updatedEntry = JournalEntry(
          id: entry.id,
          content: entry.content,
          timestamp: entry.timestamp,
          moodLabel: entry.moodLabel,
          aiAnalysis: aiAnalysis,
          insights: insights,
          tags: entry.tags,
          sentimentScore: sentimentScore,
        );
        entries[entryId] = updatedEntry.toJson();

        await _userJournalDoc.update({
          'entries': entries,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error updating entry analysis: $e');
    }
  }
}

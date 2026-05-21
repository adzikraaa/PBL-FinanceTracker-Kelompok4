import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/saving_model.dart';
import '../models/hpp_model.dart';

class FirestoreSeeder {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Melakukan seeding data mock premium ke Firestore untuk pengguna aktif
  static Future<void> seedMockData(
    String uid, {
    String? email,
    String? displayName,
  }) async {
    try {
      debugPrint('FirestoreSeeder: Memulai pengisian data untuk UID: $uid...');

      // 1. Seed / Update data profil pengguna di Firestore agar menjadi PREMIUM
      final userDocRef = _db.collection('users').doc(uid);
      final userSnapshot = await userDocRef.get();

      final String finalEmail = email ?? userSnapshot.data()?['email'] ?? 'wirausaha@bizprice.app';
      final String finalName = displayName ?? userSnapshot.data()?['displayName'] ?? userSnapshot.data()?['name'] ?? 'Wirausahawan Sukses';
      final String finalPhotoUrl = userSnapshot.data()?['photoUrl'] ?? '';

      // Update profile but keep default premium status (false)
      await userDocRef.set({
        'uid': uid,
        'email': finalEmail,
        'displayName': finalName,
        'name': finalName, // Duplikasi untuk compatibility viewmodel yang mencari field 'name'
        'photoUrl': finalPhotoUrl,
        'isPremium': false,
      }, SetOptions(merge: true));
await _db.collection('users').doc(uid).set({'seeded': true}, SetOptions(merge: true));
      debugPrint('FirestoreSeeder: Status premium berhasil diaktifkan.');

      debugPrint('FirestoreSeeder: Seluruh pengisian data selesai successfully.');
    } catch (e) {
      debugPrint('FirestoreSeeder ERROR: Gagal mengisi data Firestore: $e');
    }
  }

  // Check if user data already seeded
  static Future<bool> hasSeeded(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      final data = doc.data();
      return data != null && (data['seeded'] ?? false) == true;
    } catch (e) {
      debugPrint('FirestoreSeeder: hasSeeded error $e');
      return false;
    }
  }
}


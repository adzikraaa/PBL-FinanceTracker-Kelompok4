import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/saving_model.dart';
import '../models/user_model.dart'; // Wajib di-import
import '../models/hpp_model.dart';  // Wajib di-import

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==========================================
  // 1. DATABASE USER
  // ==========================================
  
  // Simpan data user ke Firestore saat pertama kali login
  Future<void> saveUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toJson());
  }

  // Ambil data profil user (untuk cek status Premium)
  Future<UserModel> getUser(String uid) async {
    var doc = await _db.collection('users').doc(uid).get();
    return UserModel.fromJson(doc.data()!);
  }

  // ==========================================
  // 2. FITUR TABUNGAN (CRUD)
  // ==========================================

  Future<void> addSaving(SavingModel saving) async {
    await _db.collection('savings').add(saving.toJson());
  }

  Stream<List<SavingModel>> streamSavings(String userId) {
    return _db
        .collection('savings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SavingModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateSaving(String id, double newAmount) async {
    await _db.collection('savings').doc(id).update({
      'currentAmount': newAmount,
    });
  }

  Future<void> updateSavingFull(SavingModel saving) async {
    if (saving.id == null) return;
    await _db.collection('savings').doc(saving.id).update(saving.toJson());
  }

  Future<void> deleteSaving(String id) async {
    await _db.collection('savings').doc(id).delete();
  }

  // ==========================================
  // 3. DATABASE HPP (RIWAYAT & INSIGHT)
  // ==========================================
  
  // Simpan hasil hitungan user ke riwayat agar bisa muncul di list
  Future<void> addHistory(HppModel data) async {
    await _db.collection('history').add(data.toJson());
  }

  // Ambil data riwayat untuk ditampilkan di List Riwayat & Grafik Insight
  Stream<List<HppModel>> streamHistory(String userId) {
    return _db
        .collection('history')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HppModel.fromJson(doc.data(), doc.id))
            .toList());
  }
} // <--- KURUNG TUTUP CLASS HARUS DI PALING BAWAH
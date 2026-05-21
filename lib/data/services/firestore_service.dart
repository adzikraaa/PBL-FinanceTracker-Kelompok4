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
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => SavingModel.fromJson(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
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
  
  // ==========================================
  // 4. DATABASE FINANCE (CALCULATIONS)
  // ==========================================

  // Simpan data perhitungan (editable) ke koleksi 'finance'
  Future<void> addFinance(HppModel data) async {
    await _db.collection('finance').add(data.toJson());
  }

  // Stream data perhitungan yang dapat diedit oleh pengguna
  Stream<List<HppModel>> streamFinance(String userId) {
    return _db
        .collection('finance')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => HppModel.fromJson(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  // Update satu dokumen perhitungan yang sudah ada
  Future<void> updateFinance(String docId, Map<String, dynamic> data) async {
    await _db.collection('finance').doc(docId).update(data);
  }

  // Delete perhitungan yang tidak diperlukan lagi
  Future<void> deleteFinance(String docId) async {
    await _db.collection('finance').doc(docId).delete();
  }
  Future<void> addHistory(HppModel data) async {
    await _db.collection('history').add(data.toJson());
  }

  // Ambil data riwayat untuk ditampilkan di List Riwayat & Grafik Insight
  Stream<List<HppModel>> streamHistory(String userId) {
    return _db
        .collection('history')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => HppModel.fromJson(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<void> deleteHistory(String id) async {
    await _db.collection('history').doc(id).delete();
  }
} // <--- KURUNG TUTUP CLASS HARUS DI PALING BAWAH
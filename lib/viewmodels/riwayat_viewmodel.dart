import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/models/hpp_model.dart';
import '../data/services/firestore_service.dart';

class RiwayatViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<HppModel> _history = [];
  bool isLoading = true;
  String? error;

  // Subscription ke stream Firestore
  StreamSubscription<List<HppModel>>? _historySub;
  // Subscription ke perubahan status auth
  StreamSubscription<User?>? _authSub;

  List<HppModel> get history => _history;

  /// Item terbaru (untuk card di Home)
  HppModel? get latest => _history.isNotEmpty ? _history.first : null;

  RiwayatViewModel() {
    // Dengarkan perubahan auth — otomatis mulai/berhenti stream data
    _authSub = _auth.authStateChanges().listen((user) {
      if (user != null) {
        _startListening(user.uid);
      } else {
        _stopListening();
        _history = [];
        isLoading = false;
        notifyListeners();
      }
    });
  }

  /// Mulai subscribe ke koleksi 'history' di Firestore
  void _startListening(String uid) {
    // Batalkan subscription lama jika ada
    _historySub?.cancel();
    isLoading = true;
    notifyListeners();

    _historySub = _firestoreService.streamHistory(uid).listen(
      (list) {
        _history = list;
        isLoading = false;
        error = null;
        notifyListeners();
      },
      onError: (e) {
        error = e.toString();
        isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Hentikan subscription ke Firestore
  void _stopListening() {
    _historySub?.cancel();
    _historySub = null;
  }

  Future<void> deleteHistory(String id) async {
    await _firestoreService.deleteHistory(id);
  }

  @override
  void dispose() {
    _historySub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}

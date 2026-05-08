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

  StreamSubscription<List<HppModel>>? _sub;

  List<HppModel> get history => _history;

  /// Item terbaru (untuk card di Home)
  HppModel? get latest => _history.isNotEmpty ? _history.first : null;

  RiwayatViewModel() {
    _init();
  }

  void _init() {
    final user = _auth.currentUser;
    if (user == null) {
      isLoading = false;
      notifyListeners();
      return;
    }
    _sub = _firestoreService.streamHistory(user.uid).listen(
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

  Future<void> deleteHistory(String id) async {
    await _firestoreService.deleteHistory(id);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

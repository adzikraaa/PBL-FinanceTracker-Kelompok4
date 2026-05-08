import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/models/saving_model.dart';
import '../data/services/firestore_service.dart';

class SavingsViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<SavingModel> _savings = [];
  bool isLoading = true;
  String? error;

  StreamSubscription<List<SavingModel>>? _sub;

  List<SavingModel> get savings => _savings;

  SavingModel? get firstSaving => _savings.isNotEmpty ? _savings.first : null;

  double get totalSavings =>
      _savings.fold(0, (sum, item) => sum + item.currentAmount);

  double get totalTarget =>
      _savings.fold(0, (sum, item) => sum + item.targetAmount);

  double get savingsPercentage {
    if (totalTarget == 0) return 0;
    return (totalSavings / totalTarget) * 100;
  }

  SavingsViewModel() {
    _init();
  }

  void _init() {
    final user = _auth.currentUser;
    if (user == null) {
      isLoading = false;
      notifyListeners();
      return;
    }
    _sub = _firestoreService.streamSavings(user.uid).listen(
      (list) {
        _savings = list;
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

  Future<void> addSaving({
    required String title,
    required double targetAmount,
    required double currentAmount,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final saving = SavingModel(
      userId: user.uid,
      title: title,
      targetAmount: targetAmount,
      currentAmount: currentAmount.clamp(0, targetAmount),
      createdAt: DateTime.now(),
    );
    await _firestoreService.addSaving(saving);
  }

  Future<void> updateSaving(String id, double newAmount) async {
    await _firestoreService.updateSaving(id, newAmount);
  }

  Future<void> removeSaving(String id) async {
    await _firestoreService.deleteSaving(id);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

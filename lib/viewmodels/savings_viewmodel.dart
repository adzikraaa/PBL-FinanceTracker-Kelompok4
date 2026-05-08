import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models/savings_model.dart';
import '../data/services/firestore_service.dart';

class SavingsViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<SavingModel> _savings = [];
  bool isLoading = true;
  String? errorMessage;
  StreamSubscription<List<SavingModel>>? _sub;

  // Form Fields
  String title = '';
  double currentAmount = 0.0;
  double targetAmount = 5000.0;
  String? imageUrl;
  SavingModel? editingSaving;

  List<SavingModel> get savings => _savings;
  double get totalSavings => _savings.fold(0, (sum, item) => sum + item.currentAmount);
  double get totalTarget => _savings.fold(0, (sum, item) => sum + item.targetAmount);

  SavingModel? get firstSaving => _savings.isNotEmpty ? _savings.first : null;

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
        errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        errorMessage = e.toString();
        isLoading = false;
        notifyListeners();
      },
    );
  }

  // Persentase progress per item
  double getProgress(SavingModel saving) {
    if (saving.targetAmount <= 0) return 0;
    return (saving.currentAmount / saving.targetAmount).clamp(0.0, 1.0);
  }

  // Monthly goal otomatis (sisa dibagi 12 bulan)
  double getMonthlyGoal(SavingModel saving) {
    double sisa = saving.targetAmount - saving.currentAmount;
    if (sisa <= 0) return 0;
    return sisa / 12;
  }

  // Expected completion otomatis
  String getExpectedCompletion(SavingModel saving) {
    double monthly = getMonthlyGoal(saving);
    if (monthly <= 0) return 'Selesai!';
    double sisa = saving.targetAmount - saving.currentAmount;
    int bulan = (sisa / monthly).ceil();
    DateTime selesai = DateTime.now().add(Duration(days: bulan * 30));
    const monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${monthNames[selesai.month]} ${selesai.year}';
  }

  // Isi form untuk edit
  void loadForEdit(SavingModel saving) {
    editingSaving = saving;
    title = saving.title;
    currentAmount = saving.currentAmount;
    targetAmount = saving.targetAmount;
    imageUrl = saving.imageUrl;
    errorMessage = null;
    notifyListeners();
  }

  // Reset form (untuk tambah baru)
  void resetForm() {
    editingSaving = null;
    title = '';
    currentAmount = 0.0;
    targetAmount = 5000.0;
    imageUrl = null;
    errorMessage = null;
    notifyListeners();
  }

  // Fungsi untuk memilih gambar dengan validasi format
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        final String fileName = image.name.toLowerCase();
        final String extension = fileName.split('.').last;

        // Validasi format: JPEG, JPG, PNG
        if (extension == 'jpg' || extension == 'jpeg' || extension == 'png') {
          final bytes = await image.readAsBytes();
          imageUrl = 'data:image/$extension;base64,${base64Encode(bytes)}';
          errorMessage = null;
        } else {
          errorMessage = 'Format file tidak sesuai (Hanya JPG, JPEG, PNG)';
        }
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Gagal mengambil gambar';
      notifyListeners();
    }
  }

  // Validasi form
  bool _isFormValid() {
    if (title.trim().isEmpty) {
      errorMessage = 'Field tidak boleh kosong';
      notifyListeners();
      return false;
    }
    if (targetAmount < 1000) {
      errorMessage = 'Nominal tidak valid, minimal 1.000';
      notifyListeners();
      return false;
    }
    errorMessage = null;
    return true;
  }

  // Simpan (tambah atau edit)
  Future<bool> saveSaving(String userId) async {
    if (!_isFormValid()) return false;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final saving = SavingModel(
        id: editingSaving?.id,
        userId: userId,
        title: title.trim(),
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        createdAt: editingSaving?.createdAt ?? DateTime.now(),
        imageUrl: imageUrl,
      );

      if (editingSaving != null) {
        await _firestoreService
            .updateSavingFull(saving)
            .timeout(const Duration(seconds: 3))
            .catchError((_) => null);
      } else {
        await _firestoreService
            .addSaving(saving)
            .timeout(const Duration(seconds: 3))
            .catchError((_) => null);
      }

      resetForm();
      return true;
    } catch (e) {
      errorMessage = 'Gagal menyimpan tabungan: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Tambah tabungan baru langsung
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

  // Update jumlah tabungan
  Future<void> updateSavingAmount(String id, double newAmount) async {
    await _firestoreService.updateSaving(id, newAmount);
  }

  // Hapus tabungan
  Future<bool> deleteSaving(String id) async {
    isLoading = true;
    notifyListeners();
    try {
      await _firestoreService
          .deleteSaving(id)
          .timeout(const Duration(seconds: 3))
          .catchError((_) => null);
      return true;
    } catch (e) {
      errorMessage = 'Gagal menghapus tabungan: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

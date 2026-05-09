import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../data/models/saving_model.dart';
import '../data/services/firestore_service.dart';

class SavingViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<List<SavingModel>>? _sub;

  List<SavingModel> _savings = [];
  List<SavingModel> get savings => _savings;

  bool isLoading = false;
  String? errorMessage;
  
  // Cache untuk data gambar agar tidak flicker
  Uint8List? _cachedImageData;
  Uint8List? get cachedImageData => _cachedImageData;

  SavingViewModel() {
    _init();
  }

  void _init() {
    isLoading = true;
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

  // Form fields dengan properti reaktif
  String _title = '';
  String get title => _title;
  set title(String value) {
    _title = value;
    notifyListeners();
  }

  double _currentAmount = 0.0;
  double get currentAmount => _currentAmount;
  set currentAmount(double value) {
    _currentAmount = value;
    notifyListeners();
  }

  double _targetAmount = 5000.0;
  double get targetAmount => _targetAmount;
  set targetAmount(double value) {
    _targetAmount = value;
    notifyListeners();
  }

  String? imageUrl; // Field untuk menampung gambar yang dipilih

  // Editing state
  SavingModel? editingSaving;

  // Total semua tabungan
  double get totalSavings =>
      _savings.fold(0.0, (sum, item) => sum + item.currentAmount);

  double get totalTarget =>
      _savings.fold(0.0, (sum, item) => sum + item.targetAmount);

  double get savingsPercentage {
    if (totalTarget == 0) return 0;
    return (totalSavings / totalTarget) * 100;
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
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${monthNames[selesai.month]} ${selesai.year}';
  }

  // Listen realtime dari Firestore
  void listenSavings(String userId) {
    _sub?.cancel();
    isLoading = true;
    _sub = _firestoreService.streamSavings(userId).listen(
      (data) {
        _savings = data;
        isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        isLoading = false;
        errorMessage = 'Gagal memuat data: $e';
        notifyListeners();
      },
    );
  }

  // Isi form untuk edit
  void loadForEdit(SavingModel saving) {
    editingSaving = saving;
    title = saving.title;
    currentAmount = saving.currentAmount;
    targetAmount = saving.targetAmount;
    imageUrl = saving.imageUrl;
    
    // Decode cache jika ada imageUrl
    if (imageUrl != null && imageUrl!.startsWith('data:image')) {
      try {
        final base64String = imageUrl!.split(',').last;
        _cachedImageData = base64Decode(base64String);
      } catch (_) {
        _cachedImageData = null;
      }
    } else {
      _cachedImageData = null;
    }
    
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }

  // Reset form (untuk tambah baru)
  void resetForm() {
    editingSaving = null;
    title = '';
    currentAmount = 0.0;
    targetAmount = 5000.0;
    imageUrl = null;
    _cachedImageData = null;
    errorMessage = null;
    isLoading = false;
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
          _cachedImageData = bytes;
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
      errorMessage = 'Nama tabungan tidak boleh kosong';
      notifyListeners();
      return false;
    }
    if (targetAmount <= 0) {
      errorMessage = 'Nominal target tidak boleh kosong atau 0';
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
        await _firestoreService.updateSavingFull(saving);
      } else {
        await _firestoreService.addSaving(saving);
      }

      resetForm();
      return true;
    } catch (e) {
      errorMessage = 'Gagal menyimpan data: $e';
      print('DEBUG: Error saving saving: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
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

  // Update cepat nominal (tambah saldo)
  Future<bool> quickUpdateAmount(String id, double current, double amountToAdd) async {
    if (amountToAdd <= 0) return false;
    
    isLoading = true;
    notifyListeners();
    
    try {
      final newTotal = current + amountToAdd;
      await _firestoreService.updateSaving(id, newTotal);
      return true;
    } catch (e) {
      errorMessage = 'Gagal update nominal: $e';
      print('DEBUG: Error updating amount: $e');
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
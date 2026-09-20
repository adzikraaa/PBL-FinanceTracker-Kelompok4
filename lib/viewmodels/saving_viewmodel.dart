import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../data/models/saving_model.dart';
import '../data/services/firestore_service.dart';

class SavingViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<SavingModel> _savings = [];
  List<SavingModel> get savings => _savings;

  bool isLoading = false;
  String? errorMessage;
  
  // Cache untuk data gambar agar tidak flicker
  Uint8List? _cachedImageData;
  Uint8List? get cachedImageData => _cachedImageData;
  
  MemoryImage? _cachedMemoryImage;
  String? _lastImageUrl;

  MemoryImage? getCachedImage(String url) {
    if (url.startsWith('data:image')) {
      if (url == _lastImageUrl && _cachedMemoryImage != null) {
        return _cachedMemoryImage;
      }
      try {
        final base64String = url.split(',').last;
        _cachedMemoryImage = MemoryImage(base64Decode(base64String));
        _lastImageUrl = url;
        return _cachedMemoryImage;
      } catch (e) {
        return null;
      }
    }
    return null;
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

  // Expected completion otomatis (diprediksi dari rata-rata tabungan per bulan saat ini)
  String getExpectedCompletion(SavingModel saving) {
    if (saving.currentAmount >= saving.targetAmount) return 'Selesai!';

    // 1. Hitung berapa hari sejak tabungan dibuat
    int daysElapsed = DateTime.now().difference(saving.createdAt).inDays;
    
    // 2. Jika kurang dari 30 hari (1 bulan), asumsikan sebagai 1 bulan 
    //    agar bisa menghitung rata-rata (mencegah pembagian dengan 0)
    double monthsElapsed = daysElapsed < 30 ? 1.0 : daysElapsed / 30.0;
    
    // 3. Rata-rata tabungan per bulan berdasarkan data saat ini
    double averageMonthlySaving = saving.currentAmount / monthsElapsed;
    
    // Jika belum ada uang yang ditabung
    if (averageMonthlySaving <= 0) return 'Belum diprediksi';

    // 4. Sisa target yang harus dicapai
    double sisa = saving.targetAmount - saving.currentAmount;
    
    // 5. Prediksi sisa bulan yang dibutuhkan
    int bulanSisa = (sisa / averageMonthlySaving).ceil();
    
    // 6. Tanggal selesai = hari ini ditambah sisa bulan
    DateTime selesai = DateTime.now().add(Duration(days: bulanSisa * 30));
    
    const monthNames = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${monthNames[selesai.month]} ${selesai.year}';
  }

  // Listen realtime dari Firestore
  void listenSavings(String userId) {
    _firestoreService.streamSavings(userId).listen((data) {
      _savings = data;
      notifyListeners();
    });
  }

  // Isi form untuk edit
  void loadForEdit(SavingModel saving) {
    editingSaving = saving;
    title = saving.title;
    currentAmount = saving.currentAmount;
    targetAmount = saving.targetAmount;
    imageUrl = saving.imageUrl;
    _cachedMemoryImage = null; // Reset cache when loading new image
    _lastImageUrl = null;
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
    _cachedMemoryImage = null;
    _lastImageUrl = null;
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
          // Simpan as base64 untuk persistensi sederhana
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
      errorMessage = 'Nama tabungan harus diisi';
      notifyListeners();
      return false;
    }
    if (targetAmount <= 0) {
      errorMessage = 'Target tabungan harus diisi dan lebih dari 0';
      notifyListeners();
      return false;
    }
    if (targetAmount < 1000) {
      errorMessage = 'Minimal target tabungan adalah 1.000';
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

      // Gunakan timeout yang lebih pendek dan tetap anggap sukses jika data sudah masuk buffer lokal
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
      await _firestoreService.updateSaving(id, newTotal)
          .timeout(const Duration(seconds: 3))
          .catchError((_) => null);
      return true;
    } catch (e) {
      errorMessage = 'Gagal update nominal: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

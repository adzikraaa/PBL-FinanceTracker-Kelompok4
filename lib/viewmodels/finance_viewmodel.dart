import 'package:flutter/material.dart';
import '../data/models/hpp_model.dart'; //

class FinanceViewModel extends ChangeNotifier {
  // --- Input Variables (State) ---
  double biayaProduksi = 0.0;
  double biayaTenagaKerja = 0.0;
  double biayaOverhead = 0.0;
  int jumlahUnit = 0;
  
  double hargaJualUnit = 0.0;
  double biayaTetap = 0.0;
  int? jumlahUnitTerjual;
  
  String namaProduk = "Produk Baru";

  // --- History untuk Insight ---
  final List<HppModel> history = [
    HppModel(
      id: '1',
      userId: 'anon',
      namaProduk: 'Nasi Goreng Spesial',
      biayaProduksi: 18000,
      biayaTenagaKerja: 8000,
      biayaOverhead: 4000,
      jumlahUnit: 150,
      biayaTetap: 120000,
      hargaJualUnit: 25000,
      jumlahUnitTerjual: 120,
      totalHpp: 30000,
      bepUnit: 8,
      bepRupiah: 200000,
      catatan: 'Analisa penjualan bulan ini',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    HppModel(
      id: '2',
      userId: 'anon',
      namaProduk: 'Kopi Susu Kekinian',
      biayaProduksi: 15000,
      biayaTenagaKerja: 7000,
      biayaOverhead: 3500,
      jumlahUnit: 120,
      biayaTetap: 100000,
      hargaJualUnit: 22000,
      jumlahUnitTerjual: 110,
      totalHpp: 25500,
      bepUnit: 10,
      bepRupiah: 220000,
      catatan: 'Produk laris akhir pekan',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    HppModel(
      id: '3',
      userId: 'anon',
      namaProduk: 'Roti Tawar Premium',
      biayaProduksi: 12000,
      biayaTenagaKerja: 5000,
      biayaOverhead: 2500,
      jumlahUnit: 80,
      biayaTetap: 80000,
      hargaJualUnit: 20000,
      jumlahUnitTerjual: 70,
      totalHpp: 19500,
      bepUnit: 6,
      bepRupiah: 120000,
      catatan: 'Stok cukup',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    HppModel(
      id: '4',
      userId: 'anon',
      namaProduk: 'Ayam Goreng Kampung',
      biayaProduksi: 20000,
      biayaTenagaKerja: 9000,
      biayaOverhead: 5000,
      jumlahUnit: 100,
      biayaTetap: 150000,
      hargaJualUnit: 35000,
      jumlahUnitTerjual: 95,
      totalHpp: 34000,
      bepUnit: 7,
      bepRupiah: 245000,
      catatan: 'Permintaan tinggi',
      createdAt: DateTime.now(),
    ),
    HppModel(
      id: '5',
      userId: 'anon',
      namaProduk: 'Bakso Sapi Rumahan',
      biayaProduksi: 16000,
      biayaTenagaKerja: 6000,
      biayaOverhead: 3000,
      jumlahUnit: 110,
      biayaTetap: 110000,
      hargaJualUnit: 18000,
      jumlahUnitTerjual: 100,
      totalHpp: 25000,
      bepUnit: 9,
      bepRupiah: 162000,
      catatan: 'Data otomatis disimpan untuk Insight',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  // --- Getters untuk Kalkulasi Otomatis ---

  // Rumus HPP (Sesuai UI baru: Biaya Produksi + Upah + Overhead)
  double get hitungHPP => 
      biayaProduksi + biayaTenagaKerja + biayaOverhead;

  double get modalPerUnit => jumlahUnit > 0 ? hitungHPP / jumlahUnit : 0;

  // Rumus BEP
  // BEP Unit = Biaya Tetap / (Harga Jual per Unit - Biaya Variabel per Unit)
  // Biaya Variabel per Unit diasumsikan sama dengan modalPerUnit
  double get hitungBEPUnit {
    double margin = hargaJualUnit - modalPerUnit;
    if (margin <= 0) return 0; // Menghindari bagi nol atau hasil negatif jika rugi
    return biayaTetap / margin;
  }

  // BEP Rupiah (Omzet) = BEP Unit * Harga Jual
  double get hitungBEPRupiah => hitungBEPUnit * hargaJualUnit;

  // Margin per Unit
  double get marginPerUnit => hargaJualUnit - modalPerUnit;

  // Margin Percentage
  double get marginPercentage => hargaJualUnit > 0 ? (marginPerUnit / hargaJualUnit) * 100 : 0;

  // --- Fungsi Validasi ---
  bool isHppValid() {
    return biayaProduksi >= 0 && 
           biayaTenagaKerja >= 0 &&
           biayaOverhead >= 0 &&
           jumlahUnit > 0;
  }

  bool isBepValid() {
    return isHppValid() && hargaJualUnit > 0 && biayaTetap >= 0;
  }

  // --- Fungsi Simpan ---
  Future<void> simpanPerhitungan(String userId) async {
    if (isBepValid()) {
      final newHpp = HppModel(
        userId: userId,
        namaProduk: namaProduk,
        biayaProduksi: biayaProduksi,
        biayaTenagaKerja: biayaTenagaKerja,
        biayaOverhead: biayaOverhead,
        jumlahUnit: jumlahUnit,
        biayaTetap: biayaTetap,
        hargaJualUnit: hargaJualUnit,
        jumlahUnitTerjual: jumlahUnitTerjual,
        totalHpp: hitungHPP,
        bepUnit: hitungBEPUnit,
        bepRupiah: hitungBEPRupiah,
        catatan: '', 
        createdAt: DateTime.now(),
      );

      // Panggil Firestore service kamu di sini
      // await _firestoreService.addHpp(newHpp); 
      
      notifyListeners();
    }
  }

  // --- Getters untuk Insight View ---
  int get totalProducts => history.isEmpty ? 1 : history.length;

  double get averageHpp {
    if (history.isEmpty) return 0;
    final sum = history.fold<double>(0, (sum, item) => sum + item.totalHpp);
    return sum / history.length;
  }

  String get totalBepAchievedPercent {
    if (history.isEmpty) return '0%';
    int totalAchieved = 0;
    for (var item in history) {
      if (item.jumlahUnitTerjual != null && item.jumlahUnitTerjual! >= item.bepUnit) {
        totalAchieved++;
      }
    }
    final percentage = (totalAchieved / history.length) * 100;
    return '${percentage.toStringAsFixed(0)}%';
  }

  int get performanceScore {
    if (history.isEmpty) return 0;
    int score = 0;
    
    // 1. Hitung persentase BEP tercapai (0-30 poin)
    int bepCount = 0;
    for (var item in history) {
      if (item.jumlahUnitTerjual != null && item.jumlahUnitTerjual! >= item.bepUnit) {
        bepCount++;
      }
    }
    score += ((bepCount / history.length) * 30).toInt();
    
    // 2. Hitung rata-rata margin (0-35 poin)
    double avgMargin = 0;
    for (var item in history) {
      avgMargin += ((item.hargaJualUnit - (item.totalHpp / item.jumlahUnit)) / item.hargaJualUnit) * 100;
    }
    avgMargin = avgMargin / history.length;
    score += ((avgMargin / 50) * 35).toInt();
    
    // 3. Consistency (0-20 poin) - berdasarkan jumlah produk
    score += ((history.length / 10) * 20).toInt();
    
    // 4. Growth trend (0-15 poin) - newest items memiliki BEP lebih baik
    if (history.length > 1) {
      final newestItem = history.last;
      final oldestItem = history.first;
      if (newestItem.bepRupiah < oldestItem.bepRupiah) {
        score += 15;
      }
    }
    
    return score.clamp(0, 100);
  }

  String get trendLabel {
    return performanceScore > 75 ? 'TRENDING' : 'STABIL';
  }

  String get popularProduct {
    if (history.isEmpty) return 'Tidak ada produk';
    HppModel popular = history.first;
    for (var item in history) {
      if ((item.jumlahUnitTerjual ?? 0) > (popular.jumlahUnitTerjual ?? 0)) {
        popular = item;
      }
    }
    return popular.namaProduk;
  }

  String get efficiencyHeadline {
    final lowestBep = history.isEmpty ? 'Tidak ada' : history.reduce((a, b) => a.bepUnit < b.bepUnit ? a : b);
    if (history.isEmpty) return 'Tidak ada data';
    return 'BEP Terendah:\n${lowestBep.namaProduk}';
  }

  List<double> get weeklyBepSeries {
    if (history.length < 6) {
      return [14, 12, 16, 13, 15, 14];
    }
    return history.map((item) => item.bepUnit.toDouble()).toList();
  }
}
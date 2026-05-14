import 'package:flutter/material.dart';
import '../data/models/hpp_model.dart';

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

  // --- History (Dummy Data untuk testing) ---
  final List<HppModel> history = [
    HppModel(
      id: '1',
      userId: 'anon',
      namaProduk: 'Kopi Susu',
      biayaProduksi: 8000,
      biayaTenagaKerja: 0,
      biayaOverhead: 0,
      jumlahUnit: 1,
      biayaTetap: 0,
      hargaJualUnit: 15000,
      jumlahUnitTerjual: 200,
      totalHpp: 8000,
      bepUnit: 0,
      bepRupiah: 0,
      catatan: '',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  // ================================
  // PERHITUNGAN
  // ================================

  double get hitungHPP =>
      biayaProduksi + biayaTenagaKerja + biayaOverhead;

  double get modalPerUnit =>
      jumlahUnit > 0 ? hitungHPP / jumlahUnit : 0;

  double get hitungBEPUnit {
    double margin = hargaJualUnit - modalPerUnit;
    if (margin <= 0) return 0;
    return biayaTetap / margin;
  }

  double get hitungBEPRupiah =>
      hitungBEPUnit * hargaJualUnit;

  double get marginPerUnit =>
      hargaJualUnit - modalPerUnit;

  double get marginPercentage =>
      hargaJualUnit > 0 ? (marginPerUnit / hargaJualUnit) * 100 : 0;

  // ================================
  // VALIDASI
  // ================================

  bool isHppValid() {
    return biayaProduksi >= 0 &&
        biayaTenagaKerja >= 0 &&
        biayaOverhead >= 0 &&
        jumlahUnit > 0;
  }

  bool isBepValid() {
    return isHppValid() &&
        hargaJualUnit > 0 &&
        biayaTetap >= 0;
  }

  // ================================
  // SIMPAN DATA
  // ================================

  Future<void> simpanPerhitungan(String userId) async {
    if (!isBepValid()) return;

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

    history.add(newHpp);
    notifyListeners();
  }

  // ================================
  // INSIGHT: TARGET PROFIT & PENJUALAN
  // ================================

  double targetProfitBulanan = 2100000.0;

  void setTargetProfit(double target) {
    targetProfitBulanan = target;
    notifyListeners();
  }

  void updatePenjualan(int index, int delta) {
    if (index >= 0 && index < history.length) {
      int current = history[index].jumlahUnitTerjual ?? 0;
      int newValue = current + delta;
      if (newValue < 0) newValue = 0;
      history[index].jumlahUnitTerjual = newValue;
      notifyListeners();
    }
  }

  double get totalUntungBersih {
    double total = 0.0;
    for (var item in history) {
      int laku = item.jumlahUnitTerjual ?? 0;
      double hppPerUnit = item.jumlahUnit > 0 ? item.totalHpp / item.jumlahUnit : 0;
      double untungPerUnit = item.hargaJualUnit - hppPerUnit;
      total += (laku * untungPerUnit);
    }
    return total;
  }

  double get progressProfit {
    if (targetProfitBulanan <= 0) return 0;
    double prog = totalUntungBersih / targetProfitBulanan;
    return prog.clamp(0.0, 1.0);
  }

  // ================================
  // INSIGHT
  // ================================

  int get totalProducts => history.length;

  double get averageHpp {
    if (history.isEmpty) return 0;

    final sum = history.fold<double>(
      0,
      (sum, item) => sum + item.totalHpp,
    );

    return sum / history.length;
  }

  String get totalBepAchievedPercent {
    if (history.isEmpty) return '0%';

    int totalAchieved = history.where((item) =>
        item.jumlahUnitTerjual != null &&
        item.jumlahUnitTerjual! >= item.bepUnit).length;

    final percentage = (totalAchieved / history.length) * 100;
    return '${percentage.toStringAsFixed(0)}%';
  }

  int get performanceScore {
    if (history.isEmpty) return 0;

    int score = 0;

    int bepCount = history.where((item) =>
        item.jumlahUnitTerjual != null &&
        item.jumlahUnitTerjual! >= item.bepUnit).length;

    score += ((bepCount / history.length) * 30).toInt();

    double avgMargin = history.fold<double>(0, (sum, item) {
      return sum +
          ((item.hargaJualUnit -
                      (item.totalHpp / item.jumlahUnit)) /
                  item.hargaJualUnit) *
              100;
    }) / history.length;

    score += ((avgMargin / 50) * 35).toInt();

    score += ((history.length / 10) * 20).toInt();

    if (history.length > 1) {
      final newestItem = history.last;
      final oldestItem = history.first;

      if (newestItem.bepRupiah < oldestItem.bepRupiah) {
        score += 15;
      }
    }

    return score.clamp(0, 100);
  }

  String get trendLabel =>
      performanceScore > 75 ? 'TRENDING' : 'STABIL';

  String get popularProduct {
    if (history.isEmpty) return 'Tidak ada produk';

    HppModel popular = history.first;

    for (var item in history) {
      if ((item.jumlahUnitTerjual ?? 0) >
          (popular.jumlahUnitTerjual ?? 0)) {
        popular = item;
      }
    }

    return popular.namaProduk;
  }

  // ================================
  // FIX ERROR (AMAN)
  // ================================

  String get efficiencyHeadline {
    if (history.isEmpty) return 'Tidak ada data';

    final HppModel lowestBep = history.reduce(
      (a, b) => a.bepUnit < b.bepUnit ? a : b,
    );

    return 'BEP Terendah:\n${lowestBep.namaProduk}';
  }

  // ================================
  // CHART DATA (SUDAH BENAR)
  // ================================

  List<double> get weeklyBepSeries {
    if (history.length < 6) {
      return [14, 12, 16, 13, 15, 14];
    }

    return history
        .map((item) => item.bepUnit.toDouble())
        .toList();
  }
}
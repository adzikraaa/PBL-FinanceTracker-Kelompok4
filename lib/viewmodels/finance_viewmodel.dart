import 'package:flutter/material.dart';
import '../data/models/hpp_model.dart';

class FinanceViewModel extends ChangeNotifier {
  // --- Input Variables (State) ---
  double persediaanAwal = 0.0;
  double pembelianBersih = 0.0;
  double biayaTenagaKerja = 0.0;
  double biayaOverhead = 0.0;
  double persediaanAkhir = 0.0;
  int jumlahUnit = 0;
  double biayaTetap = 0.0;
  double hargaJualUnit = 0.0;
  String namaProduk = "Produk Baru";

  final List<HppModel> history = [
    HppModel(
      id: '1',
      userId: 'anon',
      namaProduk: 'Nasi Goreng Spesial',
      persediaanAwal: 18000,
      pembelianBersih: 12000,
      biayaTenagaKerja: 8000,
      biayaOverhead: 4000,
      persediaanAkhir: 9000,
      jumlahUnit: 150,
      biayaTetap: 120000,
      hargaJualUnit: 25000,
      totalHpp: 33000,
      bepUnit: 8,
      bepRupiah: 200000,
      catatan: 'Analisa penjualan bulan ini',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    HppModel(
      id: '2',
      userId: 'anon',
      namaProduk: 'Kopi Susu Kekinian',
      persediaanAwal: 15000,
      pembelianBersih: 10000,
      biayaTenagaKerja: 7000,
      biayaOverhead: 3500,
      persediaanAkhir: 8000,
      jumlahUnit: 120,
      biayaTetap: 100000,
      hargaJualUnit: 22000,
      totalHpp: 25500,
      bepUnit: 10,
      bepRupiah: 220000,
      catatan: 'Produk laris akhir pekan',
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
  ];

  // --- Getters untuk Kalkulasi Otomatis ---

  // Rumus HPP
  double get hitungHPP =>
      (persediaanAwal + pembelianBersih + biayaTenagaKerja + biayaOverhead) - persediaanAkhir;

  double get modalPerUnit => jumlahUnit > 0 ? hitungHPP / jumlahUnit : 0;

  // Rumus BEP
  // BEP Unit = Biaya Tetap / (Harga Jual per Unit - Biaya Variabel per Unit)
  double get hitungBEPUnit {
    final margin = hargaJualUnit - modalPerUnit;
    if (margin <= 0) return 0; // Menghindari bagi nol atau hasil negatif jika rugi
    return biayaTetap / margin;
  }

  // BEP Rupiah = BEP Unit * Harga Jual
  double get hitungBEPRupiah => hitungBEPUnit * hargaJualUnit;

  List<double> get weeklyBepSeries {
    if (history.isEmpty) {
      return [10, 14, 18, 16, 20, 22, 19];
    }
    return history.map((item) {
      final value = item.bepRupiah / 10000;
      if (value < 4) return 4.0;
      if (value > 30) return 30.0;
      return value;
    }).toList();
  }

  int get totalProducts => history.isEmpty ? 1 : history.length;

  double get averageHpp {
    if (history.isEmpty) return 12500;
    final total = history.map((item) => item.totalHpp).reduce((a, b) => a + b);
    return total / history.length;
  }

  String get totalBepAchievedPercent {
    if (history.isEmpty) return '82%';
    final latest = history.first;
    if (latest.bepRupiah <= 0) return '0%';
    final value = ((latest.totalHpp / latest.bepRupiah) * 100).clamp(0, 100).toInt();
    return '$value%';
  }

  String get popularProduct =>
      history.isNotEmpty ? history.first.namaProduk : 'Nasi Goreng Spesial';

  int get performanceScore {
    if (history.isEmpty) return 82;
    final score = 70 + (history.first.totalHpp / 1000).round();
    return score.clamp(60, 98);
  }

  String get efficiencyHeadline {
    if (history.isEmpty) return 'BEP +12% Pekan Ini';
    return 'BEP +${(history.first.bepRupiah / 10000).round()}% Pekan Ini';
  }

  String get trendLabel => performanceScore > 75 ? 'TRENDING' : 'STABIL';

  // --- Fungsi Validasi ---
  bool isValid() {
    return persediaanAwal >= 0 &&
           jumlahUnit > 0 &&
           hargaJualUnit > 0 &&
           biayaTetap >= 0;
  }

  // --- Fungsi Simpan ---
  Future<void> simpanPerhitungan(String userId) async {
    if (isValid()) {
      final newHpp = HppModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        namaProduk: namaProduk,
        persediaanAwal: persediaanAwal,
        pembelianBersih: pembelianBersih,
        biayaTenagaKerja: biayaTenagaKerja,
        biayaOverhead: biayaOverhead,
        persediaanAkhir: persediaanAkhir,
        jumlahUnit: jumlahUnit,
        biayaTetap: biayaTetap,
        hargaJualUnit: hargaJualUnit,
        totalHpp: hitungHPP,
        bepUnit: hitungBEPUnit,
        bepRupiah: hitungBEPRupiah,
        catatan: 'Data otomatis disimpan untuk Insight',
        createdAt: DateTime.now(),
      );

      history.insert(0, newHpp);
      notifyListeners();
    }
  }
}

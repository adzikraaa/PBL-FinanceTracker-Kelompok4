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

  double persediaanAwal = 0.0;
  double pembelianBersih = 0.0;
  double persediaanAkhir = 0.0;

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
      biayaProduksi: 0.0, // <-- Diperbaiki dari null
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
      biayaProduksi: 0.0, // <-- Diperbaiki dari null
    ),
  ];

  // --- Getters untuk Kalkulasi Otomatis ---

  // Rumus HPP
  double get hitungHPP =>
      (persediaanAwal + pembelianBersih + biayaTenagaKerja + biayaOverhead) -
      persediaanAkhir;

  double get modalPerUnit => jumlahUnit > 0 ? hitungHPP / jumlahUnit : 0;

  double get hitungBEPUnit {
    double margin = hargaJualUnit - modalPerUnit;
    if (margin <= 0) {
      return 0; // Menghindari bagi nol atau hasil negatif jika rugi
    }
    return biayaTetap / margin;
  }

  // BEP Rupiah = BEP Unit * Harga Jual
  double get hitungBEPRupiah => hitungBEPUnit * hargaJualUnit;

  // Margin
  double get marginPerUnit => hargaJualUnit > 0 ? hargaJualUnit - modalPerUnit : 0.0; // <-- Diperbaiki dari null

  double get marginPercentage => hargaJualUnit > 0 ? (marginPerUnit / hargaJualUnit) * 100 : 0.0; // <-- Diperbaiki dari null

  // --- Fungsi Validasi ---
  bool isValid() {
    return persediaanAwal >= 0 &&
        jumlahUnit > 0 &&
        hargaJualUnit > 0 &&
        biayaTetap >= 0;
  }

  bool isBepValid() {
    // Validasi sederhana, pastikan harga jual lebih besar dari modal agar BEP bisa tercapai
    return hargaJualUnit > modalPerUnit; 
  } // <-- Diperbaiki dari empty body

  // ================================
  // SIMPAN DATA
  // ================================

  Future<List<double>> simpanPerhitungan(String userId) async {
    if (isValid()) {
      final newHpp = HppModel(
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
        bepUnit: hitungBEPUnit, // Sudah tidak 0 lagi
        bepRupiah: hitungBEPRupiah, // Sudah tidak 0 lagi
        catatan: '',
        createdAt: DateTime.now(),
        biayaProduksi: 0.0, // <-- Diperbaiki dari null
      );

      // Panggil Firestore service kamu di sini
      // await _firestoreService.addHpp(newHpp);

      // Tambahkan ke lokal jika belum menggunakan Firebase (opsional)
      // history.insert(0, newHpp);

      notifyListeners();
    }

    return history.map((item) => item.bepUnit.toDouble()).toList();
  }

  // Getters for insight view
  List<double> get weeklyBepSeries =>
      history.map((item) => item.bepUnit).toList();

  int get totalProducts => history.length;

  double get averageHpp => history.isNotEmpty
      ? history.map((item) => item.totalHpp).reduce((a, b) => a + b) /
          history.length
      : 0.0;

  double get totalBepAchievedPercent => 85.0; // dummy

  double get performanceScore => 75.0; // dummy

  String get trendLabel => 'Naik'; // dummy

  String get popularProduct => 'Produk A'; // dummy

  String get efficiencyHeadline => 'Efisiensi Baik';
}
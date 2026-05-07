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

  double get modalPerUnit =>
      jumlahUnit > 0 ? hitungHPP / jumlahUnit : 0;

  double get hitungBEPUnit {
    double margin = hargaJualUnit - modalPerUnit;
    if (margin <= 0) return 0; // Menghindari bagi nol atau hasil negatif jika rugi
    return biayaTetap / margin;
  }

  // BEP Rupiah = BEP Unit * Harga Jual
  double get hitungBEPRupiah => hitungBEPUnit * hargaJualUnit;

  // --- Fungsi Validasi ---
  bool isValid() {
    return persediaanAwal >= 0 && 
           jumlahUnit > 0 && 
           hargaJualUnit > 0 && 
           biayaTetap >= 0;
  }

  // ================================
  // SIMPAN DATA
  // ================================

  Future<void> simpanPerhitungan(String userId) async {
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
        bepUnit: hitungBEPUnit,     // Sudah tidak 0 lagi
        bepRupiah: hitungBEPRupiah, // Sudah tidak 0 lagi
        catatan: '', 
        createdAt: DateTime.now(),
      );

      // Panggil Firestore service kamu di sini
      // await _firestoreService.addHpp(newHpp); 
      
      notifyListeners();
    }

    return history
        .map((item) => item.bepUnit.toDouble())
        .toList();
  }
}

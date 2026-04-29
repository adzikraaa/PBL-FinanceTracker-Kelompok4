import 'package:flutter/material.dart';
import '../data/models/hpp_model.dart'; //

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

  // --- Getters untuk Kalkulasi Otomatis ---

  // Rumus HPP
  double get hitungHPP => 
      (persediaanAwal + pembelianBersih + biayaTenagaKerja + biayaOverhead) - persediaanAkhir;

  double get modalPerUnit => jumlahUnit > 0 ? hitungHPP / jumlahUnit : 0;

  // Rumus BEP
  // BEP Unit = Biaya Tetap / (Harga Jual per Unit - Biaya Variabel per Unit)
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

  // --- Fungsi Simpan ---
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
  }
}
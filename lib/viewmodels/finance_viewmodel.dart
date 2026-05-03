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
}
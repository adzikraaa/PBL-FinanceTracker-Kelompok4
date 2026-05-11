import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeViewModel extends ChangeNotifier {
  // ─── Data User ────────────────────────────────────────────────────────────
  String userName = 'user';

  // ─── Data Riwayat ─────────────────────────────────────────────────────────
  String riwayatNama = 'Nasi Goreng Spesial';
  String riwayatHarga = '25.000';
  bool riwayatUntung = true;

  // ─── Data Tabungan ────────────────────────────────────────────────────────
  double tabunganProgress = 0.75;
  String tabunganNama = 'Liburan Akhir Tahun';
  String tabunganTarget = 'Rp 10.000.000';
  String tabunganSaatIni = 'Rp 7.500.000';
  String tabunganSisa = 'Rp 2.5jt lagi menuju target';
  String tabunganEmoji = 'Hampir sampai! 🔥';

  // ─── Data Catatan ─────────────────────────────────────────────────────────
  String catatanJudul = 'Rencana Jual\nFebruari';
  String catatanIsi = 'ksjskkjksjk eksnjcmxmzm ndmfklk.';

  // ─── Bottom Nav ───────────────────────────────────────────────────────────
  int selectedIndex = 2;

  void onNavTapManual(int index) {
    if (index < 0 || index >= 5) return;
    selectedIndex = index;
    notifyListeners();
  }

  void onLihatRiwayat() {
    // TODO: navigasi ke halaman riwayat
  }

  void onTabunganTap() {
    // TODO: navigasi ke halaman tabungan
  }

  void onHppBepTap() {
    // TODO: navigasi ke halaman hitung HPP & BEP
  }

  void onInsightTap() {
    // TODO: navigasi ke halaman insight
  }

  void onCatatanTap() {
    // TODO: navigasi ke halaman catatan
  }
}
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/models/hpp_model.dart';
import '../data/models/monthly_target_model.dart';
import '../data/services/firestore_service.dart';

class FinanceViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<HppModel>>? _sub;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<List<MonthlyTargetModel>>? _targetsSub;
  Map<String, double> monthlyTargets = {};

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
  String catatan = '';
  bool lastSaveSuccess = false; // flag: true setelah simpan berhasil
  
  // Navigation step (0: HPP, 1: BEP, 2: Analysis)
  int currentStep = 0;
  
  void setStep(int step) {
    currentStep = step;
    notifyListeners();
  }

  void updateCatatan(String nilai) {
    catatan = nilai;
    notifyListeners();
  }

  List<HppModel> history = [];

  FinanceViewModel() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _sub?.cancel();
        _sub = _firestoreService.streamFinance(user.uid).listen((data) {
          history = data;
          notifyListeners();
        });
        _targetsSub?.cancel();
        _targetsSub = _firestoreService.streamMonthlyTargets(user.uid).listen((targetsList) {
          monthlyTargets = {
            for (var target in targetsList) "${target.year}_${target.month}": target.target
          };
          notifyListeners();
        });
      } else {
        _sub?.cancel();
        _targetsSub?.cancel();
        history = [];
        monthlyTargets = {};
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _targetsSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  // --- Target & Penjualan Bulanan ---
  double getTargetProfitForMonth(DateTime month) {
    final key = "${month.year}_${month.month}";
    return monthlyTargets[key] ?? 0.0;
  }

  Future<void> simpanPenjualanDanTarget(DateTime month, double target, Map<String, int> salesMap) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Simpan target bulanan ke Firestore
    final docId = "${user.uid}_${month.year}_${month.month}";
    final targetModel = MonthlyTargetModel(
      id: docId,
      userId: user.uid,
      year: month.year,
      month: month.month,
      target: target,
    );
    await _firestoreService.saveMonthlyTarget(targetModel);

    // Simpan perubahan jumlahUnitTerjual dari seluruh history yang diubah secara paralel
    final futures = <Future>[];
    for (int i = 0; i < history.length; i++) {
      final item = history[i];
      final prodKey = item.id ?? 'idx_$i';
      if (salesMap.containsKey(prodKey)) {
        final newSales = salesMap[prodKey]!;
        if (item.id != null) {
          futures.add(_firestoreService.updateFinance(item.id!, {
            'jumlahUnitTerjual': newSales,
          }));
        }
        item.jumlahUnitTerjual = newSales;
      }
    }
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
    notifyListeners();
  }

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
  double get marginPerUnit => hargaJualUnit > 0 ? hargaJualUnit - modalPerUnit : 0.0;

  double get marginPercentage => hargaJualUnit > 0 ? (marginPerUnit / hargaJualUnit) * 100 : 0.0;

  // --- Fungsi Validasi ---
  bool isValid() {
    return persediaanAwal >= 0 &&
        jumlahUnit > 0 &&
        hargaJualUnit > 0 &&
        biayaTetap >= 0;
  }

  bool isBepValid() {
    // Validasi: Harga jual harus lebih tinggi dari modal per unit agar BEP bisa dicapai
    return hargaJualUnit > 0 && modalPerUnit >= 0 && hargaJualUnit > modalPerUnit;
  }

  // ================================
  // SIMPAN DATA
  // ================================

  Future<void> simpanPerhitungan(String? _) async {
    if (!isBepValid()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newHpp = HppModel(
      userId: user.uid,
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
      catatan: catatan,
      createdAt: DateTime.now(),
      persediaanAwal: persediaanAwal,
      pembelianBersih: pembelianBersih,
      persediaanAkhir: persediaanAkhir,
    );

    await _firestoreService.addFinance(newHpp);
    // Also save a snapshot to riwayat (history) for Insight and immutable records
    await _firestoreService.addHistory(newHpp);

  }

  // ================================
  // INSIGHT: TARGET PROFIT & PENJUALAN
  // ================================

  double get targetProfitBulanan {
    final now = DateTime.now();
    return getTargetProfitForMonth(now);
  }

  void setTargetProfit(double target) {
    final now = DateTime.now();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docId = "${user.uid}_${now.year}_${now.month}";
      final targetModel = MonthlyTargetModel(
        id: docId,
        userId: user.uid,
        year: now.year,
        month: now.month,
        target: target,
      );
      _firestoreService.saveMonthlyTarget(targetModel);
    }
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
    final now = DateTime.now();
    double total = 0.0;
    for (var item in history) {
      if (item.createdAt.year == now.year && item.createdAt.month == now.month) {
        int laku = item.jumlahUnitTerjual ?? 0;
        double hppPerUnit = item.jumlahUnit > 0 ? item.totalHpp / item.jumlahUnit : 0;
        double untungPerUnit = item.hargaJualUnit - hppPerUnit;
        total += (laku * untungPerUnit);
      }
    }
    return total;
  }

  double get progressProfit {
    final target = targetProfitBulanan;
    if (target <= 0) return 0;
    double prog = totalUntungBersih / target;
    return prog.clamp(0.0, 1.0);
  }

  void resetData() {
    biayaProduksi = 0.0;
    biayaTenagaKerja = 0.0;
    biayaOverhead = 0.0;
    jumlahUnit = 0;
    hargaJualUnit = 0.0;
    biayaTetap = 0.0;
    jumlahUnitTerjual = null;
    namaProduk = "Produk Baru";
    catatan = '';
    persediaanAwal = 0.0;
    pembelianBersih = 0.0;
    persediaanAkhir = 0.0;
    currentStep = 0;
    lastSaveSuccess = false;
    notifyListeners();
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
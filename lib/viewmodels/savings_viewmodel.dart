import 'package:flutter/material.dart';
import '../models/saving_item.dart';

class SavingsViewModel extends ChangeNotifier {
  final List<SavingItem> savings = [
    SavingItem(
      id: 'tab1',
      name: 'Dana Darurat',
      currentAmount: 3500000,
      targetAmount: 5000000,
      notes: 'Jaga kestabilan bisnis saat stok bumbu naik.',
      expectedCompletion: 'Okt 2025',
      iconUrl: null,
    ),
    SavingItem(
      id: 'tab2',
      name: 'Investasi Promo',
      currentAmount: 2000000,
      targetAmount: 8000000,
      notes: 'Untuk kampanye diskon akhir bulan.',
      expectedCompletion: 'Jan 2026',
      iconUrl: null,
    ),
  ];

  double get totalCurrentAmount =>
      savings.fold(0, (value, item) => value + item.currentAmount);

  void addSaving(SavingItem item) {
    savings.add(item);
    notifyListeners();
  }

  void updateSaving(SavingItem item) {
    final index = savings.indexWhere((element) => element.id == item.id);
    if (index >= 0) {
      savings[index] = item;
      notifyListeners();
    }
  }

  void deleteSaving(String? id) {
    if (id == null) return;
    savings.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}

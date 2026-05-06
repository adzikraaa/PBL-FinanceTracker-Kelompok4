import 'package:flutter/material.dart';

class SavingItem {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime createdAt;

  SavingItem({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.createdAt,
  });
}

class SavingsViewModel extends ChangeNotifier {
  final List<SavingItem> _savings = [
    SavingItem(
      id: '1',
      name: 'Modal Baru',
      targetAmount: 5000000,
      currentAmount: 3500000,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    SavingItem(
      id: '2',
      name: 'Cicilan Mesin',
      targetAmount: 10000000,
      currentAmount: 6200000,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    SavingItem(
      id: '3',
      name: 'Dana Darurat',
      targetAmount: 2000000,
      currentAmount: 1800000,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  List<SavingItem> get savings => _savings;

  double get totalSavings => _savings.fold(0, (sum, item) => sum + item.currentAmount);

  double get totalTarget => _savings.fold(0, (sum, item) => sum + item.targetAmount);

  double get savingsPercentage {
    if (totalTarget == 0) return 0;
    return (totalSavings / totalTarget) * 100;
  }

  void addSaving(SavingItem item) {
    _savings.add(item);
    notifyListeners();
  }

  void removeSaving(String id) {
    _savings.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void updateSaving(String id, double newAmount) {
    final index = _savings.indexWhere((item) => item.id == id);
    if (index != -1) {
      _savings[index] = SavingItem(
        id: _savings[index].id,
        name: _savings[index].name,
        targetAmount: _savings[index].targetAmount,
        currentAmount: newAmount,
        createdAt: _savings[index].createdAt,
      );
      notifyListeners();
    }
  }
}

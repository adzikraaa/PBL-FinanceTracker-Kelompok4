class SavingItem {
  String id;
  String name;
  double currentAmount;
  double targetAmount;
  String notes;
  String expectedCompletion;
  String? iconUrl;

  SavingItem({
    required this.id,
    required this.name,
    required this.currentAmount,
    required this.targetAmount,
    this.notes = '',
    this.expectedCompletion = 'Dec 2025',
    this.iconUrl,
  });

  double get progress {
    if (targetAmount <= 0) return 0;
    return (currentAmount / targetAmount).clamp(0, 1);
  }

  double get remainingAmount =>
      currentAmount >= targetAmount ? 0 : targetAmount - currentAmount;
}

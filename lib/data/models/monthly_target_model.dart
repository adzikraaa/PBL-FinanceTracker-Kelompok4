class MonthlyTargetModel {
  final String id;
  final String userId;
  final int year;
  final int month;
  final double target;

  MonthlyTargetModel({
    required this.id,
    required this.userId,
    required this.year,
    required this.month,
    required this.target,
  });

  factory MonthlyTargetModel.fromJson(Map<String, dynamic> json, String docId) {
    return MonthlyTargetModel(
      id: docId,
      userId: json['userId'] ?? '',
      year: json['year'] ?? 0,
      month: json['month'] ?? 0,
      target: (json['target'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'year': year,
      'month': month,
      'target': target,
    };
  }
}

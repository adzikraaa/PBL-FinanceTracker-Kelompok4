class SavingModel {
  String? id;
  String userId;
  String title;
  double targetAmount;
  double currentAmount;
  DateTime createdAt;
  String? imageUrl;

  SavingModel({
    this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.createdAt,
    this.imageUrl,
  });

  // Konversi dari JSON (Firestore) ke Object Flutter
  factory SavingModel.fromJson(Map<String, dynamic> json, String docId) {
    return SavingModel(
      id: docId,
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      targetAmount: (json['targetAmount'] ?? 0).toDouble(),
      currentAmount: (json['currentAmount'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      imageUrl: json['imageUrl'],
    );
  }

  // Konversi dari Object Flutter ke JSON untuk disimpan di Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}
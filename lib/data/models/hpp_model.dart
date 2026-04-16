class HppModel {
  String? id;
  String userId;
  double totalHpp;
  double bepUnit;
  double bepRupiah;
  String catatan;
  DateTime createdAt;

  HppModel({
    this.id,
    required this.userId,
    required this.totalHpp,
    required this.bepUnit,
    required this.bepRupiah,
    required this.catatan,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'totalHpp': totalHpp,
    'bepUnit': bepUnit,
    'bepRupiah': bepRupiah,
    'catatan': catatan,
    'createdAt': createdAt.toIso8601String(),
  };

  factory HppModel.fromJson(Map<String, dynamic> json, String docId) => HppModel(
    id: docId,
    userId: json['userId'],
    totalHpp: json['totalHpp'].toDouble(),
    bepUnit: json['bepUnit'].toDouble(),
    bepRupiah: json['bepRupiah'].toDouble(),
    catatan: json['catatan'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
  );
}
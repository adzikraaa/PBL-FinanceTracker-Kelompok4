class HppModel {
  String? id;
  String userId;
  String namaProduk;

  double biayaProduksi;
  double biayaTenagaKerja;
  double biayaOverhead;
  int jumlahUnit;
  double biayaTetap;
  double hargaJualUnit;
  int? jumlahUnitTerjual;

  double totalHpp;
  double bepUnit;
  double bepRupiah;
  String catatan;
  DateTime createdAt;

  HppModel({
    this.id,
    required this.userId,
    required this.namaProduk,
    required this.biayaProduksi,
    required this.biayaTenagaKerja,
    required this.biayaOverhead,
    required this.jumlahUnit,
    required this.biayaTetap,
    required this.hargaJualUnit,
    this.jumlahUnitTerjual,
    required this.totalHpp,
    required this.bepUnit,
    required this.bepRupiah,
    required this.catatan,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'namaProduk': namaProduk,
    'biayaProduksi': biayaProduksi,
    'biayaTenagaKerja': biayaTenagaKerja,
    'biayaOverhead': biayaOverhead,
    'jumlahUnit': jumlahUnit,
    'biayaTetap': biayaTetap,
    'hargaJualUnit': hargaJualUnit,
    'jumlahUnitTerjual': jumlahUnitTerjual,
    'totalHpp': totalHpp,
    'bepUnit': bepUnit,
    'bepRupiah': bepRupiah,
    'catatan': catatan,
    'createdAt': createdAt.toIso8601String(),
  };

  factory HppModel.fromJson(Map<String, dynamic> json, String docId) => HppModel(
    id: docId,
    userId: json['userId'],
    namaProduk: json['namaProduk'],
    biayaProduksi: json['biayaProduksi']?.toDouble() ?? 0.0,
    biayaTenagaKerja: json['biayaTenagaKerja']?.toDouble() ?? 0.0,
    biayaOverhead: json['biayaOverhead']?.toDouble() ?? 0.0,
    jumlahUnit: json['jumlahUnit'] ?? 0,
    biayaTetap: json['biayaTetap']?.toDouble() ?? 0.0,
    hargaJualUnit: json['hargaJualUnit']?.toDouble() ?? 0.0,
    jumlahUnitTerjual: json['jumlahUnitTerjual'],
    totalHpp: json['totalHpp']?.toDouble() ?? 0.0,
    bepUnit: json['bepUnit']?.toDouble() ?? 0.0,
    bepRupiah: json['bepRupiah']?.toDouble() ?? 0.0,
    catatan: json['catatan'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
  );
}
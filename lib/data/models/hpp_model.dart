class HppModel {
  String? id;
  String userId;
  String namaProduk;

  double persediaanAwal;
  double pembelianBersih;
  double biayaTenagaKerja;
  double biayaOverhead;
  double persediaanAkhir;
  int jumlahUnit;
  double biayaTetap;
  double hargaJualUnit;

  double totalHpp;
  double bepUnit;
  double bepRupiah;
  String catatan;
  DateTime createdAt;

  HppModel({
    this.id,
    required this.userId,
    required this.namaProduk,
    required this.persediaanAwal,
    required this.pembelianBersih,
    required this.biayaTenagaKerja,
    required this.biayaOverhead,
    required this.persediaanAkhir,
    required this.jumlahUnit,
    required this.biayaTetap,
    required this.hargaJualUnit,

    required this.totalHpp,
    required this.bepUnit,
    required this.bepRupiah,
    required this.catatan,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'namaProduk': namaProduk,
    'persediaanAwal': persediaanAwal,
    'pembelianBersih': pembelianBersih,
    'biayaTenagaKerja': biayaTenagaKerja,
    'biayaOverhead': biayaOverhead,
    'persediaanAkhir': persediaanAkhir,
    'jumlahUnit': jumlahUnit,
    'biayaTetap': biayaTetap,
    'hargaJualUnit': hargaJualUnit,

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
    persediaanAwal: json['persediaanAwal'].toDouble(),
    pembelianBersih: json['pembelianBersih'].toDouble(),
    biayaTenagaKerja: json['biayaTenagaKerja'].toDouble(),
    biayaOverhead: json['biayaOverhead'].toDouble(),
    persediaanAkhir: json['persediaanAkhir'].toDouble(),
    jumlahUnit: json['jumlahUnit'],
    biayaTetap: json['biayaTetap'].toDouble(),
    hargaJualUnit: json['hargaJualUnit'].toDouble(),
    
    totalHpp: json['totalHpp'].toDouble(),
    bepUnit: json['bepUnit'].toDouble(),
    bepRupiah: json['bepRupiah'].toDouble(),
    catatan: json['catatan'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
  );
}
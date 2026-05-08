import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/hpp_model.dart';

class PdfService {
  static final _currencyFmt = NumberFormat.currency(
    locale: 'id_ID', 
    symbol: 'Rp ', 
    decimalDigits: 0
  );

  static Future<pw.Document> _generatePdf(HppModel data) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    final margin = data.hargaJualUnit - (data.jumlahUnit > 0 ? data.totalHpp / data.jumlahUnit : 0.0);
    final marginPct = data.hargaJualUnit > 0 ? (margin / data.hargaJualUnit * 100) : 0.0;
    final hppPerUnit = data.jumlahUnit > 0 ? data.totalHpp / data.jumlahUnit : 0.0;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Text(
                    'LAPORAN PERHITUNGAN HPP & BEP',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#163520'),
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Center(
                  child: pw.Text(
                    'BizPrice App',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColor.fromHex('#6B7280'),
                    ),
                  ),
                ),
                pw.Divider(thickness: 2, height: 40, color: PdfColor.fromHex('#4ADE80')),

                // Detail Produk
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Nama Produk:', style: const pw.TextStyle(fontSize: 10)),
                        pw.Text(
                          data.namaProduk,
                          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Tanggal Perhitungan:', style: const pw.TextStyle(fontSize: 10)),
                        pw.Text(
                          DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(data.createdAt),
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),

                // Table 1: Rincian Biaya
                pw.Text('1. Rincian Biaya Produksi', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                _buildTable([
                  ['Biaya Produksi', _currencyFmt.format(data.biayaProduksi)],
                  ['Upah Tenaga Kerja', _currencyFmt.format(data.biayaTenagaKerja)],
                  ['Biaya Overhead', _currencyFmt.format(data.biayaOverhead)],
                  ['Target Produksi', '${data.jumlahUnit.toStringAsFixed(0)} Unit'],
                  ['TOTAL HPP', _currencyFmt.format(data.totalHpp), true],
                  ['HPP PER UNIT', _currencyFmt.format(hppPerUnit), true],
                ]),

                pw.SizedBox(height: 30),

                // Table 2: Analisis Keuntungan & BEP
                pw.Text('2. Analisis Keuntungan & BEP', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                _buildTable([
                  ['Biaya Tetap', _currencyFmt.format(data.biayaTetap)],
                  ['Harga Jual Per Unit', _currencyFmt.format(data.hargaJualUnit)],
                  ['Profit Margin', '${marginPct.toStringAsFixed(1)}%'],
                  ['BEP (Titik Impas) Unit', '${data.bepUnit.toStringAsFixed(0)} Unit', true],
                  ['BEP (Titik Impas) Rupiah', _currencyFmt.format(data.bepRupiah), true],
                ]),

                pw.Spacer(),

                // Footer
                pw.Divider(color: PdfColors.grey400),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    'Dibuat oleh BizPrice - Solusi UMKM Pintar',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  static Future<void> shareHpp(HppModel data) async {
    final pdf = await _generatePdf(data);
    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Laporan_HPP_${data.namaProduk.replaceAll(' ', '_')}.pdf',
    );
  }

  static Future<void> downloadHpp(HppModel data) async {
    final pdf = await _generatePdf(data);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_HPP_${data.namaProduk.replaceAll(' ', '_')}.pdf',
    );
  }

  static pw.Widget _buildTable(List<List<dynamic>> rows) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: rows.map((row) {
        final isHighlight = row.length > 2 && row[2] == true;
        return pw.TableRow(
          decoration: isHighlight ? const pw.BoxDecoration(color: PdfColors.grey100) : null,
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                row[0].toString(),
                style: pw.TextStyle(fontWeight: isHighlight ? pw.FontWeight.bold : null),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                row[1].toString(),
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontWeight: isHighlight ? pw.FontWeight.bold : null),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

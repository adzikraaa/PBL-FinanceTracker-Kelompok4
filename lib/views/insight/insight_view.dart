import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/finance_viewmodel.dart';
import '../../utils/currency_formatter.dart';
import '../finance/hitung_hpp_page.dart';

const Color kBg = Color(0xFF0A1F12);
const Color kCardDark = Color(0xFF132F1D);
const Color kCardLight = Color(0xFFB5E48C);
const Color kTextDark = Color(0xFF1A3A10);
const Color kGreenAccent = Color(0xFF6CF688);
const Color kWhite = Colors.white;

class InsightView extends StatefulWidget {
  const InsightView({super.key});

  @override
  State<InsightView> createState() => _InsightViewState();
}

class _InsightViewState extends State<InsightView> {

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceViewModel>();

    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120, left: 16, right: 16, top: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildDonutCard(finance),
                  const SizedBox(height: 16),
                  _buildMetricsGrid(finance),
                  const SizedBox(height: 16),
                  _buildCatatPenjualan(finance),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Insight',
                style: TextStyle(
                  color: kWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Grafik Perhitungan HPP & BEP',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Text(
                DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now()),
                style: const TextStyle(color: kTextDark, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, color: kTextDark, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDonutCard(FinanceViewModel finance) {
    double sisaTarget = finance.targetProfitBulanan - finance.totalUntungBersih;
    if (sisaTarget < 0) sisaTarget = 0;
    
    int cupsLagi = 0;
    if (sisaTarget > 0 && finance.history.isNotEmpty) {
      double avgHpp = finance.averageHpp;
      double avgJual = finance.history.fold<double>(0, (sum, item) => sum + item.hargaJualUnit) / finance.history.length;
      double avgMargin = avgJual - avgHpp;
      if (avgMargin > 0) {
        cupsLagi = (sisaTarget / avgMargin).ceil();
      } else {
        cupsLagi = (sisaTarget / 5000).ceil(); 
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => _showEditDataDialog(context, finance),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: kCardLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle_outline, color: kTextDark, size: 16),
                    SizedBox(width: 6),
                    Text('Set Target', style: TextStyle(color: kTextDark, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(140, 140),
                  painter: _DonutChartPainter(
                    progress: finance.progressProfit,
                    trackColor: const Color(0xFFE8F5E9),
                    progressColor: const Color(0xFF2E7D32),
                    strokeWidth: 14.0,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(finance.progressProfit * 100).toInt()}%',
                      style: const TextStyle(color: kTextDark, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const Text('tercapai', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(const Color(0xFF2E7D32), 'Untung terkumpul'),
              const SizedBox(width: 16),
              _buildLegend(const Color(0xFFE8F5E9), 'Kurang dari target'),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF9BF4A5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: kTextDark, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'Bagus! Kamu sudah mencapai ',
                      style: const TextStyle(color: kTextDark, fontSize: 12),
                      children: [
                        TextSpan(text: '${(finance.progressProfit * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: ' dari target. Jual '),
                        TextSpan(text: '$cupsLagi cup', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: ' lagi untuk mencapai target!'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildMetricsGrid(FinanceViewModel finance) {
    double sisaTarget = finance.targetProfitBulanan - finance.totalUntungBersih;
    if (sisaTarget < 0) sisaTarget = 0;

    int totalTerjual = finance.history.fold<int>(0, (sum, item) => sum + (item.jumlahUnitTerjual ?? 0));

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      children: [
        _buildMetricCard('UNTUNG TERKUMPUL', CurrencyFormatter.formatRupiah(finance.totalUntungBersih), kCardDark, kWhite),
        _buildMetricCard('SISA KE TARGET', CurrencyFormatter.formatRupiah(sisaTarget), kCardLight, kTextDark),
        _buildMetricCard('TARGET PROFIT', CurrencyFormatter.formatRupiah(finance.targetProfitBulanan), kCardLight, kTextDark),
        _buildMetricCard('TOTAL TERJUAL', '$totalTerjual cup', kCardDark, kWhite),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, Color bgColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCatatPenjualan(FinanceViewModel finance) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Catat Penjualan', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Pilih produk & jumlah yang laku hari ini', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 16),
          ...List.generate(finance.history.length, (index) {
            final item = finance.history[index];
            double untungPerCup = item.hargaJualUnit - (item.jumlahUnit > 0 ? item.totalHpp / item.jumlahUnit : 0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.namaProduk, style: const TextStyle(color: kWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('Untung/cup: ${CurrencyFormatter.formatRupiah(untungPerCup)}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => finance.updatePenjualan(index, -1),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.remove, color: Colors.white54, size: 16),
                        ),
                      ),
                      SizedBox(
                        width: 36,
                        child: Text('${item.jumlahUnitTerjual ?? 0}', textAlign: TextAlign.center, style: const TextStyle(color: kWhite, fontWeight: FontWeight.bold)),
                      ),
                      GestureDetector(
                        onTap: () => finance.updatePenjualan(index, 1),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.add, color: Colors.white54, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Penjualan disimpan!')));
              },
              icon: const Icon(Icons.save_alt, color: kTextDark, size: 18),
              label: const Text('Simpan Penjualan', style: TextStyle(color: kTextDark, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kGreenAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDataDialog(BuildContext context, FinanceViewModel finance) {
    final TextEditingController targetController = TextEditingController(text: CurrencyFormatter.formatRupiah(finance.targetProfitBulanan).replaceAll('Rp ', ''));
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            double currentTotal = 0;
            for (var item in finance.history) {
              currentTotal += (item.jumlahUnitTerjual ?? 0) * item.hargaJualUnit;
            }

            return Dialog(
              backgroundColor: kCardDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              insetPadding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Edit Data', style: TextStyle(color: kWhite, fontSize: 18, fontWeight: FontWeight.bold)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close, color: Colors.white54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text('TARGET PROFIT', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Monthly Goal', style: TextStyle(color: Colors.white38, fontSize: 10)),
                            Row(
                              children: [
                                const Text('Rp ', style: TextStyle(color: kCardLight, fontSize: 20, fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: TextField(
                                    controller: targetController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [CurrencyInputFormatter()],
                                    style: const TextStyle(color: kCardLight, fontSize: 24, fontWeight: FontWeight.bold),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('CATAT PENJUALAN', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                          Text('LIVE', style: TextStyle(color: kCardLight, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(finance.history.length, (index) {
                        final item = finance.history[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.coffee, color: Colors.white54, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.namaProduk, style: const TextStyle(color: kWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text('Rp ${CurrencyFormatter.formatRupiah(item.hargaJualUnit).replaceAll('Rp ', '')}/cup', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      finance.updatePenjualan(index, -1);
                                      setStateDialog(() {});
                                    },
                                    child: Container(
                                      width: 28, height: 28,
                                      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(6)),
                                      child: const Icon(Icons.remove, color: Colors.white54, size: 14),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 32,
                                    child: Text('${item.jumlahUnitTerjual ?? 0}', textAlign: TextAlign.center, style: const TextStyle(color: kWhite, fontWeight: FontWeight.bold)),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      finance.updatePenjualan(index, 1);
                                      setStateDialog(() {});
                                    },
                                    child: Container(
                                      width: 28, height: 28,
                                      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(6)),
                                      child: const Icon(Icons.add, color: Colors.white54, size: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Penjualan Hari Ini', style: TextStyle(color: Colors.white54, fontSize: 12)),
                          Text(CurrencyFormatter.formatRupiah(currentTotal), style: const TextStyle(color: kCardLight, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            String targetStr = targetController.text.replaceAll('.', '');
                            if (targetStr.isNotEmpty) {
                              finance.setTargetProfit(double.tryParse(targetStr) ?? 0);
                            }
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perubahan disimpan!')));
                          },
                          icon: const Icon(Icons.save, color: kTextDark, size: 18),
                          label: const Text('Simpan Perubahan', style: TextStyle(color: kTextDark, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD54F),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

}

class _DonutChartPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _DonutChartPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    this.strokeWidth = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

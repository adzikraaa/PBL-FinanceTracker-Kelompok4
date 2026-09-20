import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/finance_viewmodel.dart';
import '../../utils/currency_formatter.dart';
import '../../viewmodels/premium_viewmodel.dart';
import 'dart:ui';
import '../premium/premium_view.dart';

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
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  final Map<String, int> _editingSales = {};

  String _getProductKey(dynamic item, int index) {
    return item.id ?? 'idx_$index';
  }

  // Filter history berdasarkan bulan yang dipilih
  List<MapEntry<int, dynamic>> _filteredIndexed(List<dynamic> history) {
    return history
        .asMap()
        .entries
        .where((e) =>
            e.value.createdAt.year == _selectedMonth.year &&
            e.value.createdAt.month == _selectedMonth.month)
        .toList();
  }

  bool get _isCurrentMonth =>
      _selectedMonth.year == DateTime.now().year &&
      _selectedMonth.month == DateTime.now().month;

  void _showMonthPicker(BuildContext context) {
    int tempYear = _selectedMonth.year;
    final now = DateTime.now();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFD2E3C8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B3D2A).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Year nav
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => setModal(() => tempYear--),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B3D2A).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.chevron_left, color: Color(0xFF0F2E1A), size: 20),
                      ),
                    ),
                    Text(
                      '$tempYear',
                      style: const TextStyle(color: Color(0xFF0F2E1A), fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (tempYear < now.year) setModal(() => tempYear++);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: tempYear < now.year ? const Color(0xFF1B3D2A).withValues(alpha: 0.08) : const Color(0xFF1B3D2A).withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.chevron_right,
                            color: tempYear < now.year ? const Color(0xFF0F2E1A) : const Color(0xFF0F2E1A).withValues(alpha: 0.2), size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Month grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 2.0,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: 12,
                  itemBuilder: (_, i) {
                    final m = i + 1;
                    final isFuture = DateTime(tempYear, m).isAfter(DateTime(now.year, now.month));
                    final isSelected = tempYear == _selectedMonth.year && m == _selectedMonth.month;
                    return GestureDetector(
                      onTap: isFuture
                          ? null
                          : () {
                              setState(() => _selectedMonth = DateTime(tempYear, m));
                              Navigator.pop(ctx);
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1B3D2A)
                              : isFuture
                                  ? const Color(0xFF1B3D2A).withValues(alpha: 0.02)
                                  : const Color(0xFF1B3D2A).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? Border.all(color: const Color(0xFF1B3D2A), width: 2)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          DateFormat('MMM', 'id_ID').format(DateTime(tempYear, m)),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : isFuture
                                    ? const Color(0xFF0F2E1A).withValues(alpha: 0.2)
                                    : const Color(0xFF0F2E1A),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceViewModel>();
    final premiumVm = context.watch<PremiumViewModel>();

    // Filter history berdasarkan bulan dipilih
    final indexed = _filteredIndexed(finance.history);
    final filteredHistory = indexed.map((e) => e.value).toList();

    final targetProfit = finance.getTargetProfitForMonth(_selectedMonth);

    // Hitung metrik dari history yang sudah difilter
    double filteredUntung = filteredHistory.fold(0.0, (sum, item) {
      double untungPerUnit = item.hargaJualUnit -
          (item.jumlahUnit > 0 ? item.totalHpp / item.jumlahUnit : 0);
      return sum + untungPerUnit * (item.jumlahUnitTerjual ?? 0);
    });
    double filteredProgress = targetProfit > 0
        ? (filteredUntung / targetProfit).clamp(0.0, 1.0)
        : 0.0;
    double filteredSisa = targetProfit > 0
        ? (targetProfit - filteredUntung).clamp(0.0, double.infinity)
        : 0.0;
    int filteredTerjual =
        filteredHistory.fold<int>(0, (sum, item) => sum + ((item.jumlahUnitTerjual ?? 0) as int));

    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 160, left: 16, right: 16, top: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildDonutCard(finance, filteredProgress, filteredUntung, filteredSisa),
                  const SizedBox(height: 16),
                  _buildMetricsGrid(finance, filteredUntung, filteredSisa, filteredTerjual),
                  const SizedBox(height: 8),
                  _buildCatatPenjualan(finance, indexed),
                ],
              ),
            ),
          ),
          if (!premiumVm.isPremium) _buildPremiumOverlay(context),
        ],
      ),
    );
  }

  Widget _buildPremiumOverlay(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: kBg.withOpacity(0.7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2D22),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange.withOpacity(0.5), width: 2),
                ),
                child: const Icon(Icons.lock_outline, color: Colors.orange, size: 48),
              ),
              const SizedBox(height: 24),
              const Text(
                'Fitur Insight Terkunci',
                style: TextStyle(color: kWhite, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Upgrade ke Premium untuk membuka analitik bisnis lengkap, grafik profit, dan pemantauan target secara real-time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: context.read<PremiumViewModel>(),
                        child: const PremiumView(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreenAccent,
                  foregroundColor: kTextDark,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 8,
                  shadowColor: kGreenAccent.withOpacity(0.5),
                ),
                child: const Text(
                  'Buka Kunci Premium',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
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
        GestureDetector(
          onTap: () => _showMonthPicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isCurrentMonth ? Colors.white : kGreenAccent.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('MMMM yyyy', 'id_ID').format(_selectedMonth),
                  style: TextStyle(
                    color: _isCurrentMonth ? kTextDark : kTextDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, color: kTextDark, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDonutCard(
    FinanceViewModel finance,
    double filteredProgress,
    double filteredUntung,
    double filteredSisa,
  ) {
    // Hitung estimasi unit yg harus dijual lagi
    int unitLagi = 0;
    if (filteredSisa > 0 && finance.history.isNotEmpty) {
      final filtered = _filteredIndexed(finance.history).map((e) => e.value).toList();
      final src = filtered.isNotEmpty ? filtered : finance.history;
      double avgHpp = src.fold<double>(0, (s, i) => s + (i.jumlahUnit > 0 ? i.totalHpp / i.jumlahUnit : 0)) / src.length;
      double avgJual = src.fold<double>(0, (s, i) => s + i.hargaJualUnit) / src.length;
      double avgMargin = avgJual - avgHpp;
      unitLagi = avgMargin > 0 ? (filteredSisa / avgMargin).ceil() : (filteredSisa / 5000).ceil();
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
                    Text('Atur Target', style: TextStyle(color: kTextDark, fontWeight: FontWeight.bold, fontSize: 12)),
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
                    progress: filteredProgress,
                    trackColor: const Color(0xFFE8F5E9),
                    progressColor: const Color(0xFF2E7D32),
                    strokeWidth: 14.0,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(filteredProgress * 100).toInt()}%',
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
                        TextSpan(text: '${(filteredProgress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: ' dari target. Jual '),
                        TextSpan(text: '$unitLagi unit', style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildMetricsGrid(
    FinanceViewModel finance,
    double filteredUntung,
    double filteredSisa,
    int filteredTerjual,
  ) {
    final targetProfit = finance.getTargetProfitForMonth(_selectedMonth);
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(child: _buildMetricCard('UNTUNG TERKUMPUL', CurrencyFormatter.formatRupiah(filteredUntung), const Color(0xFFD2E3C8), kTextDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard('SISA KE TARGET', CurrencyFormatter.formatRupiah(filteredSisa), kCardLight, kTextDark)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(child: _buildMetricCard('TARGET PROFIT', CurrencyFormatter.formatRupiah(targetProfit), kCardLight, kTextDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard('TOTAL TERJUAL', '$filteredTerjual unit', const Color(0xFFD2E3C8), kTextDark)),
            ],
          ),
        ),
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

  Widget _buildCatatPenjualan(FinanceViewModel finance, List<MapEntry<int, dynamic>> indexed) {
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
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Catat Penjualan', style: TextStyle(color: kWhite, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text('Produk yang laku bulan ini', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (indexed.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, color: Colors.white24, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Tidak ada produk di ${DateFormat('MMMM yyyy', 'id_ID').format(_selectedMonth)}',
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...indexed.map((entry) {
              final originalIndex = entry.key;
              final item = entry.value;
              final prodKey = _getProductKey(item, originalIndex);
              final currentSales = _editingSales[prodKey] ?? (item.jumlahUnitTerjual ?? 0);
              double untungPerUnit = item.hargaJualUnit - (item.jumlahUnit > 0 ? item.totalHpp / item.jumlahUnit : 0);
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
                          Text('Untung/unit: ${CurrencyFormatter.formatRupiah(untungPerUnit)}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                        ],
                      ),
                    ),
                    _SalesCounterWidget(
                      initialValue: currentSales,
                      onChanged: (val) {
                        setState(() {
                          _editingSales[prodKey] = val;
                        });
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final targetProfit = finance.getTargetProfitForMonth(_selectedMonth);
                final messenger = ScaffoldMessenger.of(context);
                await finance.simpanPenjualanDanTarget(_selectedMonth, targetProfit, _editingSales);
                setState(() {
                  _editingSales.clear();
                });
                messenger.showSnackBar(const SnackBar(content: Text('Penjualan disimpan!')));
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
    final initialTarget = finance.getTargetProfitForMonth(_selectedMonth);
    final TextEditingController targetController = TextEditingController(text: CurrencyFormatter.formatRupiah(initialTarget).replaceAll('Rp ', ''));
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final indexed = _filteredIndexed(finance.history);
            double currentTotal = 0;
            for (var entry in indexed) {
              final item = entry.value;
              final prodKey = _getProductKey(item, entry.key);
              final currentSales = _editingSales[prodKey] ?? (item.jumlahUnitTerjual ?? 0);
              currentTotal += currentSales * item.hargaJualUnit;
            }

            return Dialog(
              backgroundColor: const Color(0xFFD2E3C8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: const Color(0xFF8BCA6E).withValues(alpha: 0.3),
                ),
              ),
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
                          const Text('Edit Data', style: TextStyle(color: Color(0xFF0F2E1A), fontSize: 18, fontWeight: FontWeight.bold)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close, color: Color(0xFF0F2E1A)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text('TARGET PROFIT', style: TextStyle(color: Color(0xFF4E6E56), fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B3D2A).withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1B3D2A).withValues(alpha: 0.1)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Target Bulanan', style: TextStyle(color: Color(0xFF4E6E56), fontSize: 10)),
                            Row(
                              children: [
                                const Text('Rp ', style: TextStyle(color: Color(0xFF1B3D2A), fontSize: 20, fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: TextField(
                                    controller: targetController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [CurrencyInputFormatter()],
                                    style: const TextStyle(color: Color(0xFF1B3D2A), fontSize: 24, fontWeight: FontWeight.bold),
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
                          Text('CATAT PENJUALAN', style: TextStyle(color: Color(0xFF4E6E56), fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                          Text('LIVE', style: TextStyle(color: Color(0xFF1B3D2A), fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(indexed.length, (index) {
                        final originalIndex = indexed[index].key;
                        final item = indexed[index].value;
                        final prodKey = _getProductKey(item, originalIndex);
                        final currentSales = _editingSales[prodKey] ?? (item.jumlahUnitTerjual ?? 0);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B3D2A).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1B3D2A).withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(color: const Color(0xFF1B3D2A).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.coffee, color: Color(0xFF1B3D2A), size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.namaProduk, style: const TextStyle(color: Color(0xFF0F2E1A), fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text('Rp ${CurrencyFormatter.formatRupiah(item.hargaJualUnit).replaceAll('Rp ', '')}/unit', style: const TextStyle(color: Color(0xFF4E6E56), fontSize: 10)),
                                  ],
                                ),
                              ),
                              _SalesCounterWidget(
                                initialValue: currentSales,
                                isSmall: true,
                                textColor: const Color(0xFF0F2E1A),
                                onChanged: (val) {
                                  setStateDialog(() {
                                    _editingSales[prodKey] = val;
                                  });
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Penjualan Hari Ini', style: TextStyle(color: Color(0xFF4E6E56), fontSize: 12)),
                          Text(CurrencyFormatter.formatRupiah(currentTotal), style: const TextStyle(color: Color(0xFF1B3D2A), fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            String targetStr = targetController.text.replaceAll('.', '');
                            double target = double.tryParse(targetStr) ?? 0;
                            await finance.simpanPenjualanDanTarget(_selectedMonth, target, _editingSales);
                            setState(() {
                              _editingSales.clear();
                            });
                            navigator.pop();
                            messenger.showSnackBar(const SnackBar(content: Text('Perubahan disimpan!')));
                          },
                          icon: const Icon(Icons.save, color: Colors.white, size: 18),
                          label: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B3D2A),
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

class _SalesCounterWidget extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int> onChanged;
  final bool isSmall;
  final Color? textColor;

  const _SalesCounterWidget({
    required this.initialValue,
    required this.onChanged,
    this.isSmall = false,
    this.textColor,
  });

  @override
  State<_SalesCounterWidget> createState() => _SalesCounterWidgetState();
}

class _SalesCounterWidgetState extends State<_SalesCounterWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
  }

  @override
  void didUpdateWidget(covariant _SalesCounterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue.toString() != _controller.text) {
      final intval = int.tryParse(_controller.text) ?? 0;
      if (intval != widget.initialValue) {
        _controller.text = widget.initialValue.toString();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateValue(int newValue) {
    _controller.text = newValue.toString();
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final double size = widget.isSmall ? 28.0 : 32.0;
    final double iconSize = widget.isSmall ? 14.0 : 16.0;
    final double width = widget.isSmall ? 32.0 : 40.0;
    final Color actualTextColor = widget.textColor ?? kWhite;
    final Color iconColor = widget.textColor?.withValues(alpha: 0.6) ?? Colors.white54;
    final Color borderAccent = widget.textColor?.withValues(alpha: 0.25) ?? Colors.white24;

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            int current = int.tryParse(_controller.text) ?? 0;
            _updateValue(max(0, current - 1));
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              border: Border.all(color: borderAccent),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.remove, color: iconColor, size: iconSize),
          ),
        ),
        SizedBox(
          width: width,
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(color: actualTextColor, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (val) {
              int parsed = int.tryParse(val) ?? 0;
              widget.onChanged(parsed);
            },
          ),
        ),
        GestureDetector(
          onTap: () {
            int current = int.tryParse(_controller.text) ?? 0;
            _updateValue(current + 1);
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              border: Border.all(color: borderAccent),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.add, color: iconColor, size: iconSize),
          ),
        ),
      ],
    );
  }
}

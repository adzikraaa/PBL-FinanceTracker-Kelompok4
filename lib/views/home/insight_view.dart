import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/finance_viewmodel.dart';
import '../../viewmodels/savings_viewmodel.dart';
import '../finance/hitung_hpp_page.dart';

class InsightView extends StatefulWidget {
  const InsightView({super.key});

  @override
  State<InsightView> createState() => _InsightViewState();
}

class _InsightViewState extends State<InsightView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<String> _periods = ['Bulanan', 'Mingguan', 'Harian'];
  String _selectedPeriod = 'Bulanan';
  int _selectedBarIndex = 2;
  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceViewModel>();
    final savings = context.watch<SavingsViewModel>();
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final values = List<double>.from(finance.weeklyBepSeries);
    while (values.length < 6) {
      values.add(values.isNotEmpty ? values.last : 14);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF081E13),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _InsightBackgroundPainter()),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100, top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildSummaryCard(finance, formatter),
                    const SizedBox(height: 20),
                    _buildScoreRow(finance),
                    const SizedBox(height: 20),
                    _buildBarChart(values),
                    const SizedBox(height: 28),
                    _buildInsightStrategies(savings),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNav(),
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
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Grafik Perhitungan HPP & BEP',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPeriod,
              dropdownColor: const Color(0xFF0F3B29),
              borderRadius: BorderRadius.circular(14),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              icon: const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.keyboard_arrow_down, color: Colors.white70),
              ),
              items: _periods
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(value),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPeriod = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(FinanceViewModel finance, NumberFormat formatter) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D4C2D), Color(0xFF116030)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL PRODUK',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      finance.totalProducts.toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  '+8%',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('RATA-RATA HPP',
                        style: TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text(formatter.format(finance.averageHpp),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('TOTAL BEP TERCAPAI',
                        style: TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text(finance.totalBepAchievedPercent,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(FinanceViewModel finance) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Performance score ${finance.performanceScore} aktif.')),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0D3B25),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: finance.performanceScore / 100),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return SizedBox(
                        width: 110,
                        height: 110,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: value,
                              strokeWidth: 12,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9BF4A5)),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${(value * 100).round()}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text('/100',
                                    style: TextStyle(
                                        color: Colors.white54, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Performance Score',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(finance.trendLabel,
                      style: const TextStyle(
                          color: Color(0xFF9BF4A5),
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Produk populer: ${finance.popularProduct}')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D3B25),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TERPOPULER',
                          style: TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 12),
                      Text(finance.popularProduct,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Efisiensi diperbarui.')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14A14C),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('EFISIENSI',
                          style: TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 12),
                      Text(finance.efficiencyHeadline,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<double> values) {
    final labels = ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D3B25),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('BEP PER PRODUK',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Data harian minggu ini', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(values.length, (index) {
              final isActive = index == _selectedBarIndex;
              final barHeight = 130.0 + (values[index] - 10) * 4;
              return GestureDetector(
                onTap: () => setState(() => _selectedBarIndex = index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 26,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF9BF4A5) : const Color(0xFF1E603F),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF9BF4A5).withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(labels[index], style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightStrategies(SavingsViewModel savings) {
    final messages = [
      {
        'title': 'Restok Bahan Baku',
        'subtitle': 'Harga pasar Nasi Goreng menurun 5%, pertimbangkan beli borongan.',
        'icon': Icons.inventory_2,
      },
      {
        'title': 'Margin Tertekan',
        'subtitle': savings.savings.isNotEmpty
            ? 'Produk ${savings.savings.first.name} perlu evaluasi biaya HPP.'
            : 'Produk kopi susu mengalami kenaikan HPP sebesar 15%.',
        'icon': Icons.show_chart,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Insight Strategis',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...messages.map((item) {
          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(item['subtitle'] as String)),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0D3B25),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9BF4A5).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(item['icon'] as IconData, color: const Color(0xFF9BF4A5), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title'] as String,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 6),
                        Text(item['subtitle'] as String,
                            style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildBottomNav() {
    const navIcons = [
      Icons.calculate_outlined, // 0 - HPP & BEP
      Icons.account_balance_wallet_outlined, // 1 - Wallet
      Icons.home, // 2 - Home
      Icons.show_chart, // 3 - Chart (Insight)
      Icons.history, // 4 - History
    ];
    const int navCount = 5;
    const double navHeight = 68.0;
    const double circleSize = 48.0;
    const double circleTop = (navHeight - circleSize) / 2;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final navWidth = constraints.maxWidth;
          final itemWidth = navWidth / navCount;
          final circleLeft =
              itemWidth * _selectedIndex + (itemWidth / 2) - circleSize / 2;

          return SizedBox(
            height: navHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF132018).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(color: const Color(0xFF2C4334), width: 1.5),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOutCubic,
                  left: circleLeft,
                  top: circleTop,
                  child: Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6CF688),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6CF688).withOpacity(0.45),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      navIcons[_selectedIndex],
                      color: const Color(0xFF0C1B13),
                      size: 24,
                    ),
                  ),
                ),
                Row(
                  children: List.generate(navCount, (i) {
                    final isActive = i == _selectedIndex;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          if (i == _selectedIndex) return;
                          
                          setState(() {
                            _selectedIndex = i;
                          });
                          
                          await Future.delayed(const Duration(milliseconds: 340));
                          if (!mounted) return;
                          
                          if (i == 2) {
                            Navigator.popUntil(context, (route) => route.isFirst);
                          } else if (i == 0) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HitungHppPage()),
                            );
                          }
                        },
                        child: SizedBox(
                          height: navHeight,
                          child: Center(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: isActive ? 0.0 : 1.0,
                              child: Icon(
                                navIcons[i],
                                color: const Color(0xFF6B7E72),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InsightBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    paint.color = const Color(0xFF146443).withValues(alpha: 0.35);
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.15), 110, paint);

    paint.color = const Color(0xFF3CAE7A).withValues(alpha: 0.25);
    canvas.drawCircle(Offset(size.width * 0.86, size.height * 0.23), 80, paint);

    paint.color = const Color(0xFF1B4E36).withValues(alpha: 0.2);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.75), 180, paint);

    paint.color = const Color(0xFF2E7D5B).withValues(alpha: 0.15);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.88), 140, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

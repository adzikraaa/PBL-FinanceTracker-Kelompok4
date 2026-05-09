import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/finance_viewmodel.dart';
import '../widgets/custom_input_widget.dart';
import 'hasil_analisis_page.dart';

class HitungBepPage extends StatefulWidget {
  const HitungBepPage({super.key});

  @override
  State<HitungBepPage> createState() => _HitungBepPageState();
}

class _HitungBepPageState extends State<HitungBepPage> {
  // Nav state untuk animasi sliding circle
  int _navIndex = 0;

  final TextEditingController _hargaJualController = TextEditingController();
  final TextEditingController _biayaPerUnitController = TextEditingController();
  final TextEditingController _biayaTetapController = TextEditingController();
  final TextEditingController _jumlahTerjualController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill Biaya Per Unit with modalPerUnit from ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<FinanceViewModel>(context, listen: false);
      _biayaPerUnitController.text = _formatCurrency(vm.modalPerUnit);
      
      if (vm.hargaJualUnit > 0) {
        _hargaJualController.text = _formatCurrency(vm.hargaJualUnit);
      }
      if (vm.biayaTetap > 0) {
        _biayaTetapController.text = _formatCurrency(vm.biayaTetap);
      }
      if (vm.jumlahUnitTerjual != null && vm.jumlahUnitTerjual! > 0) {
        _jumlahTerjualController.text = _formatCurrency(vm.jumlahUnitTerjual!.toDouble());
      }
    });
  }

  String _formatCurrency(double value) {
    if (value <= 0) return '0';
    String result = value.toInt().toString();
    result = result.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return result;
  }

  @override
  void dispose() {
    _hargaJualController.dispose();
    _biayaPerUnitController.dispose();
    _biayaTetapController.dispose();
    _jumlahTerjualController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    final vm = Provider.of<FinanceViewModel>(context, listen: false);
    vm.hargaJualUnit = double.tryParse(_hargaJualController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
    vm.biayaTetap = double.tryParse(_biayaTetapController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
    vm.jumlahUnitTerjual = int.tryParse(_jumlahTerjualController.text.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1B13),
      body: SafeArea(
        child: Stack(
          children: [
            // Background patterns
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1E3A2A).withOpacity(0.5), width: 1),
                ),
              ),
            ),
            Positioned(
              top: 100,
              left: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1E3A2A).withOpacity(0.5), width: 1),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1E3A2A).withOpacity(0.5), width: 1),
                ),
              ),
            ),

            // Main content
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              "BREAK EVEN POINT",
                              style: TextStyle(
                                color: Color(0xFF8BCA6E),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Hitung BEP",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Input your financial figures to determine the\npoint where your total revenue equals your\ntotal expenses.",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        CustomInputWidget(
                          label: "Harga Jual Per Unit",
                          icon: Icons.payments_outlined,
                          tooltipMessage: "Masukkan harga jual produk per satu unit barang anda.",
                          controller: _hargaJualController,
                          onChanged: (_) => _onInputChanged(),
                        ),
                        const SizedBox(height: 20),

                        CustomInputWidget(
                          label: "Biaya Per Unit",
                          icon: Icons.account_balance_wallet_outlined,
                          tooltipMessage: "Biaya produksi untuk satu unit barang (Otomatis dari HPP).",
                          controller: _biayaPerUnitController,
                          readOnly: true,
                        ),
                        const SizedBox(height: 20),

                        CustomInputWidget(
                          label: "Total Biaya Tetap",
                          icon: Icons.analytics_outlined,
                          tooltipMessage: "Total biaya yang tidak berubah terlepas dari jumlah produksi.",
                          controller: _biayaTetapController,
                          onChanged: (_) => _onInputChanged(),
                        ),
                        const SizedBox(height: 20),

                        CustomInputWidget(
                          label: "Jumlah Unit Terjual (Opsional)",
                          icon: Icons.insert_chart_outlined,
                          tooltipMessage: "Masukkan estimasi unit terjual untuk simulasi margin.",
                          controller: _jumlahTerjualController,
                          prefix: "",
                          suffix: "unit",
                          onChanged: (_) => _onInputChanged(),
                        ),

                        const SizedBox(height: 40),

                        // Lihat Hasil Analisis Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF55C772), Color(0xFF8BCA6E)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6CF688).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              _onInputChanged();
                              final vm = Provider.of<FinanceViewModel>(context, listen: false);
                              if (vm.isBepValid()) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HasilAnalisisPage()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Harap isi Harga Jual dan Biaya Tetap (> 0).'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              "Lihat hasil analisis",
                              style: TextStyle(
                                color: Color(0xFF0C1B13),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 100), // Space for bottom nav
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Navigation
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: _buildBottomNav(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    const navIcons = [
      Icons.calculate_outlined,
      Icons.account_balance_wallet_outlined,
      Icons.home,
      Icons.show_chart,
      Icons.history,
    ];
    const int navCount = 5;
    const Color kNavActive = Color(0xFF6CF688);
    const Color kNavBg     = Color(0xFF132018);
    const Color kNavBorder = Color(0xFF2C4334);
    const Color kNavIcon   = Color(0xFF6B7E72);

    return LayoutBuilder(
      builder: (context, constraints) {
        final navWidth = constraints.maxWidth;
        final itemWidth = navWidth / navCount;
        final circleLeft = itemWidth * _navIndex + (itemWidth / 2) - 24;

        return SizedBox(
          height: 64,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Rail (background pill) ──
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: kNavBg.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: kNavBorder, width: 1.5),
                  ),
                ),
              ),
              // ── Sliding green circle ──
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeInOutCubic,
                left: circleLeft,
                top: 8,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: kNavActive,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kNavActive.withOpacity(0.45),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    navIcons[_navIndex],
                    color: const Color(0xFF0C1B13),
                    size: 24,
                  ),
                ),
              ),
              // ── Tappable icon slots ──
              Row(
                children: List.generate(navCount, (i) {
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        if (i == 2) {
                          // Geser lingkaran ke home dulu, baru navigate
                          setState(() => _navIndex = 2);
                          await Future.delayed(Duration.zero);
                          if (!mounted) return;
                          Navigator.popUntil(context, (r) => r.isFirst);
                        }
                      },
                      child: SizedBox(
                        height: 64,
                        child: Center(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: i == _navIndex ? 0.0 : 1.0,
                            child: Icon(
                              navIcons[i],
                              color: kNavIcon,
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
    );
  }
}
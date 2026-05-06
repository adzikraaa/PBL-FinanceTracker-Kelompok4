import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/finance_viewmodel.dart';
import '../widgets/custom_input_widget.dart';
import 'hitung_bep_page.dart';

// ─── Warna navbar sama persis dengan home_view.dart ───────────────────────────
const Color _kNavBg     = Color(0xFF132018);
const Color _kNavBorder = Color(0xFF2C4334);
const Color _kNavIcon   = Color(0xFF6B7E72);
const Color _kNavActive = Color(0xFF6CF688);

class HitungHppPage extends StatefulWidget {
  const HitungHppPage({super.key});

  @override
  State<HitungHppPage> createState() => _HitungHppPageState();
}

class _HitungHppPageState extends State<HitungHppPage> {
  int _navIndex = 0;

  final TextEditingController _biayaProduksiController    = TextEditingController();
  final TextEditingController _biayaTenagaKerjaController = TextEditingController();
  final TextEditingController _biayaOverheadController    = TextEditingController();
  final TextEditingController _jumlahUnitController       = TextEditingController();

  @override
  void dispose() {
    _biayaProduksiController.dispose();
    _biayaTenagaKerjaController.dispose();
    _biayaOverheadController.dispose();
    _jumlahUnitController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    final vm = Provider.of<FinanceViewModel>(context, listen: false);
    vm.biayaProduksi    = double.tryParse(_biayaProduksiController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
    vm.biayaTenagaKerja = double.tryParse(_biayaTenagaKerjaController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
    vm.biayaOverhead    = double.tryParse(_biayaOverheadController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
    vm.jumlahUnit       = int.tryParse(_jumlahUnitController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1B13),
      body: SafeArea(
        bottom: false, // biar navbar bisa turun ke bawah SafeArea
        child: Stack(
          children: [
            // ── Background decorative circles ────────────────────────────
            Positioned(
              top: -50, right: -50,
              child: Container(
                width: 250, height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF1E3A2A).withOpacity(0.5), width: 1),
                ),
              ),
            ),
            Positioned(
              top: 100, left: -100,
              child: Container(
                width: 350, height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF1E3A2A).withOpacity(0.5), width: 1),
                ),
              ),
            ),
            Positioned(
              bottom: -50, right: -50,
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF1E3A2A).withOpacity(0.5), width: 1),
                ),
              ),
            ),

            // ── Main content ─────────────────────────────────────────────
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "HARGA POKOK PRODUKSI",
                          style: TextStyle(
                            color: Color(0xFF8BCA6E),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Hitung HPP",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Input detail biaya produksi untuk menghitung\nHarga Pokok Penjualan secara presisi.",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        CustomInputWidget(
                          label: "Biaya Produksi",
                          icon: Icons.inventory_2,
                          tooltipMessage: "Masukkan total biaya bahan baku untuk produksi.",
                          controller: _biayaProduksiController,
                          onChanged: (_) => _onInputChanged(),
                        ),
                        const SizedBox(height: 20),

                        CustomInputWidget(
                          label: "Upah Tenaga Kerja",
                          icon: Icons.people,
                          tooltipMessage: "Masukkan total upah pekerja produksi.",
                          controller: _biayaTenagaKerjaController,
                          onChanged: (_) => _onInputChanged(),
                        ),
                        const SizedBox(height: 20),

                        CustomInputWidget(
                          label: "Biaya Overhead",
                          icon: Icons.account_balance,
                          tooltipMessage: "Masukkan biaya operasional tambahan (listrik, sewa, dll).",
                          controller: _biayaOverheadController,
                          onChanged: (_) => _onInputChanged(),
                        ),
                        const SizedBox(height: 20),

                        CustomInputWidget(
                          label: "Jumlah Unit Diproduksi",
                          icon: Icons.inventory,
                          tooltipMessage: "Masukkan target jumlah unit yang akan diproduksi.",
                          controller: _jumlahUnitController,
                          prefix: "",
                          suffix: "unit",
                          onChanged: (_) => _onInputChanged(),
                        ),

                        const SizedBox(height: 40),

                        // ── Lanjut Button ──────────────────────────────
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
                              final vm = Provider.of<FinanceViewModel>(
                                  context, listen: false);
                              if (vm.isHppValid()) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const HitungBepPage()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Harap isi semua form. Jumlah unit harus > 0.'),
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
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Lanjut",
                                  style: TextStyle(
                                    color: Color(0xFF0C1B13),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.chevron_right,
                                    color: Color(0xFF0C1B13), size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Bottom Navbar — identik dengan home_view.dart ─────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNav(),
            ),
          ],
        ),
      ),
    );
  }

  // Sama persis dengan _buildBottomNav() di home_view.dart
  Widget _buildBottomNav() {
    const navIcons = [
      Icons.calculate_outlined,
      Icons.account_balance_wallet_outlined,
      Icons.home,
      Icons.show_chart,
      Icons.history,
    ];
    const int navCount = 5;

    return Padding(
      // padding bottom 20 + left/right 20 — sama dengan home_view.dart
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final navWidth   = constraints.maxWidth;
          final itemWidth  = navWidth / navCount;
          final circleLeft = itemWidth * _navIndex + (itemWidth / 2) - 24;

          return SizedBox(
            height: 68, // sama dengan home_view.dart
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Background pill ──────────────────────────────────────
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _kNavBg.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: _kNavBorder, width: 1.5),
                    ),
                  ),
                ),

                // ── Sliding active circle ────────────────────────────────
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOutCubic,
                  left: circleLeft,
                  top: 8, // sama dengan home_view.dart
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _kNavActive,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _kNavActive.withOpacity(0.45),
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

                // ── Tap areas + inactive icons ───────────────────────────
                Row(
                  children: List.generate(navCount, (i) {
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          if (i == 2) {
                            setState(() => _navIndex = 2);
                            await Future.delayed(
                                const Duration(milliseconds: 340));
                            if (!mounted) return;
                            Navigator.pop(context);
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
                                color: _kNavIcon,
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
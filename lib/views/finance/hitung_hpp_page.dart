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

  final TextEditingController _namaProdukController       = TextEditingController();
  final TextEditingController _biayaProduksiController    = TextEditingController();
  final TextEditingController _biayaTenagaKerjaController = TextEditingController();
  final TextEditingController _biayaOverheadController    = TextEditingController();
  final TextEditingController _jumlahUnitController       = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<FinanceViewModel>(context, listen: false);
      if (vm.namaProduk != 'Produk Baru' && vm.namaProduk.isNotEmpty) {
        _namaProdukController.text = vm.namaProduk;
      }
      if (vm.biayaProduksi > 0) {
        _biayaProduksiController.text = _formatCurrency(vm.biayaProduksi);
      }
      if (vm.biayaTenagaKerja > 0) {
        _biayaTenagaKerjaController.text = _formatCurrency(vm.biayaTenagaKerja);
      }
      if (vm.biayaOverhead > 0) {
        _biayaOverheadController.text = _formatCurrency(vm.biayaOverhead);
      }
      if (vm.jumlahUnit > 0) {
        _jumlahUnitController.text = _formatCurrency(vm.jumlahUnit.toDouble());
      }
    });
  }

  String _formatCurrency(double value) {
    String result = value.toInt().toString();
    result = result.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return result;
  }

  @override
  void dispose() {
    _namaProdukController.dispose();
    _biayaProduksiController.dispose();
    _biayaTenagaKerjaController.dispose();
    _biayaOverheadController.dispose();
    _jumlahUnitController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    final vm = Provider.of<FinanceViewModel>(context, listen: false);
    vm.namaProduk       = _namaProdukController.text.trim().isEmpty
        ? 'Produk Baru'
        : _namaProdukController.text.trim();
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
                    color: const Color(0xFF1E3A2A).withValues(alpha: 0.5), width: 1),
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
                    color: const Color(0xFF1E3A2A).withValues(alpha: 0.5), width: 1),
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
                    color: const Color(0xFF1E3A2A).withValues(alpha: 0.5), width: 1),
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
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ── Nama Produk ────────────────────────────────────
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.label_outline,
                                  color: Color(0xFFE2E385),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Nama Produk",
                                  style: TextStyle(
                                    color: Color(0xFFE2E385),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Tooltip(
                                  message: "Masukkan nama produk yang akan dihitung HPP-nya.",
                                  triggerMode: TooltipTriggerMode.tap,
                                  showDuration: const Duration(seconds: 3),
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B2D22).withValues(alpha: 0.95),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFE2E385).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  textStyle: const TextStyle(
                                    color: Color(0xFFE2E385),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  child: const Icon(
                                    Icons.help_outline,
                                    color: Color(0xFF6B7E72),
                                    size: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFF132A1D),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF2C4334).withValues(alpha: 0.5),
                                ),
                              ),
                              child: TextField(
                                controller: _namaProdukController,
                                keyboardType: TextInputType.text,
                                onChanged: (_) => _onInputChanged(),
                                textAlignVertical: TextAlignVertical.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                  hintText: 'Contoh: Nasi Goreng Spesial',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF6B7E72),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

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
                                color: const Color(0xFF6CF688).withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              final vm = Provider.of<FinanceViewModel>(context, listen: false);
                              // Perhitungan HPP berdasarkan input
                              vm.persediaanAwal = double.tryParse(_biayaProduksiController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                              vm.pembelianBersih = double.tryParse(_biayaTenagaKerjaController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                              vm.biayaTenagaKerja = double.tryParse(_biayaTenagaKerjaController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                              vm.biayaOverhead = double.tryParse(_biayaOverheadController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                              vm.jumlahUnit = int.tryParse(_jumlahUnitController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('HPP Tersimpan. Total HPP: Rp ${vm.hitungHPP}'),
                                  backgroundColor: const Color(0xFF2C4334),
                                ),
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const HitungBepPage()),
                              );
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
                      color: _kNavBg.withValues(alpha: 0.95),
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
                          color: _kNavActive.withValues(alpha: 0.45),
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
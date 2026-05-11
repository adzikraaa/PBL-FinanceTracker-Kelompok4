import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/finance_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../widgets/custom_input_widget.dart';
import 'hitung_bep_page.dart';
import 'hasil_analisis_page.dart';

// ─── Warna navbar sama persis dengan home_view.dart ───────────────────────────
const Color _kNavBg     = Color(0xFF132018);
const Color _kNavBorder = Color(0xFF2C4334);
class HitungHppPage extends StatefulWidget {
  const HitungHppPage({super.key});

  @override
  State<HitungHppPage> createState() => _HitungHppPageState();
}

class _HitungHppPageState extends State<HitungHppPage> {
  final TextEditingController _namaProdukController = TextEditingController();
  final TextEditingController _biayaProduksiController = TextEditingController();
  final TextEditingController _biayaTenagaKerjaController = TextEditingController();
  final TextEditingController _biayaOverheadController = TextEditingController();
  final TextEditingController _jumlahUnitController = TextEditingController();
  late FinanceViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = Provider.of<FinanceViewModel>(context, listen: false);
    _vm.addListener(_onViewModelChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_vm.namaProduk != 'Produk Baru' && _vm.namaProduk.isNotEmpty) {
        _namaProdukController.text = _vm.namaProduk;
      }
      if (_vm.biayaProduksi > 0) {
        _biayaProduksiController.text = _formatCurrency(_vm.biayaProduksi);
      }
      if (_vm.biayaTenagaKerja > 0) {
        _biayaTenagaKerjaController.text = _formatCurrency(_vm.biayaTenagaKerja);
      }
      if (_vm.biayaOverhead > 0) {
        _biayaOverheadController.text = _formatCurrency(_vm.biayaOverhead);
      }
      if (_vm.jumlahUnit > 0) {
        _jumlahUnitController.text = _formatCurrency(_vm.jumlahUnit.toDouble());
      }
    });
  }

  void _onViewModelChanged() {
    if (!mounted) return;
    // Kosongkan input saat data di-reset setelah simpan
    if (_vm.namaProduk == 'Produk Baru' && _vm.biayaProduksi == 0 &&
        _vm.jumlahUnit == 0 && _vm.currentStep == 0) {
      if (_namaProdukController.text.isNotEmpty &&
          _namaProdukController.text != 'Produk Baru') {
        _namaProdukController.clear();
      }
      if (_biayaProduksiController.text.isNotEmpty) _biayaProduksiController.clear();
      if (_biayaTenagaKerjaController.text.isNotEmpty) _biayaTenagaKerjaController.clear();
      if (_biayaOverheadController.text.isNotEmpty) _biayaOverheadController.clear();
      if (_jumlahUnitController.text.isNotEmpty) _jumlahUnitController.clear();
    }
  }




  String _formatCurrency(double value) {
    String result = value.toInt().toString();
    result = result.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return result;
  }

  @override
  void dispose() {
    _vm.removeListener(_onViewModelChanged);
    _namaProdukController.dispose();
    _biayaProduksiController.dispose();
    _biayaTenagaKerjaController.dispose();
    _biayaOverheadController.dispose();
    _jumlahUnitController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    final vm = Provider.of<FinanceViewModel>(context, listen: false);
    vm.namaProduk = _namaProdukController.text.trim().isEmpty ? 'Produk Baru' : _namaProdukController.text.trim();
    vm.biayaProduksi = double.tryParse(_biayaProduksiController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
    vm.biayaTenagaKerja = double.tryParse(_biayaTenagaKerjaController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
    vm.biayaOverhead = double.tryParse(_biayaOverheadController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
    vm.jumlahUnit = int.tryParse(_jumlahUnitController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FinanceViewModel>();

    // Deteksi lastSaveSuccess di sini (lebih reliable dari listener)
    if (vm.lastSaveSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final homeVm = Provider.of<HomeViewModel>(context, listen: false);
        homeVm.onNavTapManual(4); // Pindah ke Riwayat
        vm.resetData();           // Reset form + step + flag
      });
    }

    return SafeArea(
      child: _buildCurrentStep(vm),
    );
  }

  Widget _buildCurrentStep(FinanceViewModel vm) {
    switch (vm.currentStep) {
      case 1:
        return const HitungBepPage();
      case 2:
        return const HasilAnalisisPage();
      default:
        return _buildHppView(vm);
    }
  }

  Widget _buildHppView(FinanceViewModel vm) {
    return Stack(
      children: [
        // Background circles
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

        // Content
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

                    // Nama Produk
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.label_outline, color: Color(0xFFE2E385), size: 16),
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
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF132A1D),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2C4334).withOpacity(0.5)),
                          ),
                          child: TextField(
                            controller: _namaProdukController,
                            onChanged: (_) => _onInputChanged(),
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16),
                              hintText: 'Contoh: Nasi Goreng Spesial',
                              hintStyle: TextStyle(color: Color(0xFF6B7E72), fontSize: 14),
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

                    // Lanjut Button
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
                          if (vm.biayaProduksi > 0 && vm.jumlahUnit > 0) {
                            vm.setStep(1);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Harap isi Biaya Produksi dan Jumlah Unit!'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Lanjut", style: TextStyle(color: Color(0xFF0C1B13), fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.chevron_right, color: Color(0xFF0C1B13), size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

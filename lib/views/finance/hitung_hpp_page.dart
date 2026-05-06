import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/finance_viewmodel.dart';

class HitungHppPage extends StatefulWidget {
  const HitungHppPage({super.key});

  @override
  State<HitungHppPage> createState() => _HitungHppPageState();
}

class _HitungHppPageState extends State<HitungHppPage> {
  // Controllers
  final TextEditingController _persediaanAwalController = TextEditingController(text: "0");
  final TextEditingController _pembelianBersihController = TextEditingController(text: "0");
  final TextEditingController _biayaTenagaKerjaController = TextEditingController(text: "0");
  final TextEditingController _biayaOverheadController = TextEditingController(text: "0");
  final TextEditingController _persediaanAkhirController = TextEditingController(text: "0");
  final TextEditingController _jumlahUnitController = TextEditingController(text: "0");

  @override
  void dispose() {
    _persediaanAwalController.dispose();
    _pembelianBersihController.dispose();
    _biayaTenagaKerjaController.dispose();
    _biayaOverheadController.dispose();
    _persediaanAkhirController.dispose();
    _jumlahUnitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1B13),
      body: SafeArea(
        child: Stack(
          children: [
            // Background patterns (Simplified with circles)
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
              top: -100,
              right: -100,
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
              left: -50,
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
                        const Text(
                          "Hitung HPP",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Input detail biaya produksi untuk menghitung\nHarga Pokok Penjualan secara presisi.",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        _buildCard(
                          title: "PERSEDIAAN & PEMBELIAN",
                          icon: Icons.inventory_2_outlined,
                          children: [
                            _buildInputRow("Persediaan Awal", "Rp", _persediaanAwalController),
                            const Divider(color: Color(0xFF2C4334), height: 32, thickness: 1),
                            _buildInputRow("Pembelian Bersih", "Rp", _pembelianBersihController),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        _buildCard(
                          title: "BIAYA PRODUKSI",
                          icon: Icons.factory_outlined,
                          children: [
                            _buildInputRow("Biaya Tenaga Kerja", "Rp", _biayaTenagaKerjaController),
                            const Divider(color: Color(0xFF2C4334), height: 32, thickness: 1),
                            _buildInputRow("Biaya Overhead", "Rp", _biayaOverheadController),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        _buildCard(
                          title: "AUDIT & VOLUME",
                          icon: Icons.analytics_outlined,
                          children: [
                            _buildInputRow("Persediaan Akhir", "Rp", _persediaanAkhirController),
                            const Divider(color: Color(0xFF2C4334), height: 32, thickness: 1),
                            _buildInputRow("Jumlah Unit Diproduksi", "qty", _jumlahUnitController),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Lanjut Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              final vm = Provider.of<FinanceViewModel>(context, listen: false);
                              vm.persediaanAwal = double.tryParse(_persediaanAwalController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                              vm.pembelianBersih = double.tryParse(_pembelianBersihController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                              vm.biayaTenagaKerja = double.tryParse(_biayaTenagaKerjaController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                              vm.biayaOverhead = double.tryParse(_biayaOverheadController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                              vm.persediaanAkhir = double.tryParse(_persediaanAkhirController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                              vm.jumlahUnit = int.tryParse(_jumlahUnitController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                              vm.simpanPerhitungan('anon');
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('HPP Tersimpan. Total HPP: Rp ${vm.hitungHPP}'),
                                  backgroundColor: const Color(0xFF2C4334),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6CF688),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Lanjut",
                                  style: TextStyle(
                                    color: Color(0xFF003D1A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xFF003D1A),
                                  size: 16,
                                ),
                              ],
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

  Widget _buildCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2D22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C4334)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF8BCA6E), size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF8BCA6E),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputRow(String label, String prefix, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFA1AFA6),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                prefix,
                style: const TextStyle(
                  color: Color(0xFF6B7E72),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
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
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF132018),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF2C4334), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.calculate_outlined, false),
          _buildNavItem(Icons.account_balance_wallet_outlined, false),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF263C2A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.home, color: Color(0xFF8BCA6E)),
          ),
          _buildNavItem(Icons.insert_chart_outlined, false),
          _buildNavItem(Icons.history, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isSelected) {
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? const Color(0xFF8BCA6E) : const Color(0xFF6B7E72),
      ),
      onPressed: () {},
    );
  }
}

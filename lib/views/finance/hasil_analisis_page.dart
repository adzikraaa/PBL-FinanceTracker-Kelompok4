import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/finance_viewmodel.dart';
import '../home/home_view.dart'; // Navigate back to home on save
import '../notes/note_form_view.dart';

class HasilAnalisisPage extends StatefulWidget {
  const HasilAnalisisPage({super.key});

  @override
  State<HasilAnalisisPage> createState() => _HasilAnalisisPageState();
}

class _HasilAnalisisPageState extends State<HasilAnalisisPage> {
  double _sliderValue = 25000; // Default simulasi

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<FinanceViewModel>(context, listen: false);
      if (vm.hargaJualUnit > 0) {
        setState(() {
          _sliderValue = vm.hargaJualUnit;
        });
      }
    });
  }

  String _formatCurrency(double value) {
    String result = value.toInt().toString();
    result = result.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FinanceViewModel>();

    return Stack(
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
                          onTap: () => vm.setStep(1),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Hasil Analisis",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              vm.namaProduk,
                              style: const TextStyle(
                                color: Color(0xFF8BCA6E),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Card 1: HPP Unit & Total
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2D22),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2C4334)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "HPP UNIT & TOTAL",
                            style: TextStyle(
                              color: Color(0xFF8BCA6E),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Rp ${_formatCurrency(vm.modalPerUnit)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 6, left: 4),
                                child: Text(
                                  "/unit",
                                  style: TextStyle(
                                    color: Color(0xFF6B7E72),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: Color(0xFF2C4334)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total HPP",
                                style: TextStyle(
                                  color: Color(0xFFA1AFA6),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "Rp ${_formatCurrency(vm.hitungHPP)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Cards 2 & 3: Margin & Harga Jual
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B2D22),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF2C4334)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "MARGIN / UNIT",
                                  style: TextStyle(
                                    color: Color(0xFF8BCA6E),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Rp ${_formatCurrency(vm.marginPerUnit)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF263C2A),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${vm.marginPercentage.toStringAsFixed(0)}% MARGIN %",
                                    style: const TextStyle(
                                      color: Color(0xFF8BCA6E),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B2D22),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF2C4334)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "HARGA JUAL",
                                  style: TextStyle(
                                    color: Color(0xFF8BCA6E),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Rp ${_formatCurrency(vm.hargaJualUnit)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Card 4: Analisis BEP
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2D22),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2C4334)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ANALISIS BEP",
                            style: TextStyle(
                              color: Color(0xFF8BCA6E),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "BEP (UNIT)",
                                      style: TextStyle(
                                        color: Color(0xFFA1AFA6),
                                        fontSize: 10,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${_formatCurrency(vm.hitungBEPUnit)} Unit",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "BEP (OMZET)",
                                      style: TextStyle(
                                        color: Color(0xFFA1AFA6),
                                        fontSize: 10,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Rp ${_formatCurrency(vm.hitungBEPRupiah)}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Card 5: Simulasi Harga Jual
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2D22),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2C4334)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Simulasi Harga Jual",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2E385).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Rp ${_formatCurrency(_sliderValue)}",
                                  style: const TextStyle(
                                    color: Color(0xFFE2E385),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            "HARGA JUAL TARGET",
                            style: TextStyle(
                              color: Color(0xFF6B7E72),
                              fontSize: 10,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Builder(
                            builder: (context) {
                              double minVal = vm.modalPerUnit > 0 ? vm.modalPerUnit : 0;
                              double maxVal = vm.modalPerUnit > 0 ? vm.modalPerUnit * 3 : 100000;
                              if (maxVal == minVal) {
                                  maxVal = minVal + 100000;
                              }
                              double safeValue = _sliderValue.clamp(minVal, maxVal);

                              return SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: const Color(0xFFE2E385),
                                  inactiveTrackColor: const Color(0xFF2C4334),
                                  thumbColor: const Color(0xFFE2E385),
                                  overlayColor: const Color(0xFFE2E385).withOpacity(0.2),
                                  trackHeight: 4,
                                ),
                                child: Slider(
                                  value: safeValue,
                                  min: minVal,
                                  max: maxVal,
                                  onChanged: (value) {
                                    setState(() {
                                      _sliderValue = value;
                                      vm.hargaJualUnit = value; 
                                    });
                                  },
                                ),
                              );
                            }
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("MINIMAL", style: TextStyle(color: Color(0xFF6B7E72), fontSize: 10)),
                                Text("MAKSIMAL", style: TextStyle(color: Color(0xFF6B7E72), fontSize: 10)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: vm.marginPercentage < 0
                                    ? const Color(0xFFE57373)
                                    : vm.marginPercentage < 20
                                        ? const Color(0xFFE2E385)
                                        : const Color(0xFF2C4334),
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              vm.marginPercentage < 0
                                  ? "RUGI"
                                  : vm.marginPercentage < 20
                                      ? "KEUNTUNGAN RENDAH"
                                      : vm.marginPercentage > 50
                                          ? "KEUNTUNGAN TINGGI"
                                          : "KEUNTUNGAN SEDANG",
                              style: TextStyle(
                                color: vm.marginPercentage < 0
                                    ? const Color(0xFFE57373)
                                    : vm.marginPercentage < 20
                                        ? const Color(0xFFE2E385)
                                        : const Color(0xFF8BCA6E),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Buttons
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NoteFormView()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2C4334)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.note_add_outlined, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "TAMBAH CATATAN",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
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
                        onPressed: () async {
                          final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                          await vm.simpanPerhitungan(userId);
                          vm.setStep(0);
                          final homeVm = Provider.of<HomeViewModel>(context, listen: false);
                          homeVm.onNavTapManual(2); // Back to home
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          "Simpan",
                          style: TextStyle(
                            color: Color(0xFF0C1B13),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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

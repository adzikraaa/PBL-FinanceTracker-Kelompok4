import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../viewmodels/saving_viewmodel.dart';
import '../../data/models/saving_model.dart';
import 'saving_form_page.dart';
import 'saving_detail_page.dart';
import 'dart:math' as math;

// ─── Sparkle Model ────────────────────────────────────────────────────────────
class _Sparkle {
  double x, y, size, opacity, phase, speed;
  _Sparkle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.phase,
    required this.speed,
  });
}

class SavingListPage extends StatefulWidget {
  final String userId;
  const SavingListPage({super.key, required this.userId});

  @override
  State<SavingListPage> createState() => _SavingListPageState();
}

class _SavingListPageState extends State<SavingListPage> with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late List<_Sparkle> _sparkles;
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _sparkles = List.generate(
      12,
      (_) => _Sparkle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble() * 0.28,
        size: _rng.nextDouble() * 8 + 4,
        opacity: _rng.nextDouble() * 0.7 + 0.3,
        phase: _rng.nextDouble() * 2 * math.pi,
        speed: _rng.nextDouble() * 1.5 + 0.5,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavingViewModel>().listenSavings(widget.userId);
    });
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2818),
      body: Stack(
        children: [
          // Background Gradient
          _buildGradientBg(),
          
          // Sparkle Layer
          _buildSparkleLayer(),

          Consumer<SavingViewModel>(
            builder: (context, vm, _) {
              return SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: vm.savings.isEmpty
                          ? _buildEmptyState()
                          : ListView(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 160),
                              children: [
                                // Header / Total Tabungan inside ListView for better scrolling
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 24, 8, 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: const Text(
                                          'TABUNGAN SAYA',
                                          style: TextStyle(
                                            color: Color(0xFFFFD700),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'TOTAL TABUNGAN',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Rp ${_formatRupiah(vm.totalSavings)}',
                                        style: const TextStyle(
                                          color: Color(0xFFFFD700),
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // List Items
                                ...vm.savings.map((saving) => _buildSavingCard(context, vm, saving)).toList(),
                              ],
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Floating Action Button moved up
          Positioned(
            right: 20,
            bottom: 140, // Di atas navbar
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF4AFF91),
              onPressed: () {
                context.read<SavingViewModel>().resetForm();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SavingFormPage(userId: widget.userId),
                  ),
                );
              },
              child: const Icon(Icons.add, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.savings_outlined, color: Colors.white10, size: 100),
          const SizedBox(height: 16),
          const Text(
            'Belum ada tabungan',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Klik tombol + untuk menambah',
            style: TextStyle(color: Colors.white24, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingCard(BuildContext context, SavingViewModel vm, SavingModel saving) {
    double progress = vm.getProgress(saving);
    bool isCompleted = progress >= 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isCompleted 
                  ? const Color(0xFF4AFF91).withOpacity(0.3) 
                  : Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SavingDetailPage(saving: saving, userId: widget.userId),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Image/Placeholder
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF163520),
                            borderRadius: BorderRadius.circular(16),
                            image: saving.imageUrl != null
                                ? DecorationImage(
                                    image: (vm.getCachedImage(saving.imageUrl!) as ImageProvider?) ?? const AssetImage('assets/images/logo.png'),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: saving.imageUrl == null
                              ? const Icon(Icons.savings, color: Colors.white24, size: 30)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        // Title & Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                saving.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isCompleted ? 'Goal Tercapai!' : 'Sisa Rp ${_formatRupiah(saving.targetAmount - saving.currentAmount)}',
                                style: TextStyle(
                                  color: isCompleted ? const Color(0xFF4AFF91) : Colors.white54,
                                  fontSize: 13,
                                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Percentage Circle
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 4,
                                backgroundColor: Colors.white10,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isCompleted ? const Color(0xFF4AFF91) : const Color(0xFFFFD700),
                                ),
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Progress & Quick Add
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TERKUMPUL',
                              style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Rp ${_formatRupiah(saving.currentAmount)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (!isCompleted)
                          _buildQuickAddButton(context, vm, saving)
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4AFF91).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF4AFF91).withOpacity(0.3), width: 1),
                            ),
                            child: const Text(
                              'DONE',
                              style: TextStyle(
                                color: Color(0xFF4AFF91),
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatRupiah(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
  }

  ImageProvider _getImageProvider(String url) {
    if (url.startsWith('data:image')) {
      final base64String = url.split(',').last;
      return MemoryImage(base64Decode(base64String));
    }
    return NetworkImage(url);
  }

  Widget _buildQuickAddButton(BuildContext context, SavingViewModel vm, SavingModel saving) {
    return GestureDetector(
      onTap: () => _showQuickUpdateSheet(context, vm, saving),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF22C55E), Color(0xFF4ADE80)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22C55E).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_outline, color: Color(0xFF0D2818), size: 16),
            SizedBox(width: 6),
            Text(
              'TABUNG',
              style: TextStyle(
                color: Color(0xFF0D2818),
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickUpdateSheet(BuildContext context, SavingViewModel vm, SavingModel saving) {
    final TextEditingController amountController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final double currentInput = double.tryParse(amountController.text.replaceAll('.', '')) ?? 0;
            final bool isLimitReached = (saving.currentAmount + currentInput) >= 1000000000;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D2818).withOpacity(0.95),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border.all(color: Colors.white10, width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Tambah Tabungan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Berapa banyak yang ingin kamu tabung hari ini?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        ThousandSeparatorFormatterWithLimit(currentAmount: saving.currentAmount),
                      ],
                      onChanged: (val) {
                        setSheetState(() {});
                      },
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: 'Masukkan nominal...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                        prefixText: 'Rp ',
                        prefixStyle: const TextStyle(color: Color(0xFF4ADE80), fontWeight: FontWeight.bold),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF4ADE80), width: 1.5),
                        ),
                      ),
                    ),
                    if (isLimitReached)
                      const Padding(
                        padding: EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                          'Batas maksimal total tabungan 1 Miliar',
                          style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPresetButton(amountController, '10rb', 10000, setSheetState),
                        _buildPresetButton(amountController, '50rb', 50000, setSheetState),
                        _buildPresetButton(amountController, '100rb', 100000, setSheetState),
                        _buildPresetButton(amountController, '500rb', 500000, setSheetState),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          final double? val = double.tryParse(amountController.text.replaceAll('.', ''));
                          if (val != null && val > 0) {
                            // Limit 1 Milyar
                            if (saving.currentAmount + val > 1000000000) {
                              setSheetState(() {});
                              return;
                            }

                            Navigator.pop(context);
                            final success = await vm.quickUpdateAmount(saving.id!, saving.currentAmount, val);
                            if (context.mounted && success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Berhasil menabung Rp ${_formatRupiah(val)}!'),
                                  backgroundColor: const Color(0xFF163520),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            }
                          } else {
                            // Validasi jika kosong
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Nominal tidak boleh kosong!'),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4ADE80),
                          foregroundColor: const Color(0xFF0D2818),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'SIMPAN TABUNGAN',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildPresetButton(TextEditingController controller, String label, double value, StateSetter setSheetState) {
    return GestureDetector(
      onTap: () {
        controller.text = _formatRupiah(value);
        setSheetState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10, width: 1),
        ),
        child: Text(
          '+$label',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildGradientBg() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A1F12),
            Color(0xFF0D2818),
            Color(0xFF0F2E1A),
          ],
        ),
      ),
    );
  }

  Widget _buildSparkleLayer() {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _SparklePainter(
                sparkles: _sparkles,
                time: _sparkleController.value,
              ),
            );
          },
        );
      },
    );
  }
}

class ThousandSeparatorFormatterWithLimit extends TextInputFormatter {
  final double currentAmount;
  ThousandSeparatorFormatterWithLimit({required this.currentAmount});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String cleanText = newValue.text.replaceAll('.', '');
    
    // Limit 1 Miliar total
    final double? val = double.tryParse(cleanText);
    if (val != null && (currentAmount + val) > 1000000000) {
      // Jika melebihi limit, kembalikan nilai lama
      return oldValue;
    }

    final String formatted = cleanText.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final List<_Sparkle> sparkles;
  final double time;

  _SparklePainter({required this.sparkles, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4AFF91).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (var s in sparkles) {
      final t = time;
      final move = math.sin(t * 2 * math.pi * s.speed + s.phase) * 15;
      final opacity = s.opacity * (0.5 + 0.5 * math.sin(t * 2 * math.pi + s.phase));
      
      final currentPaint = Paint()
        ..color = const Color(0xFF4AFF91).withOpacity(opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      final center = Offset(size.width * s.x, (size.height * s.y + move) % size.height);
      
      final path = Path();
      path.moveTo(center.dx, center.dy - s.size / 2);
      path.lineTo(center.dx + s.size / 4, center.dy);
      path.lineTo(center.dx, center.dy + s.size / 2);
      path.lineTo(center.dx - s.size / 4, center.dy);
      path.close();
      
      canvas.drawPath(path, currentPaint);
    }
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) => true;
}

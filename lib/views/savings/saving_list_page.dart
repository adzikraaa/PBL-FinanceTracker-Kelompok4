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
  int _localNavIndex = 1; // Tabungan

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _sparkles = List.generate(
      15,
      (_) => _Sparkle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: _rng.nextDouble() * 10 + 4,
        opacity: _rng.nextDouble() * 0.5 + 0.2,
        phase: _rng.nextDouble() * 2 * math.pi,
        speed: _rng.nextDouble() * 1.2 + 0.4,
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2818),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'TABUNGAN SAYA',
          style: TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Animation
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _sparkleController,
              builder: (context, _) {
                return Stack(
                  children: _sparkles.map((s) {
                    final t = _sparkleController.value;
                    final move = math.sin(t * 2 * math.pi * s.speed + s.phase) * 20;
                    return Positioned(
                      left: MediaQuery.of(context).size.width * s.x,
                      top: MediaQuery.of(context).size.height * s.y + move,
                      child: Opacity(
                        opacity: s.opacity * (0.5 + 0.5 * math.sin(t * 2 * math.pi + s.phase)),
                        child: Icon(
                          Icons.auto_awesome,
                          color: const Color(0xFF4AFF91).withOpacity(0.3),
                          size: s.size,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          Consumer<SavingViewModel>(
            builder: (context, vm, _) {
              return SafeArea(
                child: vm.savings.isEmpty && vm.totalSavings == 0
                    ? _buildEmptyState()
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                        children: [
                          // Header Card (Total Tabungan)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 16, 8, 24),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.12),
                                    Colors.white.withOpacity(0.02),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(color: Colors.white10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4AFF91).withOpacity(0.05),
                                    blurRadius: 30,
                                    spreadRadius: -10,
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4AFF91).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.account_balance_wallet, color: Color(0xFF4AFF91), size: 16),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'TOTAL TABUNGAN',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      const Text(
                                        'Rp ',
                                        style: TextStyle(
                                          color: Color(0xFF4AFF91),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Text(
                                        _formatRupiah(vm.totalSavings),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 36,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // List of Savings
                          ...vm.savings.map((saving) => _buildSavingCard(context, vm, saving)),
                        ],
                      ),
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNav(),
          ),
          Positioned(
            right: 20,
            bottom: 100, // Di atas navbar (68 + 20)
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
    return const Center(
      child: Text(
        'Tabungan masih kosong nih.\nAyo menabung :)',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }

  Widget _buildSavingCard(
      BuildContext context, SavingViewModel vm, SavingModel saving) {
    double progress = vm.getProgress(saving);
    double sisa = saving.targetAmount - saving.currentAmount;
    final bool isCompleted = progress >= 1.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SavingDetailPage(
              saving: saving,
              userId: widget.userId,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isCompleted 
                      ? const Color(0xFF4AFF91).withOpacity(0.4) 
                      : Colors.white.withOpacity(0.08),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white10, width: 1),
                          image: saving.imageUrl != null
                              ? DecorationImage(
                                  image: _getImageProvider(saving.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: saving.imageUrl == null
                            ? Icon(Icons.savings_outlined,
                                color: isCompleted ? const Color(0xFF4AFF91) : Colors.white38, 
                                size: 32)
                            : null,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              saving.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                decorationColor: Colors.white54,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.flag_rounded,
                                  size: 14,
                                  color: isCompleted ? const Color(0xFF4AFF91) : const Color(0xFFFFD700),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Target: Rp ${_formatRupiah(saving.targetAmount)}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              color: isCompleted ? const Color(0xFF4AFF91) : const Color(0xFFFFD700),
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Stack(
                    children: [
                      Container(
                        height: 10,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.elasticOut,
                        height: 10,
                        width: (MediaQuery.of(context).size.width - 80) * progress,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isCompleted
                                ? [const Color(0xFF22C55E), const Color(0xFF4ADE80)]
                                : [const Color(0xFFF59E0B), const Color(0xFFFFD700)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: (isCompleted ? const Color(0xFF4ADE80) : const Color(0xFFFFD700)).withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TERKUMPUL',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rp ${_formatRupiah(saving.currentAmount)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      if (!isCompleted)
                        _buildQuickAddButton(context, vm, saving)
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4AFF91).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF4AFF91).withOpacity(0.4), width: 1.5),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, color: Color(0xFF4AFF91), size: 14),
                              SizedBox(width: 6),
                              Text(
                                'GOAL MET',
                                style: TextStyle(
                                  color: Color(0xFF4AFF91),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
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
                        fillColor: Colors.white.withOpacity(0.08),
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
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10, width: 1),
        ),
        child: Text(
          '+${_formatRupiah(value).replaceAll('.0', '')}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
  Widget _buildBottomNav() {
    const Color kNavBg = Color(0xFF132018);
    const Color kNavBorder = Color(0xFF2C4334);
    const Color kNavIcon = Color(0xFF6B7E72);
    const Color kNavActive = Color(0xFF6CF688);

    const navIcons = [
      Icons.calculate_outlined,
      Icons.account_balance_wallet_outlined,
      Icons.home,
      Icons.show_chart,
      Icons.history,
    ];
    // Gunakan _localNavIndex agar animasi berjalan mulus
    final int activeIndex = _localNavIndex;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / 5;
          final circleLeft = itemWidth * activeIndex + (itemWidth / 2) - 24;

          return SizedBox(
            height: 68,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: kNavBg.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: kNavBorder, width: 1.5),
                    ),
                  ),
                ),
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
                      navIcons[activeIndex],
                      color: const Color(0xFF0C1B13),
                      size: 24,
                    ),
                  ),
                ),
                Row(
                  children: List.generate(5, (i) {
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          if (i == _localNavIndex) return;
                          
                          // Update index lokal agar lingkaran bergerak halus
                          setState(() => _localNavIndex = i);
                          
                          // Tunggu animasi lingkaran selesai
                          await Future.delayed(const Duration(milliseconds: 320));
                          if (!mounted) return;

                          // Pop ke Home dengan result index tujuan
                          Navigator.pop(context, i);
                        },
                        child: SizedBox(
                          height: 64,
                          child: Center(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: i == activeIndex ? 0.0 : 1.0,
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
      ),
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
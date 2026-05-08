import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../viewmodels/saving_viewmodel.dart';
import '../../data/models/saving_model.dart';
import 'saving_form_page.dart';
import 'saving_detail_page.dart';

class SavingListPage extends StatefulWidget {
  final String userId;
  const SavingListPage({super.key, required this.userId});

  @override
  State<SavingListPage> createState() => _SavingListPageState();
}

class _SavingListPageState extends State<SavingListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavingViewModel>().listenSavings(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<SavingViewModel>(
        builder: (context, vm, _) {
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                Expanded(
                  child: vm.savings.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: vm.savings.length,
                          itemBuilder: (context, index) {
                            return _buildSavingCard(
                                context, vm, vm.savings[index]);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
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
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isCompleted 
                    ? const Color(0xFF4AFF91).withOpacity(0.3) 
                    : Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Thumbnail Gambar dengan desain lebih cantik
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
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
                              size: 30)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            saving.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              decorationColor: Colors.white54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.ads_click,
                                size: 12,
                                color: isCompleted ? const Color(0xFF4AFF91) : const Color(0xFFFFD700),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Target: Rp ${_formatRupiah(saving.targetAmount)}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Persentase yang lebih menonjol
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            color: isCompleted ? const Color(0xFF4AFF91) : const Color(0xFFFFD700),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Progress Bar lebih modern
                Stack(
                  children: [
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      height: 8,
                      width: (MediaQuery.of(context).size.width - 72) * progress,
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
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TERKUMPUL',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
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
        controller.text = value.toInt().toString();
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
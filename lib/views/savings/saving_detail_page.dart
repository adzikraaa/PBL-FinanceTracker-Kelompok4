import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../data/models/saving_model.dart';
import '../../viewmodels/saving_viewmodel.dart';
import 'saving_form_page.dart';

class SavingDetailPage extends StatelessWidget {
  final SavingModel saving;
  final String userId;
  const SavingDetailPage(
      {super.key, required this.saving, required this.userId});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<SavingViewModel>();
    double progress = vm.getProgress(saving);
    double sisa = saving.targetAmount - saving.currentAmount;

    return Scaffold(
      backgroundColor: const Color(0xFF0D2818),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2818),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
        ),
        title: const Text('Kembali',
            style: TextStyle(color: Color(0xFFFFD700))),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar utama atau placeholder
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF163520),
                borderRadius: BorderRadius.circular(16),
                image: saving.imageUrl != null
                    ? DecorationImage(
                        image: _getImageProvider(saving.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: saving.imageUrl == null
                  ? const Icon(Icons.savings, color: Colors.white24, size: 80)
                  : null,
            ),
            const SizedBox(height: 16),

            const Text('SAVINGS GOAL',
                style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 12,
                    letterSpacing: 1.2)),
            const SizedBox(height: 4),
            Text(saving.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Progress card
            _buildCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('PROGRESS',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 11)),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                          const Text('Complete',
                              style:
                                  TextStyle(color: Colors.white70)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('REMAINING',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 11)),
                          Text(
                            'Rp ${_formatRupiah(sisa)}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white12,
                      color: const Color(0xFFFFD700),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Monthly Goal card
            _buildCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('MONTHLY GOAL',
                          style: TextStyle(
                              color: Colors.white54, fontSize: 11)),
                      Text(
                        'Rp ${_formatRupiah(vm.getMonthlyGoal(saving))}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D2818),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.trending_up,
                        color: Color(0xFF4AFF91)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Expected Completion card
            _buildCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('EXPECTED COMPLETION',
                          style: TextStyle(
                              color: Colors.white54, fontSize: 11)),
                      Text(
                        vm.getExpectedCompletion(saving),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D2818),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_today,
                        color: Colors.white54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Edit
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4AFF91),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.edit, color: Colors.black),
                label: const Text('Edit Goal',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SavingFormPage(
                        userId: userId,
                        existingSaving: saving,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Tombol Hapus
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF163520),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Delete Goal',
                    style: TextStyle(color: Colors.white)),
                onPressed: () => _showDeleteDialog(context, vm),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, SavingViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF3A1A1A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Colors.red, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Konfirmasi Hapus',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Apakah anda yakin\ningin menghapus tabungan ini?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4AFF91),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tidak',
                      style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A2A2A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    final success = await vm.deleteSaving(saving.id!);
                    if (!context.mounted) return;

                    if (success) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Color(0xFF4AFF91)),
                              SizedBox(width: 12),
                              Text('Tabungan berhasil dihapus',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          backgroundColor: Color(0xFF163520),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text(
                                      vm.errorMessage ?? 'Gagal menghapus data',
                                      style: const TextStyle(
                                          color: Colors.white))),
                            ],
                          ),
                          backgroundColor: const Color(0xFF163520),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Text('Iya',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF163520),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
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
}
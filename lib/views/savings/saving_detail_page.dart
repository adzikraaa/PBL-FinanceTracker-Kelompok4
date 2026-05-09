import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:math' as math;
import '../../data/models/saving_model.dart';
import '../../viewmodels/saving_viewmodel.dart';
import '../../main.dart';
import 'saving_form_page.dart';

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

class SavingDetailPage extends StatefulWidget {
  final SavingModel saving;
  final String userId;
  const SavingDetailPage(
      {super.key, required this.saving, required this.userId});

  @override
  State<SavingDetailPage> createState() => _SavingDetailPageState();
}

class _SavingDetailPageState extends State<SavingDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late List<_Sparkle> _sparkles;
  final math.Random _rng = math.Random();

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
        opacity: _rng.nextDouble() * 0.4 + 0.1,
        phase: _rng.nextDouble() * 2 * math.pi,
        speed: _rng.nextDouble() * 1.0 + 0.5,
      ),
    );
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SavingViewModel>();

    // Cari data terbaru dari list di ViewModel berdasarkan ID
    final currentSaving = vm.savings.firstWhere(
      (s) => s.id == widget.saving.id,
      orElse: () => widget.saving,
    );

    double progress = vm.getProgress(currentSaving);
    double sisa = currentSaving.targetAmount - currentSaving.currentAmount;

    return Scaffold(
      backgroundColor: const Color(0xFF0D2818),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2818),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
        ),
        title:
            const Text('Kembali', style: TextStyle(color: Color(0xFFFFD700))),
        elevation: 0,
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
                    final move =
                        math.sin(t * 2 * math.pi * s.speed + s.phase) * 20;
                    return Positioned(
                      left: MediaQuery.of(context).size.width * s.x,
                      top: MediaQuery.of(context).size.height * s.y + move,
                      child: Opacity(
                        opacity: s.opacity *
                            (0.5 + 0.5 * math.sin(t * 2 * math.pi + s.phase)),
                        child: Icon(
                          Icons.auto_awesome,
                          color: const Color(0xFF4AFF91).withOpacity(0.2),
                          size: s.size,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar utama atau placeholder
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: double.infinity,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white10),
                        image: currentSaving.imageUrl != null
                            ? DecorationImage(
                                image: _getImageProvider(
                                    vm, currentSaving.imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: currentSaving.imageUrl == null
                          ? const Icon(Icons.savings_outlined,
                              color: Colors.white24, size: 80)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text('SAVINGS GOAL',
                    style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 12,
                        letterSpacing: 1.2)),
                const SizedBox(height: 4),
                Text(currentSaving.title,
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
                                  style: TextStyle(color: Colors.white70)),
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
                            'Rp ${_formatRupiah(vm.getMonthlyGoal(currentSaving))}',
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
                            vm.getExpectedCompletion(currentSaving),
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
                      backgroundColor: progress >= 1.0
                          ? Colors.white10
                          : const Color(0xFF4AFF91),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: Icon(
                      progress >= 1.0 ? Icons.check_circle : Icons.edit,
                      color: progress >= 1.0 ? Colors.white38 : Colors.black,
                    ),
                    label: Text(
                      progress >= 1.0 ? 'Goal Tercapai' : 'Edit Goal',
                      style: TextStyle(
                        color: progress >= 1.0 ? Colors.white38 : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: progress >= 1.0
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SavingFormPage(
                                  userId: widget.userId,
                                  existingSaving: currentSaving,
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
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, SavingViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    final success = await vm.deleteSaving(widget.saving.id!);
                    if (context.mounted && success) {
                      final messenger = MyApp.scaffoldMessengerKey.currentState;
                      messenger?.hideCurrentSnackBar();
                      messenger?.showSnackBar(
                        const SnackBar(
                          content: Text('Data tabungan berhasil dihapus'),
                          backgroundColor: Color(0xFF163520),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.pop(context);
                    } else if (context.mounted) {
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
                  child:
                      const Text('Iya', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
          ),
          child: child,
        ),
      ),
    );
  }

  String _formatRupiah(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
  }

  ImageProvider _getImageProvider(SavingViewModel vm, String url) {
    if (url.startsWith('data:image') && vm.cachedImageData != null) {
      return MemoryImage(vm.cachedImageData!);
    }
    if (url.startsWith('data:image')) {
      final base64String = url.split(',').last;
      return MemoryImage(base64Decode(base64String));
    }
    return NetworkImage(url);
  }
}

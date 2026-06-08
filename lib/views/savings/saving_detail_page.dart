import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../data/models/saving_model.dart';
import '../../viewmodels/saving_viewmodel.dart';
import 'saving_form_page.dart';
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

class SavingDetailPage extends StatefulWidget {
  final SavingModel saving;
  final String userId;
  const SavingDetailPage(
      {super.key, required this.saving, required this.userId});

  @override
  State<SavingDetailPage> createState() => _SavingDetailPageState();
}

class _SavingDetailPageState extends State<SavingDetailPage> with TickerProviderStateMixin {
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
      15,
      (_) => _Sparkle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: _rng.nextDouble() * 8 + 4,
        opacity: _rng.nextDouble() * 0.4 + 0.1,
        phase: _rng.nextDouble() * 2 * math.pi,
        speed: _rng.nextDouble() * 1.5 + 0.5,
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFD700)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('DETAIL TABUNGAN',
            style: TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildGradientBg(),
          _buildSparkleLayer(),
          SafeArea(
            child: SingleChildScrollView(
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
                image: currentSaving.imageUrl != null
                    ? DecorationImage(
                        image: (vm.getCachedImage(currentSaving.imageUrl!) as ImageProvider?) ?? const AssetImage('assets/images/logo.png'),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: currentSaving.imageUrl == null
                  ? const Icon(Icons.savings, color: Colors.white24, size: 80)
                  : null,
            ),
            const SizedBox(height: 16),

            const Text('TARGET TABUNGAN',
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
                          const Text('Selesai',
                              style:
                                  TextStyle(color: Colors.white70)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('SISA',
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
                      const Text('TARGET BULANAN',
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
                      const Text('ESTIMASI SELESAI',
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
                  progress >= 1.0 ? 'Target Tercapai' : 'Edit Target',
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
                label: const Text('Hapus Target',
                    style: TextStyle(color: Colors.white)),
                onPressed: () => _showDeleteDialog(context, vm),
              ),
            ),
                ],
              ),
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
                    final success = await vm.deleteSaving(widget.saving.id!);
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

class _SparklePainter extends CustomPainter {
  final List<_Sparkle> sparkles;
  final double time;

  _SparklePainter({required this.sparkles, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (var s in sparkles) {
      final t = time;
      final move = math.sin(t * 2 * math.pi * s.speed + s.phase) * 20;
      final opacity = s.opacity * (0.5 + 0.5 * math.sin(t * 2 * math.pi + s.phase));
      
      final paint = Paint()
        ..color = const Color(0xFF4AFF91).withOpacity(opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      final center = Offset(size.width * s.x, (size.height * s.y + move) % size.height);
      
      final path = Path();
      path.moveTo(center.dx, center.dy - s.size / 2);
      path.lineTo(center.dx + s.size / 4, center.dy);
      path.lineTo(center.dx, center.dy + s.size / 2);
      path.lineTo(center.dx - s.size / 4, center.dy);
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) => true;
}

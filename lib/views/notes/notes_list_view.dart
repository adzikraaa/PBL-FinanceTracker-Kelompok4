import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/riwayat_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../data/models/hpp_model.dart';
import 'note_form_view.dart';

class NotesListView extends StatefulWidget {
  const NotesListView({super.key});

  @override
  State<NotesListView> createState() => _NotesListViewState();
}

class _NotesListViewState extends State<NotesListView>
    with TickerProviderStateMixin {

  late AnimationController _floatController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late Animation<double> _floatAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _glowAnim = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final riwayatVm = context.watch<RiwayatViewModel>();
    final notes = riwayatVm.historyWithCatatan;

    return Scaffold(
      backgroundColor: const Color(0xFF081E13),
      body: Stack(
        children: [
          // Background Painter
          Positioned.fill(
            child: CustomPaint(painter: _NotesBackgroundPainter()),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back,
                                color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Notes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Manage your financial strategies and vault\ncalculations.',
                        style: TextStyle(
                          color: Color(0xFF8BCA6E),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: notes.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, bottom: 80),
                          physics: const BouncingScrollPhysics(),
                          itemCount: notes.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B3324),
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: const Color(0xFF2C4334)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          note.namaProduk,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => NoteFormView(
                                                  noteId: note.id),
                                            ),
                                          );
                                        },
                                        child: const Icon(Icons.edit,
                                            color: Color(0xFF6B7E72),
                                            size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      GestureDetector(
                                        onTap: () {
                                          if (note.id != null) {
                                            _showDeleteConfirmation(
                                                context, note.id!);
                                          }
                                        },
                                        child: const Icon(
                                            Icons.delete_outline,
                                            color: Color(0xFF6B7E72),
                                            size: 20),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    note.catatan,
                                    style: const TextStyle(
                                      color: Color(0xFFA1AFA6),
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Floating Action Button
          Positioned(
            right: 24,
            bottom: 24,
            child: GestureDetector(
              onTap: () {
                context.read<HomeViewModel>().onNavTapManual(0); // Pindah ke tab Hitung HPP BEP
                Navigator.popUntil(context, (route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Silakan hitung HPP & BEP terlebih dahulu untuk membuat catatan.'),
                    backgroundColor: Color(0xFF1B3324),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF6CF688),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6CF688).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Color(0xFF0C1B13), size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Floating animated icon with glow
            AnimatedBuilder(
              animation: Listenable.merge(
                  [_floatController, _glowController, _particleController]),
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Particle dots orbiting
                    ...List.generate(6, (i) {
                      final angle = (i / 6) * 2 * pi +
                          _particleController.value * 2 * pi;
                      final radius = 68.0;
                      final dx = cos(angle) * radius;
                      final dy = sin(angle) * radius;
                      final opacity = (sin(
                                  _particleController.value * 2 * pi +
                                      (i * pi / 3)) +
                              1) /
                          2;
                      return Transform.translate(
                        offset: Offset(dx, dy),
                        child: Opacity(
                          opacity: opacity * 0.7,
                          child: Container(
                            width: i % 2 == 0 ? 5 : 3,
                            height: i % 2 == 0 ? 5 : 3,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6CF688),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6CF688)
                                      .withOpacity(0.8),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    // Outer glow ring
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6CF688)
                                .withOpacity(_glowAnim.value * 0.25),
                            blurRadius: 40,
                            spreadRadius: 12,
                          ),
                        ],
                      ),
                    ),
                    // Main icon container with float
                    Transform.translate(
                      offset: Offset(0, _floatAnim.value),
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF2B5C40),
                              const Color(0xFF1B3324),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFF6CF688)
                                .withOpacity(_glowAnim.value * 0.6),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6CF688)
                                  .withOpacity(_glowAnim.value * 0.15),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.sticky_note_2_outlined,
                          color: Color(0xFF6CF688),
                          size: 42,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 36),
            // Dashed border container with text
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF132018).withOpacity(0.6),
                border: Border.all(
                  color: const Color(0xFF2C4334),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Decorative lines mimicking a notebook
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 24,
                          height: 2,
                          color: const Color(0xFF6CF688).withOpacity(0.4)),
                      const SizedBox(width: 8),
                      Container(
                          width: 8,
                          height: 2,
                          color: const Color(0xFF6CF688).withOpacity(0.2)),
                      const SizedBox(width: 8),
                      Container(
                          width: 16,
                          height: 2,
                          color: const Color(0xFF6CF688).withOpacity(0.4)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum Ada Catatan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Halaman ini masih kosong.\nMulai tulis strategi keuanganmu\ndi sini! ✨',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF8BCA6E),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 16,
                          height: 2,
                          color: const Color(0xFF6CF688).withOpacity(0.2)),
                      const SizedBox(width: 8),
                      Container(
                          width: 24,
                          height: 2,
                          color: const Color(0xFF6CF688).withOpacity(0.4)),
                      const SizedBox(width: 8),
                      Container(
                          width: 8,
                          height: 2,
                          color: const Color(0xFF6CF688).withOpacity(0.2)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Hint tap to add
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.touch_app_rounded,
                  color: Color(0xFF4A7A5A),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Ketuk tombol + untuk memulai',
                  style: TextStyle(
                    color: const Color(0xFF4A7A5A),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  void _showDeleteConfirmation(BuildContext context, String noteId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B3324),
        title:
            const Text('Hapus Catatan?', style: TextStyle(color: Colors.white)),
        content: const Text('Catatan ini akan dihapus secara permanen.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Batal', style: TextStyle(color: Color(0xFF8BCA6E))),
          ),
          TextButton(
            onPressed: () {
              context.read<RiwayatViewModel>().updateCatatan(noteId, '');
              Navigator.pop(ctx);
            },
            child:
                const Text('Hapus', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _NotesBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    paint.color = const Color(0xFF146443).withOpacity(0.35);
    canvas.drawCircle(
        Offset(size.width * 0.18, size.height * 0.15), 110, paint);

    paint.color = const Color(0xFF3CAE7A).withOpacity(0.25);
    canvas.drawCircle(Offset(size.width * 0.86, size.height * 0.23), 80, paint);

    paint.color = const Color(0xFF1B4E36).withOpacity(0.2);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.75), 180, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

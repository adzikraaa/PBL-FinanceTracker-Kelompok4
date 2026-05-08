import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/note_viewmodel.dart';
import 'note_form_view.dart';

class NotesListView extends StatefulWidget {
  const NotesListView({super.key});

  @override
  State<NotesListView> createState() => _NotesListViewState();
}

class _NotesListViewState extends State<NotesListView> {
  // Use same index as Home for the center home icon
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    final noteVm = context.watch<NoteViewModel>();
    final notes = noteVm.notes;

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
                  child: ListView.separated(
                    padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        bottom: 120), // Extra padding for FAB & Bottom Nav
                    physics: const BouncingScrollPhysics(),
                    itemCount: notes.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(
                              0xFF1B3324), // matching card color in screenshot
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF2C4334)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    note.title,
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
                                        builder: (_) =>
                                            NoteFormView(noteId: note.id),
                                      ),
                                    );
                                  },
                                  child: const Icon(Icons.edit,
                                      color: Color(0xFF6B7E72), size: 20),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () {
                                    _showDeleteConfirmation(context, note.id);
                                  },
                                  child: const Icon(Icons.delete_outline,
                                      color: Color(0xFF6B7E72), size: 20),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              note.excerpt,
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
            bottom: 100, // Above bottom nav
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NoteFormView()),
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
                child:
                    const Icon(Icons.add, color: Color(0xFF0C1B13), size: 28),
              ),
            ),
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
    );
  }

  Widget _buildBottomNav() {
    const navIcons = [
      Icons.calculate_outlined, // 0 - HPP & BEP
      Icons.account_balance_wallet_outlined, // 1 - Wallet
      Icons.home, // 2 - Home
      Icons.show_chart, // 3 - Chart (Insight)
      Icons.history, // 4 - History
    ];
    const int navCount = 5;
    const double navHeight = 68.0;
    const double circleSize = 48.0;
    const double circleTop = (navHeight - circleSize) / 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final navWidth = constraints.maxWidth;
        final itemWidth = navWidth / navCount;
        final circleLeft =
            itemWidth * _selectedIndex + (itemWidth / 2) - circleSize / 2;

        return SizedBox(
          height: navHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF132018).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(34),
                    border:
                        Border.all(color: const Color(0xFF2C4334), width: 1.5),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeInOutCubic,
                left: circleLeft,
                top: circleTop,
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6CF688),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6CF688).withOpacity(0.45),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    navIcons[_selectedIndex],
                    color: const Color(0xFF0C1B13),
                    size: 24,
                  ),
                ),
              ),
              Row(
                children: List.generate(navCount, (i) {
                  final isActive = i == _selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        if (i == _selectedIndex) return;

                        // We act as if going back to home or other root pages
                        if (i == 2) {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        } else {
                          // other nav items not implemented here since it's a sub-page,
                          // but can mimic InsightView's logic.
                          Navigator.popUntil(context, (route) => route.isFirst);
                          // For a complete flow, we'd use a main layout with a persistent bottom nav.
                        }
                      },
                      child: SizedBox(
                        height: navHeight,
                        child: Center(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isActive ? 0.0 : 1.0,
                            child: Icon(
                              navIcons[i],
                              color: const Color(0xFF6B7E72),
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
              context.read<NoteViewModel>().deleteNote(noteId);
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

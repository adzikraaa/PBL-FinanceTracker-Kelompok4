import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/riwayat_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../data/models/hpp_model.dart';

class NoteFormView extends StatefulWidget {
  final String? noteId; // ID dari riwayat HPP yang ingin diedit catatannya

  const NoteFormView({super.key, this.noteId});

  @override
  State<NoteFormView> createState() => _NoteFormViewState();
}

class _NoteFormViewState extends State<NoteFormView> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  int _selectedIndex = 2; // Home active by default in the bottom bar like others

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();

    if (widget.noteId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final riwayatVm = context.read<RiwayatViewModel>();
        final hppItem = riwayatVm.history.firstWhere(
          (n) => n.id == widget.noteId,
          orElse: () => HppModel(
            id: '',
            userId: '',
            namaProduk: '',
            persediaanAwal: 0,
            pembelianBersih: 0,
            persediaanAkhir: 0,
            biayaProduksi: 0,
            biayaTenagaKerja: 0,
            biayaOverhead: 0,
            jumlahUnit: 0,
            biayaTetap: 0,
            hargaJualUnit: 0,
            totalHpp: 0,
            bepUnit: 0,
            bepRupiah: 0,
            catatan: '',
            createdAt: DateTime.now(),
          ),
        );
        if (hppItem.id != null && hppItem.id!.isNotEmpty) {
          setState(() {
            _titleController.text = hppItem.namaProduk;
            _contentController.text = hppItem.catatan;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final riwayatVm = context.read<RiwayatViewModel>();
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi catatan tidak boleh kosong.')),
      );
      return;
    }

    if (widget.noteId != null) {
      riwayatVm.updateCatatan(widget.noteId!, content);
    }
    Navigator.pop(context); // Kembali setelah menyimpan
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.noteId != null;

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
              children: [
                // Header (App Bar Custom)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        isEditing ? 'Edit Catatan' : 'Tambah Catatan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _saveNote,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFBE488), // Yellowish button
                          foregroundColor: const Color(0xFF0C1B13),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Note Heading
                        const Text(
                          'NOTE HEADING',
                          style: TextStyle(
                            color: Color(0xFF8BCA6E),
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B3324),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFF2C4334)),
                          ),
                          child: TextField(
                            controller: _titleController,
                            readOnly: true,
                            style: const TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Nama Produk',
                              hintStyle: TextStyle(color: Colors.white30, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Detailed Insights
                        const Text(
                          'DETAIL INSIGHT',
                          style: TextStyle(
                            color: Color(0xFF8BCA6E),
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B3324),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFF2C4334)),
                          ),
                          child: TextField(
                            controller: _contentController,
                            maxLines: 10,
                            minLines: 8,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              height: 1.6,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Tulis rincian catatan di sini...',
                              hintStyle: TextStyle(color: Colors.white30, fontSize: 15),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        if (isEditing) ...[
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                               context.read<RiwayatViewModel>().updateCatatan(widget.noteId!, '');
                               Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFB04B4B)), // Muted red border
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              minimumSize: const Size(double.infinity, 56),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.delete_outline, color: Color(0xFFFF6B6B), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Hapus Catatan',
                                  style: TextStyle(
                                    color: Color(0xFFFF6B6B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 120), // Bottom padding for nav
                      ],
                    ),
                  ),
                ),
              ],
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
                    border: Border.all(color: const Color(0xFF2C4334), width: 1.5),
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
                        final homeVm = Provider.of<HomeViewModel>(context, listen: false);
                        homeVm.onNavTapManual(i);
                        Navigator.popUntil(context, (route) => route.isFirst);
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
}

class _NotesBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    paint.color = const Color(0xFF146443).withOpacity(0.35);
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.15), 110, paint);

    paint.color = const Color(0xFF3CAE7A).withOpacity(0.25);
    canvas.drawCircle(Offset(size.width * 0.86, size.height * 0.23), 80, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/riwayat_viewmodel.dart';
import '../../data/models/hpp_model.dart';
import '../../data/services/pdf_service.dart';
import '../finance/hitung_hpp_page.dart';

import '../../viewmodels/premium_viewmodel.dart';

String _fmtTime(DateTime d) => DateFormat('HH:mm', 'id_ID').format(d);
String _fmtDateFull(DateTime d) => DateFormat('dd MMM yyyy', 'id_ID').format(d);

// ─── Colors ──────────────────────────────────────────────────────────────────
const Color _kBg       = Color(0xFF0B2114);
const Color _kGlow     = Color(0xFF1E472A);
const Color _kCard     = Color(0xFFFFFFFF);
const Color _kGreen    = Color(0xFF4ADE80);
const Color _kDarkGreen= Color(0xFF163520);
const Color _kWhite    = Color(0xFFFFFFFF);
const Color _kWhite70  = Color(0xB3FFFFFF);
const Color _kWhite40  = Color(0x66FFFFFF);
const Color _kGreyText = Color(0xFF6B7280);
const Color _kLightGreenBtn = Color(0xFFA2E874);

class RiwayatView extends StatefulWidget {
  const RiwayatView({super.key});

  @override
  State<RiwayatView> createState() => _RiwayatViewState();
}

class _RiwayatViewState extends State<RiwayatView> with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _sparkleCtrl;
  int _localNavIndex = 4; // Riwayat

  final _currencyFmt = NumberFormat.currency(
    locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _sparkleCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _sparkleCtrl.dispose();
    super.dispose();
  }

  void _showDeleteDialog(BuildContext ctx, RiwayatViewModel vm, HppModel item) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF163520),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Riwayat',
            style: TextStyle(color: _kWhite, fontWeight: FontWeight.bold)),
        content: Text(
          'Hapus riwayat "${item.namaProduk}"?',
          style: const TextStyle(color: _kWhite70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: _kWhite40)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await vm.deleteHistory(item.id!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: _kWhite,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
  
  Map<String, List<HppModel>> _groupHistoryByDate(List<HppModel> history) {
    Map<String, List<HppModel>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var item in history) {
      final date = DateTime(item.createdAt.year, item.createdAt.month, item.createdAt.day);
      String key;
      if (date == today) {
        key = 'HARI INI';
      } else if (date == yesterday) {
        key = 'KEMARIN';
      } else {
        key = DateFormat('dd MMM yyyy', 'id_ID').format(date).toUpperCase();
      }

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<PremiumViewModel>().isPremium;
    return Consumer<RiwayatViewModel>(
      builder: (context, vm, _) {
        final groupedHistory = _groupHistoryByDate(vm.history);
        final groupKeys = groupedHistory.keys.toList();

        return Scaffold(
          backgroundColor: _kBg,
          body: Stack(
            children: [
              _buildBgGlow(),
              _buildSparkles(),
              SafeArea(
                bottom: false,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      _buildHeader(context),
                      if (vm.isLoading)
                        const Expanded(
                          child: Center(
                              child: CircularProgressIndicator(color: _kGreen)),
                        )
                      else if (vm.history.isEmpty)
                        _buildEmptyState()
                      else
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                            physics: const BouncingScrollPhysics(),
                            children: [
                              ...groupKeys.map((key) {
                                final items = groupedHistory[key]!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildDateHeader(key),
                                    ...items.map((item) => _buildRiwayatCard(item, vm, context, isPremium)),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Background ────────────────────────────────────────────────────────────
  Widget _buildBgGlow() => Positioned(
    top: -100,
    left: 0,
    right: 0,
    child: Container(
      height: 400,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.5),
          radius: 1.0,
          colors: [
            _kGlow.withValues(alpha: 0.5),
            _kBg.withValues(alpha: 0.0),
          ],
        ),
      ),
    ),
  );

  Widget _buildSparkles() => AnimatedBuilder(
        animation: _sparkleCtrl,
        builder: (_, __) => CustomPaint(
          size: Size.infinite,
          painter: _SparklesPainter(t: _sparkleCtrl.value),
        ),
      );


  // ─── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          const Text(
            'Riwayat Kalkulasi',
            style: TextStyle(
              color: _kWhite,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Date Group Header ─────────────────────────────────────────────────────
  Widget _buildDateHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.white24,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Riwayat Card ──────────────────────────────────────────────────────────
  Widget _buildRiwayatCard(HppModel item, RiwayatViewModel vm, BuildContext ctx, bool isPremium) {
    final hppPerUnit = item.jumlahUnit > 0 ? item.totalHpp / item.jumlahUnit : 0.0;
    final margin = item.hargaJualUnit - hppPerUnit;
    final marginPct = item.hargaJualUnit > 0 ? (margin / item.hargaJualUnit * 100) : 0.0;
    
    // Logic for circular color and badges
    Color marginColor;
    if (marginPct >= 50) {
      marginColor = const Color(0xFF4A154B); // Dark purple
    } else if (marginPct >= 30) {
      marginColor = const Color(0xFFC53030); // Dark red
    } else {
      marginColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Top section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.namaProduk,
                    style: const TextStyle(
                      color: _kDarkGreen,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                // Circular percentage indicator
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: marginColor, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      '${marginPct.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: marginColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Grid stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatGridItem('HPP', _currencyFmt.format(hppPerUnit)),
                      const SizedBox(height: 16),
                      _buildStatGridItem('BEP UNIT', '${item.bepUnit.toStringAsFixed(0)} unit'),
                      const SizedBox(height: 8),
                      // Badge 1
                      if (item.bepUnit > 100)
                        _buildBadge(Icons.warning_amber_rounded, 'BEP Tinggi', const Color(0xFFFFE4E6), const Color(0xFFE11D48))
                      else if (marginPct >= 50)
                        _buildBadge(Icons.star, 'Paling Menguntungkan', const Color(0xFFF3E8FF), const Color(0xFF6B21A8))
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatGridItem('HARGA JUAL', _currencyFmt.format(item.hargaJualUnit)),
                      const SizedBox(height: 16),
                      _buildStatGridItem('PROFIT MARGIN', '${marginPct.toStringAsFixed(0)}%', valueColor: marginColor),
                      const SizedBox(height: 8),
                      // Badge 2
                      if (item.bepUnit <= 100 && marginPct >= 40)
                        _buildBadge(Icons.flash_on, 'Laku Cepat', const Color(0xFFF3F4F6), const Color(0xFF4B5563))
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Divider
          Container(
            height: 1,
            color: Colors.grey.withValues(alpha: 0.1),
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          
          // Bottom row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: _kGreyText.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${_fmtDateFull(item.createdAt)}, ${_fmtTime(item.createdAt)}',
                          style: TextStyle(color: _kGreyText.withValues(alpha: 0.8), fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    final premiumVm = context.read<PremiumViewModel>();
                    bool allowNoWatermark = false;

                    if (premiumVm.isPremium) {
                      allowNoWatermark = true;
                    } else if (premiumVm.canUsePdfTrial) {
                      allowNoWatermark = true;
                      await premiumVm.incrementPdfTrial();
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text('Menggunakan trial PDF tanpa watermark (${premiumVm.pdfTrialUsed}/${PremiumViewModel.maxPdfTrial})'),
                            backgroundColor: Colors.orange,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    } else {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('Trial habis. Menampilkan watermark. Upgrade Premium untuk menghilangkan watermark.'),
                            backgroundColor: Colors.grey,
                            duration: Duration(seconds: 4),
                          ),
                        );
                      }
                    }

                    await PdfService.downloadHpp(item, isPremium: allowNoWatermark);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6), // Light grey
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.download_outlined, size: 14, color: _kDarkGreen),
                        const SizedBox(width: 4),
                        const Text(
                          'PDF',
                          style: TextStyle(
                            color: _kDarkGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    _showLihatCatatan(ctx, vm, item);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: _kLightGreenBtn,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.description_outlined, size: 14, color: _kDarkGreen),
                        const SizedBox(width: 4),
                        const Text(
                          'Catatan',
                          style: TextStyle(
                            color: _kDarkGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGridItem(String label, String value, {Color valueColor = _kDarkGreen}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _kGreyText,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
  
  Widget _buildBadge(IconData icon, String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showLihatCatatan(BuildContext ctx, RiwayatViewModel vm, HppModel item) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        bool isEditing = item.catatan.trim().isEmpty;
        final TextEditingController noteController =
            TextEditingController(text: item.catatan);

        return StatefulBuilder(
          builder: (context, setStateSheet) {
            final currentNote = item.catatan;
            final isEmpty = currentNote.trim().isEmpty;

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 36,
                top: 16,
                left: 24,
                right: 24,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF132A1D),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // Header
                  Row(
                    children: [
                      const Icon(Icons.description_outlined,
                          color: Color(0xFF8BCA6E), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Catatan Perhitungan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              item.namaProduk,
                              style: const TextStyle(
                                color: Color(0xFF8BCA6E),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isEditing && !isEmpty)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: Color(0xFF8BCA6E)),
                          onPressed: () {
                            setStateSheet(() {
                              isEditing = true;
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Content
                  if (isEditing)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: noteController,
                          maxLines: 4,
                          maxLength: 200,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Tulis catatan perhitungan di sini...',
                            hintStyle: const TextStyle(color: Colors.white30),
                            fillColor: const Color(0xFF1B3324),
                            filled: true,
                            counterStyle: const TextStyle(color: Colors.white54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFF2C4334)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFF8BCA6E)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            if (!isEmpty) // Only show cancel if there was a note already
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setStateSheet(() {
                                        isEditing = false;
                                        noteController.text = item.catatan;
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.white38),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text('Batal'),
                                  ),
                                ),
                              ),
                            if (!isEmpty) const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final newNote = noteController.text.trim();
                                    await vm.updateCatatan(item.id!, newNote);
                                    // Update the local item object so it updates visually immediately
                                    item.catatan = newNote;
                                    setStateSheet(() {
                                      isEditing = false;
                                    });
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        const SnackBar(
                                          content: Text('Catatan berhasil disimpan!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8BCA6E),
                                    foregroundColor: const Color(0xFF0C1B13),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Simpan',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  else if (isEmpty)
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B3324),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF2C4334)),
                          ),
                          child: Column(
                            children: const [
                              Icon(Icons.notes_outlined,
                                  color: Colors.white38, size: 40),
                              SizedBox(height: 12),
                              Text(
                                'Tidak ada catatan',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Kamu belum menambahkan catatan untuk perhitungan ini.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                    height: 1.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              setStateSheet(() {
                                isEditing = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8BCA6E),
                              foregroundColor: const Color(0xFF0C1B13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Tambah Catatan',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.4,
                          ),
                          child: SingleChildScrollView(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B3324),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF2C4334)),
                              ),
                              child: Text(
                                currentNote,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.7,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8BCA6E),
                              foregroundColor: const Color(0xFF0C1B13),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Tutup',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── Empty State ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF1E472A).withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(Icons.receipt_long_outlined,
                  color: Colors.white54, size: 44),
            ),
            const SizedBox(height: 20),
            const Text('Belum Ada Riwayat',
                style: TextStyle(
                    color: _kWhite, fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Riwayat akan muncul setelah kamu menghitung HPP & BEP.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HitungHppPage(showBackButton: true)),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: _kLightGreenBtn,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.calculate_outlined, color: _kDarkGreen, size: 18),
                  SizedBox(width: 8),
                  Text('Mulai Hitung',
                      style: TextStyle(
                          color: _kDarkGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

}



// ── Sparkles Painter ─────────────────────────────────────────────────────────
class _SparklesPainter extends CustomPainter {
  final double t;
  static final _rng = Random(99);
  static final _sp = List.generate(
      16,
      (_) => [
            _rng.nextDouble(),
            _rng.nextDouble() * 0.6,
            _rng.nextDouble() * 5 + 2,
            _rng.nextDouble() * 2 * pi,
            _rng.nextDouble() * 1.5 + 0.5,
          ]);

  _SparklesPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in _sp) {
      final pulse = (sin(t * 2 * pi * s[4] + s[3]) + 1) / 2;
      final opacity = (0.45 * pulse).clamp(0.0, 1.0);
      if (opacity < 0.05) continue;
      final paint = Paint()
        ..color = const Color(0xFF4ADE80).withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      final cx = s[0] * size.width;
      final cy = s[1] * size.height;
      final r = s[2] * (0.7 + 0.3 * pulse);
      final path = Path();
      for (int i = 0; i < 8; i++) {
        final a = i * pi / 4 - pi / 2;
        final rad = i.isEven ? r : r * 0.35;
        final x = cx + cos(a) * rad;
        final y = cy + sin(a) * rad;
        i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SparklesPainter old) => old.t != t;
}

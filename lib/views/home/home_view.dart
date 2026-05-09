import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/note_viewmodel.dart';
import '../../viewmodels/riwayat_viewmodel.dart';
import '../../viewmodels/saving_viewmodel.dart';
import '../finance/hitung_hpp_page.dart';
import '../insight/insight_view.dart';
import '../riwayat/riwayat_view.dart';
import '../notes/notes_list_view.dart';
import 'profile_view.dart';
import '../savings/saving_list_page.dart';

// ─── Color Palette (Dark Green Theme) ────────────────────────────────────────
const Color kBg = Color(0xFF0D2818);
const Color kBgMid = Color(0xFF122A1C);
const Color kCard = Color(0xFF163520);
const Color kCardLight = Color(0xFF1E4A2C);
const Color kGreen = Color(0xFF4ADE80);
const Color kGreenLime = Color(0xFF86EFAC);
const Color kGreenBtn = Color(0xFF22C55E);
const Color kRiwayat = Color(0xFF9CD76A);
const Color kWhite = Color(0xFFFFFFFF);
const Color kWhite70 = Color(0xB3FFFFFF);
const Color kWhite40 = Color(0x66FFFFFF);
const Color kWhite20 = Color(0x33FFFFFF);
const Color kCatatan = Color(0xFF163520);
const Color kNavBg = Color(0xFF132018);
const Color kNavBorder = Color(0xFF2C4334);
const Color kNavIcon = Color(0xFF6B7E72);
const Color kNavActive = Color(0xFF6CF688);

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

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late HomeViewModel _vm;

  late AnimationController _sparkleController;
  late AnimationController _progressAnimController;
  late Animation<double> _progressAnim;
  late List<_Sparkle> _sparkles;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();

    _vm = context.read<HomeViewModel>();
    // Pastikan saat buka Home, navbar aktif di index 2 (Home)
    _vm.selectedIndex = 2;

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _progressAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnim = Tween<double>(begin: 0, end: _vm.tabunganProgress).animate(
      CurvedAnimation(parent: _progressAnimController, curve: Curves.easeOut),
    );
    _progressAnimController.forward();

    _sparkles = List.generate(
        12,
        (_) => _Sparkle(
              x: _rng.nextDouble(),
              y: _rng.nextDouble() * 0.28,
              size: _rng.nextDouble() * 8 + 4,
              opacity: _rng.nextDouble() * 0.7 + 0.3,
              phase: _rng.nextDouble() * 2 * pi,
              speed: _rng.nextDouble() * 1.5 + 0.5,
            ));
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _progressAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: kBg,
          body: Stack(
            children: [
              _buildGradientBg(),
              _buildSparkleLayer(),
              SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGreetingSection(),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildRiwayatCard(),
                            const SizedBox(height: 14),
                            _buildTabunganCard(),
                            const SizedBox(height: 14),
                            _buildHppBepCard(),
                            const SizedBox(height: 14),
                            _buildBottomRow(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomNav(),
              ),
            ],
          ),
        );
      },
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

  Widget _buildGreetingSection() {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    final displayName = user?.displayName ?? _vm.userName;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting text ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, $displayName!',
                  style: const TextStyle(
                    color: kWhite,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Mulai hitung HPP & BEP untuk produk\nbisnismu sekarang.',
                  style: TextStyle(
                    color: kWhite70,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // ── Profile avatar button ──
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileView()),
              );
            },
            child: Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF22C55E), Color(0xFF4ADE80)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kGreen.withOpacity(0.4),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(
                      color: kGreen.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: photoUrl != null
                      ? ClipOval(
                          child: Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: Color(0xFF0D2818),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Color(0xFF0D2818),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                // online dot
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: kGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: kBg, width: 2),
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

  Widget _buildRiwayatCard() {
    final riwayatVm = context.watch<RiwayatViewModel>();
    final latest = riwayatVm.latest;
    final currFmt = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    void goToRiwayat() async {
      _vm.onNavTapManual(4);
      await Future.delayed(const Duration(milliseconds: 320));
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RiwayatView()),
      );
      if (mounted) _vm.onNavTapManual(2);
    }

    return GestureDetector(
      onTap: goToRiwayat,
      child: Container(
        decoration: BoxDecoration(
          color: kRiwayat,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFB8E88A), width: 0.8),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'RIWAYAT',
                  style: TextStyle(
                    color: Color(0xFF1E3D0F),
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (riwayatVm.history.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3D0F).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${riwayatVm.history.length} data',
                      style: const TextStyle(
                          color: Color(0xFF1E3D0F),
                          fontSize: 10,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (riwayatVm.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(
                      color: Color(0xFF1E3D0F), strokeWidth: 2),
                ),
              )
            else if (latest == null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        color: Color(0xFF5A9A30), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Belum ada riwayat perhitungan',
                      style: TextStyle(
                          color: Color(0xFF1A3A10),
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3D0F).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: Color(0xFF1E3D0F),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            latest.namaProduk,
                            style: const TextStyle(
                              color: Color(0xFF1A3A10),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'HPP/unit: ${currFmt.format(latest.jumlahUnit > 0 ? latest.totalHpp / latest.jumlahUnit : 0)}',
                            style: const TextStyle(
                                color: Color(0xFF5A9A30), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      currFmt.format(latest.hargaJualUnit),
                      style: const TextStyle(
                        color: Color(0xFF1A3A10),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: goToRiwayat,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF5A9A30), width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  foregroundColor: const Color(0xFF1E3D0F),
                ),
                child: const Text(
                  'LIHAT SEMUA RIWAYAT',
                  style: TextStyle(
                    color: Color(0xFF1E3D0F),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabunganCard() {
    return Consumer<SavingViewModel>(
      builder: (context, savingVm, child) {
        final bool hasData = savingVm.savings.isNotEmpty;

        if (!hasData) {
          return GestureDetector(
            onTap: () async {
              _vm.onNavTapManual(1);
              await Future.delayed(const Duration(milliseconds: 320));
              if (!mounted) return;
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SavingListPage(userId: FirebaseAuth.instance.currentUser?.uid ?? '')),
              );
              if (mounted) _vm.onNavTapManual(2);
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: kWhite20, width: 0.8),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: kWhite.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: kGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BELUM ADA TABUNGAN',
                          style: TextStyle(
                            color: kWhite40,
                            fontSize: 10,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Yuk, mulai menabung!',
                          style: TextStyle(
                            color: kWhite,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF22C55E), Color(0xFF4ADE80)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'TAMBAH',
                      style: TextStyle(
                        color: Color(0xFF0D2818),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Ambil data terbaru (pertama di list)
        final latestSaving = savingVm.savings.first;

        final String nama = latestSaving.title;
        final double current = latestSaving.currentAmount;
        final double target = latestSaving.targetAmount;
        final double progress = (current / target).clamp(0.0, 1.0);

        return GestureDetector(
          onTap: () async {
            _vm.onNavTapManual(1);
            await Future.delayed(const Duration(milliseconds: 320));
            if (!mounted) return;
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SavingListPage(userId: FirebaseAuth.instance.currentUser?.uid ?? '')),
            );
            if (mounted) _vm.onNavTapManual(2);
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kCard,
                  kCard.withOpacity(0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kWhite.withOpacity(0.08), width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TABUNGAN TERBARU',
                      style: TextStyle(
                        color: kWhite40,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      nama,
                      style: const TextStyle(
                        color: kWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Progress Circle
                        SizedBox(
                          width: 68,
                          height: 68,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 64, // Sedikit lebih kecil agar tidak kepotong
                                height: 64,
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 5,
                                  backgroundColor: kWhite20,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(kGreen),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: const TextStyle(
                                  color: kWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Detail Teks
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TERKUMPUL',
                                style: TextStyle(
                                  color: kWhite40,
                                  fontSize: 9,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                'Rp ${current.toInt().toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+$)"), (m) => "${m[1]}.")}',
                                style: const TextStyle(
                                  color: kWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'TARGET',
                                style: TextStyle(
                                  color: kWhite40,
                                  fontSize: 9,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                'Rp ${target.toInt().toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+$)"), (m) => "${m[1]}.")}',
                                style: TextStyle(
                                  color: kWhite.withOpacity(0.55),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8), // Gap lebih kecil antara teks dan foto
                        // Gambar Goal
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: kWhite.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: kWhite.withOpacity(0.1), width: 1),
                            image: latestSaving.imageUrl != null
                                ? DecorationImage(
                                    image: _getImageProvider(latestSaving.imageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: latestSaving.imageUrl == null
                              ? Icon(Icons.savings_outlined, color: kWhite.withOpacity(0.2), size: 28)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
                // Panah di pojok kanan bawah
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: Icon(
                    Icons.arrow_forward_ios_rounded, 
                    color: kWhite.withOpacity(0.15), 
                    size: 14
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildHppBepCard() {
    return GestureDetector(
      onTap: () async {
        // Pindahkan active navbar ke HPP (index 0) saat card diklik
        _vm.onNavTapManual(0);
        await Future.delayed(const Duration(milliseconds: 380));
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HitungHppPage()),
        );
        // Saat user balik ke Home, kembalikan active navbar ke Home (index 2)
        if (mounted) _vm.onNavTapManual(2);
      },
      child: Container(
        decoration: BoxDecoration(
          // Hijau terang vivid seperti screenshot
          color: const Color(0xFF6CF688),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            // Lingkaran gelap solid
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFF0D1F10), // hijau tua gelap solid
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calculate_outlined,
                color: Color(0xFFFBBF24), // kuning/amber
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Hitung HPP & BEP',
                style: TextStyle(
                  color: Color(0xFF0A1A0A),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              color: Color(0xFF0A1A0A),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomRow() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Insight ──
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kWhite20, width: 0.8),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'INSIGHT',
                    style: TextStyle(
                      color: kWhite40,
                      fontSize: 10,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: SizedBox(
                      width: 68,
                      height: 68,
                      child: CustomPaint(
                        painter: _DonutPainter(
                          slices: const [0.4, 0.6],
                          colors: [kGreen, kCardLight],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _insightLegend(kGreen, 'Cat A: 40%'),
                  const SizedBox(height: 4),
                  _insightLegend(kWhite40, 'Cat B: 60%'),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _vm.onInsightTap,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: kWhite20,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward,
                            color: kWhite, size: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // ── Catatan ──
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                // Hijau lime medium sesuai screenshot
                color: const Color(0xFF78C44A),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CATATAN',
                    style: TextStyle(
                      color: Color(0xFF1E3D0F), // hijau tua gelap
                      fontSize: 10,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ..._buildNoteLines(),
                  const Spacer(),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotesListView(),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'LIHAT DAFTAR',
                            style: TextStyle(
                              color: Color(0xFF1E3D0F),
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotesListView(),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Color(0xFF1E3D0F),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNoteLines() {
    final noteVm = context.watch<NoteViewModel>();
    final notes = noteVm.notes;

    if (notes.isEmpty) {
      return [
        const Text(
          'Belum ada catatan',
          style: TextStyle(
            color: Color(0xFF2D5A1B),
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ];
    }

    final latestNote = notes.first;
    final lines = latestNote.content.split('\n').take(2).toList();

    return [
      Text(
        latestNote.title,
        style: const TextStyle(
          color: Color(0xFF2D5A1B),
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      ...lines
          .map((line) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  line,
                  style: const TextStyle(
                    color: Color(0xFF2D5A1B),
                    fontSize: 12,
                    height: 1.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
    ];
  }

  Widget _insightLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: kWhite70, fontSize: 10)),
      ],
    );
  }

  // ─── Bottom Navbar ────────────────────────────────────────────────
  Widget _buildBottomNav() {
    const navIcons = [
      Icons.calculate_outlined, // 0 - HPP & BEP
      Icons.account_balance_wallet_outlined, // 1 - Wallet
      Icons.home, // 2 - Home (default aktif)
      Icons.show_chart, // 3 - Chart
      Icons.history, // 4 - History
    ];
    const int navCount = 5;
    const double navHeight = 68.0;
    const double circleSize = 48.0;
    // circle selalu tepat di tengah vertikal navbar
    const double circleTop = (navHeight - circleSize) / 2;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final navWidth = constraints.maxWidth;
          final itemWidth = navWidth / navCount;
          // posisi horizontal circle mengikuti tab aktif, tepat di tengah item
          final circleLeft =
              itemWidth * _vm.selectedIndex + (itemWidth / 2) - circleSize / 2;

          return SizedBox(
            height: navHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Background pill ──────────────────────────────────────
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: kNavBg.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(color: kNavBorder, width: 1.5),
                    ),
                  ),
                ),

                // ── Animated active circle ──────────
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOutCubic,
                  left: circleLeft,
                  top: circleTop,
                  child: Container(
                    width: circleSize,
                    height: circleSize,
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
                      navIcons[_vm.selectedIndex],
                      color: const Color(0xFF0C1B13),
                      size: 24,
                    ),
                  ),
                ),

                // ── Tap areas + inactive icons ───────────────────────────
                Row(
                  children: List.generate(navCount, (i) {
                    final isActive = i == _vm.selectedIndex;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          int? targetIndex = i;
                          while (targetIndex != null && targetIndex != 2) {
                            // Update index segera agar lingkaran bergerak halus
                            _vm.onNavTapManual(targetIndex);
                            
                            // Tunggu animasi lingkaran selesai
                            await Future.delayed(const Duration(milliseconds: 320));
                            if (!mounted) break;

                            Widget targetPage;
                            switch (targetIndex) {
                              case 0: targetPage = const HitungHppPage(); break;
                              case 1: targetPage = SavingListPage(userId: FirebaseAuth.instance.currentUser?.uid ?? ''); break;
                              case 3: targetPage = const InsightView(); break;
                              case 4: targetPage = const RiwayatView(); break;
                              default: targetIndex = null; continue;
                            }

                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => targetPage),
                            );

                            if (mounted && result is int) {
                              targetIndex = result;
                            } else {
                              targetIndex = null;
                            }
                          }

                          if (mounted) {
                            _vm.onNavTapManual(2);
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

// ── Sparkle Painter ───────────────────────────────────────────────────────────
class _SparklePainter extends CustomPainter {
  final List<_Sparkle> sparkles;
  final double time;

  _SparklePainter({required this.sparkles, required this.time});

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    const int points = 4;
    final outerRadius = size;
    final innerRadius = size * 0.35;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * pi / points) - pi / 2;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + cos(angle) * radius;
      final y = center.dy + sin(angle) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in sparkles) {
      final t = (time * s.speed + s.phase / (2 * pi)) % 1.0;
      final pulse = (sin(t * 2 * pi) + 1) / 2;
      final opacity = (s.opacity * pulse).clamp(0.0, 1.0);

      if (opacity < 0.05) continue;

      final paint = Paint()
        ..color = const Color(0xFF4ADE80).withOpacity(opacity)
        ..style = PaintingStyle.fill;

      final center = Offset(s.x * size.width, s.y * size.height);
      final starSize = s.size * (0.7 + 0.3 * pulse);
      _drawStar(canvas, center, starSize, paint);
    }
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.time != time;
}

// Helper untuk image provider (ditambahkan untuk support gambar tabungan)
ImageProvider _getImageProvider(String url) {
  if (url.startsWith('data:image')) {
    final base64String = url.split(',').last;
    return MemoryImage(base64Decode(base64String));
  }
  return NetworkImage(url);
}

// ── Donut Painter ─────────────────────────────────────────────────────────────
class _DonutPainter extends CustomPainter {
  final List<double> slices;
  final List<Color> colors;

  const _DonutPainter({required this.slices, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 12.0;
    final rect =
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startAngle = -pi / 2;
    for (int i = 0; i < slices.length; i++) {
      paint.color = colors[i % colors.length];
      final sweepAngle = 2 * pi * slices[i];
      canvas.drawArc(rect, startAngle, sweepAngle - 0.08, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

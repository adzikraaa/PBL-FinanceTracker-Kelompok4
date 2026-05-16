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
import '../../viewmodels/auth_viewmodel.dart';
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
    // Use Consumer instead of AnimatedBuilder to avoid first-frame
    // rendering issues with ChangeNotifier-as-animation pattern.
    return Consumer<HomeViewModel>(
      builder: (context, vm, _) {
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
    final isPremium = context.watch<AuthViewModel>().isPremium;

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
          // ── Premium Upgrade Cart (Visible if NOT premium) ──
          if (!isPremium)
            GestureDetector(
              onTap: () => _showPremiumUpgradeSheet(context),
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0, right: 16.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      color: Color(0xFFC49A45),
                      size: 28,
                    ),
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // ── Profile avatar button ──
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileView()),
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Avatar
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
                        color: const Color(0xFF22C55E).withValues(alpha: 0.35),
                        blurRadius: 12,
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

                // Premium Crown Badge (Visible if premium)
                if (isPremium)
                  const Positioned(
                    top: -8,
                    right: -8,
                    child: Text(
                      '👑',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPremiumUpgradeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PremiumUpgradeSheet(),
    );
  }

  Widget _buildRiwayatCard() {
    final riwayatVm = context.watch<RiwayatViewModel>();
    final latest = riwayatVm.latest;
    final currFmt = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    void goToRiwayat() {
      _vm.onNavTapManual(4);
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
            onTap: () {
              _vm.onNavTapManual(1);
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
          onTap: () {
            _vm.onNavTapManual(1);
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
                                    image: (savingVm.getCachedImage(latestSaving.imageUrl!) as ImageProvider?) ?? const AssetImage('assets/images/logo.png'),
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
      onTap: () {
        _vm.onNavTapManual(0);
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
            child: GestureDetector(
              onTap: () => _vm.onNavTapManual(3),
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
                  ],
                ),
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

}

// ── Premium Upgrade Bottom Sheet ──────────────────────────────────────────────
class _PremiumUpgradeSheet extends StatefulWidget {
  const _PremiumUpgradeSheet();

  @override
  State<_PremiumUpgradeSheet> createState() => _PremiumUpgradeSheetState();
}

class _PremiumUpgradeSheetState extends State<_PremiumUpgradeSheet>
    with TickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _slideCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SlideTransition(
      position: _slideAnim,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.88,
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0C2215),
                Color(0xFF0A1C12),
                Color(0xFF081510),
              ],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle bar (pinned top) ──
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // ── Scrollable content ──
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottomPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Golden crown banner
                        _buildTopBanner(),
                        const SizedBox(height: 20),

                        // Feature list
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              _buildFeatureRow(
                                Icons.picture_as_pdf_rounded,
                                'Ekspor Laporan PDF',
                                'Tanpa watermark, kualitas premium',
                                const Color(0xFFFFD60A),
                                delay: 0,
                              ),
                              const SizedBox(height: 12),
                              _buildFeatureRow(
                                Icons.bar_chart_rounded,
                                'Analitik Bisnis Lengkap',
                                'Grafik profit, margin & BEP otomatis',
                                const Color(0xFF6CF688),
                                delay: 80,
                              ),
                              const SizedBox(height: 12),
                              _buildFeatureRow(
                                Icons.lock_open_rounded,
                                'Akses Semua Fitur',
                                'Tanpa batasan, selamanya',
                                const Color(0xFFFF8C60),
                                delay: 160,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // CTA button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildCtaButton(context),
                        ),

                        // Price note
                        const SizedBox(height: 12),
                        Text(
                          'Hanya Rp 100rb SEUMUR HIDUP 🎉',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 12,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBanner() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Shimmer glow behind crown
        AnimatedBuilder(
          animation: _shimmerCtrl,
          builder: (_, __) {
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  startAngle: _shimmerCtrl.value * 2 * 3.14159,
                  colors: const [
                    Color(0xFFFFD60A),
                    Color(0xFFFFA500),
                    Color(0xFF0C2215),
                    Color(0xFF0C2215),
                    Color(0xFFFFD60A),
                  ],
                ),
              ),
            );
          },
        ),
        // Crown container
        ScaleTransition(
          scale: _pulseAnim,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFE347), Color(0xFFFF9500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD60A).withValues(alpha: 0.5),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFF1A0F00),
              size: 44,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(
    IconData icon,
    String title,
    String subtitle,
    Color iconColor, {
    int delay = 0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 20 * (1 - v)), child: child),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: iconColor.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.check_circle_rounded, color: iconColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCtaButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        // TODO: navigate to payment page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Fitur pembayaran segera hadir! 🚀',
              style: TextStyle(
                color: Color(0xFF0A1F0E),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            backgroundColor: const Color(0xFF4ADE80),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _shimmerCtrl,
        builder: (_, __) {
          return Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: const [Color(0xFFFFE347), Color(0xFFFFA500)],
                begin: Alignment(-1 + _shimmerCtrl.value * 2, 0),
                end: Alignment(1 + _shimmerCtrl.value * 2, 0),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD60A).withValues(alpha: 0.45),
                  blurRadius: 18,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  color: Color(0xFF1A0F00),
                  size: 22,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Langganan Sekarang',
                  style: TextStyle(
                    color: Color(0xFF1A0F00),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF1A0F00),
                  size: 20,
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

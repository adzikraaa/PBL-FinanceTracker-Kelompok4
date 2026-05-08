import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../finance/hitung_hpp_page.dart';
import '../savings/saving_list_page.dart';
import '../../viewmodels/saving_viewmodel.dart';
import 'profile_view.dart';
import '../insight/insight_view.dart';
import 'package:provider/provider.dart';

// ─── Color Palette (Dark Green Theme) ────────────────────────────────────────
const Color kBg        = Color(0xFF0D2818);
const Color kBgMid     = Color(0xFF122A1C);
const Color kCard      = Color(0xFF163520);
const Color kCardLight = Color(0xFF1E4A2C);
const Color kGreen     = Color(0xFF4ADE80);
const Color kGreenLime = Color(0xFF86EFAC);
const Color kGreenBtn  = Color(0xFF22C55E);
const Color kRiwayat   = Color(0xFF9CD76A);
const Color kWhite     = Color(0xFFFFFFFF);
const Color kWhite70   = Color(0xB3FFFFFF);
const Color kWhite40   = Color(0x66FFFFFF);
const Color kWhite20   = Color(0x33FFFFFF);
const Color kCatatan   = Color(0xFF163520);
const Color kNavBg     = Color(0xFF132018);
const Color kNavBorder = Color(0xFF2C4334);
const Color kNavIcon   = Color(0xFF6B7E72);
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
  final HomeViewModel _vm = HomeViewModel();

  late AnimationController _sparkleController;
  late List<_Sparkle> _sparkles;
  final Random _rng = Random();

  late AnimationController _progressController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();

    _vm.onNavTap(2);

    // Inisialisasi pendengar data tabungan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        context.read<SavingViewModel>().listenSavings(user.uid);
      }
    });

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _sparkles = List.generate(25, (_) => _Sparkle(
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      size: _rng.nextDouble() * 7 + 3,
      opacity: _rng.nextDouble() * 0.6 + 0.2,
      phase: _rng.nextDouble() * 2 * pi,
      speed: _rng.nextDouble() * 1.2 + 0.4,
    ));

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnim = Tween<double>(begin: 0, end: _vm.tabunganProgress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _progressController.forward();
    });
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    _progressController.dispose();
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
                child: _buildBody(_vm),
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

  Widget _buildBody(HomeViewModel vm) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    
    switch (vm.selectedIndex) {
      case 1: // Tabungan
        return Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: SavingListPage(userId: userId),
        );
      case 2: // Home Dashboard
        return SingleChildScrollView(
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
        );
      case 3: // Insight
        return const InsightView();
      default:
        return Center(
          child: Text(
            'Halaman ${vm.selectedIndex} Belum Tersedia',
            style: const TextStyle(color: Colors.white70),
          ),
        );
    }
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
    return Container(
      decoration: BoxDecoration(
        color: kRiwayat,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB8E88A), width: 0.8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 12),
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
                    color: const Color(0xFF1E3D0F).withOpacity(0.3),
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
                  child: Text(
                    _vm.riwayatNama,
                    style: const TextStyle(
                      color: Color(0xFF1A3A10),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  'Rp ${_vm.riwayatHarga}',
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
              onPressed: _vm.onLihatRiwayat,
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
    );
  }

  Widget _buildTabunganCard() {
    return Consumer<SavingViewModel>(
      builder: (context, savingVm, child) {
        final bool hasData = savingVm.savings.isNotEmpty;

        if (!hasData) {
          return GestureDetector(
            onTap: () => _vm.onNavTap(1), // Pindah ke tab tabungan
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
          onTap: () => _vm.onNavTap(1), // Pindah ke tab tabungan
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
        _vm.onNavTap(0);
        await Future.delayed(const Duration(milliseconds: 380));
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HitungHppPage()),
        );
        if (mounted) _vm.onNavTap(2);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF6CF688),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFF0D1F10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calculate_outlined,
                color: Color(0xFFFBBF24),
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
          Expanded(
            child: Consumer<SavingViewModel>(
              builder: (context, savingVm, _) {
                double totalCurrent = savingVm.savings
                    .fold(0.0, (sum, item) => sum + item.currentAmount);
                double totalTarget = savingVm.savings
                    .fold(0.0, (sum, item) => sum + item.targetAmount);

                double totalProgress = totalTarget > 0
                    ? (totalCurrent / totalTarget).clamp(0.0, 1.0)
                    : 0.0;

                return Container(
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
                              slices: [totalProgress, 1.0 - totalProgress],
                              colors: [kGreen, kCardLight],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _insightLegend(kGreen,
                          'Terkumpul: ${(totalProgress * 100).toInt()}%'),
                      const SizedBox(height: 4),
                      _insightLegend(kWhite40,
                          'Sisa: ${((1.0 - totalProgress) * 100).toInt()}%'),
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
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
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
                      color: Color(0xFF1E3D0F),
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
                        onTap: _vm.onCatatanTap,
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
                        onTap: _vm.onCatatanTap,
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
    final widths = [1.0, 0.75, 0.88];
    return widths
        .map((w) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                height: 5,
                width: double.infinity,
                margin: EdgeInsets.only(right: (1 - w) * 60),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D5A1B),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ))
        .toList();
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

  Widget _buildBottomNav() {
    const navIcons = [
      Icons.calculate_outlined,
      Icons.account_balance_wallet_outlined,
      Icons.home,
      Icons.show_chart,
      Icons.history,
    ];
    const int navCount = 5;
    const double navHeight = 68.0;
    const double circleSize = 48.0;
    const double circleTop = (navHeight - circleSize) / 2;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final navWidth = constraints.maxWidth;
          final itemWidth = navWidth / navCount;
          final circleLeft =
              itemWidth * _vm.selectedIndex + (itemWidth / 2) - circleSize / 2;

          return SizedBox(
            height: navHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: kNavBg.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(color: kNavBorder, width: 1.5),
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
                Row(
                  children: List.generate(navCount, (i) {
                    final isActive = i == _vm.selectedIndex;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          if (i == 0) {
                            _vm.onNavTap(0);
                            await Future.delayed(
                                const Duration(milliseconds: 340));
                            if (!mounted) return;
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const HitungHppPage()),
                            );
                            if (mounted) _vm.onNavTap(2);
                            if (mounted) _vm.onNavTap(2);
                          } else {
                            _vm.onNavTap(i);
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
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

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
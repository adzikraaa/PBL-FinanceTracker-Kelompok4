import 'package:flutter/material.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../finance/hitung_hpp_page.dart';
import '../savings/savings_list_view.dart';
import 'insight_view.dart';

// ─── Warna ───────────────────────────────────────────────────────────────────
const Color kUngu   = Color(0xFF430D75);
const Color kKuning = Color(0xFFFFD900);
const Color kAbu    = Color(0xFFC3C3C3);
const Color kPutih  = Color(0xFFFFFFFF);
const Color kHitam  = Color(0xFF000000);

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeViewModel _vm = HomeViewModel();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: kPutih,
          body: Stack(
            children: [
              // ── Background blob pastel ──
              _buildBackground(),
              // ── Konten scroll ──
              SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildGreeting(),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildRiwayatCard(),
                            const SizedBox(height: 16),
                            _buildTabunganCard(),
                            const SizedBox(height: 16),
                            _buildHppBepCard(),
                            const SizedBox(height: 16),
                            _buildBottomRow(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ── Navbar nempel di bawah ──
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

  Widget _buildBackground() {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _BlobPainter(),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'User ${_vm.userName}',
            style: const TextStyle(
              color: kUngu,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 10),
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF4ECDC4),
                child: const Icon(Icons.person, color: kPutih, size: 24),
              ),
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: kKuning,
                    shape: BoxShape.circle,
                    border: Border.all(color: kPutih, width: 1.5),
                  ),
                  child: const Icon(Icons.star, size: 9, color: kUngu),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Greeting ──────────────────────────────────────────────────────────────
  Widget _buildGreeting() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hi, ${_vm.userName}!',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: kHitam,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Mulai hitung HPP & BEP untuk produk\nbisnismu sekarang.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // ── Kartu Riwayat ─────────────────────────────────────────────────────────
  Widget _buildRiwayatCard() {
    return Container(
      decoration: BoxDecoration(
        color: kUngu,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.access_time, color: kPutih, size: 20),
              SizedBox(width: 8),
              Text('Riwayat',
                  style: TextStyle(
                      color: kPutih,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          const Text('RIWAYAT TERBARU',
              style: TextStyle(color: kAbu, fontSize: 11, letterSpacing: 1)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_vm.riwayatNama,
                      style: const TextStyle(
                          color: kPutih,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(_vm.riwayatHarga,
                      style: const TextStyle(
                          color: kKuning,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: kKuning,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      _vm.riwayatUntung
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: kUngu,
                      size: 18,
                    ),
                    Text(
                      _vm.riwayatUntung ? 'UNTUNG' : 'RUGI',
                      style: const TextStyle(
                          color: kUngu,
                          fontWeight: FontWeight.bold,
                          fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: _vm.onLihatRiwayat,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kPutih),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('LIHAT SEMUA RIWAYAT',
                      style: TextStyle(
                          color: kPutih,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, color: kPutih, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Kartu Tabungan ────────────────────────────────────────────────────────
  Widget _buildTabunganCard() {
    return Container(
      decoration: BoxDecoration(
        color: kKuning,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: kUngu, size: 20),
              SizedBox(width: 8),
              Text('Tabungan',
                  style: TextStyle(
                      color: kUngu,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: _vm.tabunganProgress,
                        strokeWidth: 12,
                        backgroundColor: kPutih.withValues(alpha: 0.5),
                        valueColor: const AlwaysStoppedAnimation<Color>(kUngu),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.directions_car,
                            color: kUngu, size: 30),
                        Text(
                          '${(_vm.tabunganProgress * 100).toInt()}%',
                          style: const TextStyle(
                              color: kUngu,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(width: 1, height: 70, color: kUngu),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TARGET',
                        style: TextStyle(
                            fontSize: 11, color: kUngu, letterSpacing: 1)),
                    Row(
                      children: [
                        const Icon(Icons.track_changes,
                            color: kUngu, size: 16),
                        const SizedBox(width: 4),
                        Text(_vm.tabunganTarget,
                            style: const TextStyle(
                                color: kUngu,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ],
                    ),
                    Divider(color: kUngu.withValues(alpha: 0.3)),
                    const Text('TABUNGAN SAAT INI',
                        style: TextStyle(
                            fontSize: 11, color: kUngu, letterSpacing: 1)),
                    Row(
                      children: [
                        const Icon(Icons.savings, color: kUngu, size: 16),
                        const SizedBox(width: 4),
                        Text(_vm.tabunganSaatIni,
                            style: const TextStyle(
                                color: kUngu,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_vm.tabunganSisa,
                      style: const TextStyle(
                          color: kUngu,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  Text(_vm.tabunganEmoji,
                      style: const TextStyle(color: kUngu, fontSize: 12)),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SavingsListView()),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                      color: kPutih, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_forward,
                      color: kHitam, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Kartu HPP & BEP ───────────────────────────────────────────────────────
  Widget _buildHppBepCard() {
    return GestureDetector(
      onTap: _vm.onHppBepTap,
      child: Container(
        decoration: BoxDecoration(
          color: kUngu,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: kPutih.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calculate_outlined,
                  color: kKuning, size: 26),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Hitung HPP & BEP',
                style: TextStyle(
                    color: kPutih,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: kPutih.withValues(alpha: 0.7), size: 18),
          ],
        ),
      ),
    );
  }

  // ── Baris Bawah: Insight + Catatan ───────────────────────────────────────
  Widget _buildBottomRow() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Insight ──
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: kUngu,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.pie_chart, color: kKuning, size: 18),
                      SizedBox(width: 6),
                      Text('Insight',
                          style: TextStyle(
                              color: kPutih,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: CircularProgressIndicator(
                        value: 0.65,
                        strokeWidth: 13,
                        backgroundColor: kPutih.withValues(alpha: 0.15),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(kKuning),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _legendItem('General'),
                  const SizedBox(height: 6),
                  _legendItem('Apa yh'),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const InsightView()),
                        );
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                            color: kPutih, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward,
                            color: kHitam, size: 16),
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
                color: const Color(0xFF8E8E9A),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.edit_note, color: kPutih, size: 18),
                      SizedBox(width: 6),
                      Text('Catatan',
                          style: TextStyle(
                              color: kPutih,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(_vm.catatanJudul,
                      style: const TextStyle(
                          color: kPutih,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(_vm.catatanIsi,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: kPutih.withValues(alpha: 0.8),
                          fontSize: 11)),
                  const Spacer(),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _vm.onCatatanTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: kPutih,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Lihat Daftar',
                              style: TextStyle(
                                  color: kHitam,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _vm.onCatatanTap,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                              color: kPutih, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_forward,
                              color: kHitam, size: 14),
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

  Widget _legendItem(String label) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 6,
          decoration: BoxDecoration(
            color: kPutih.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(color: kPutih, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ── Bottom Navigation Bar ─────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final icons = [
      Icons.calculate_outlined,
      Icons.account_balance_wallet_outlined,
      Icons.home_rounded,
      Icons.pie_chart_outline,
      Icons.access_time,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final navWidth = screenWidth - 24;
        final itemWidth = navWidth / icons.length;
        final selectedX =
            (itemWidth * _vm.selectedIndex) + (itemWidth / 2) + 12;

        return Container(
          color: Colors.transparent,
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            height: 90,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  bottom: 0,
                  left: 12,
                  right: 12,
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: kUngu,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Row(
                      children: List.generate(icons.length, (i) {
                        final isSelected = i == _vm.selectedIndex;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (i == 0) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const HitungHppPage()),
                                );
                              } else if (i == 1) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SavingsListView()),
                                );
                              } else {
                                _vm.onNavTap(i);
                              }
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Icon(
                                icons[i],
                                color: isSelected
                                    ? Colors.transparent
                                    : kPutih.withValues(alpha: 0.6),
                                size: 24,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  bottom: 18,
                  left: selectedX - 31,
                  child: GestureDetector(
                    onTap: () => _vm.onNavTap(_vm.selectedIndex),
                    child: Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFD0D0D0), Color(0xFF909090)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: kUngu,
                        ),
                        child: Icon(icons[_vm.selectedIndex],
                            color: kPutih, size: 26),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Background Blob Painter ───────────────────────────────────────────────────
class _BlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);

    // Blob ungu kiri tengah
    paint.color = const Color.fromARGB(255, 168, 171, 245);
    canvas.drawCircle(
        Offset(size.width * 0.22, size.height * 0.38), 110, paint);

    // Blob kuning kanan atas
    paint.color = const Color.fromARGB(255, 247, 236, 180);
    canvas.drawCircle(
        Offset(size.width * 0.78, size.height * 0.07), 55, paint);

    // Blob biru kanan tengah
    paint.color = const Color.fromARGB(255, 179, 207, 242);
    canvas.drawCircle(
        Offset(size.width * 0.88, size.height * 0.58), 130, paint);

    // Blob pink kanan bawah
    paint.color = const Color.fromARGB(255, 241, 191, 209);
    canvas.drawCircle(
        Offset(size.width * 0.78, size.height * 0.73), 75, paint);

    // Blob kuning bawah tengah
    paint.color = const Color.fromARGB(255, 247, 231, 185);
    canvas.drawCircle(
        Offset(size.width * 0.38, size.height * 0.9), 100, paint);

    // Blob pink kiri bawah
    paint.color = const Color.fromARGB(255, 255, 211, 227);
    canvas.drawCircle(
        Offset(size.width * 0.05, size.height * 0.75), 120, paint);

    // Blob ungu kiri atas
    paint.color = const Color.fromARGB(255, 203, 192, 244);
    canvas.drawCircle(
        Offset(size.width * 0.0, size.height * 0.08), 80, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
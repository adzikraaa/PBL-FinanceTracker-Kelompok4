import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/premium_viewmodel.dart';
import '../home/main_navigation.dart';
import 'dart:math';

class PaymentSuccessView extends StatefulWidget {
  const PaymentSuccessView({super.key});

  @override
  State<PaymentSuccessView> createState() => _PaymentSuccessViewState();
}

class _PaymentSuccessViewState extends State<PaymentSuccessView>
    with TickerProviderStateMixin {
  late AnimationController _checkCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _contentCtrl;

  late Animation<double> _checkScale;
  late Animation<double> _checkOpacity;
  late Animation<double> _ringScale;
  late Animation<double> _contentSlide;

  @override
  void initState() {
    super.initState();

    _checkCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    _contentCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _checkScale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: 1.2)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 60),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.2, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 40),
    ]).animate(_checkCtrl);

    _checkOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _checkCtrl,
          curve: const Interval(0, 0.5, curve: Curves.easeIn)),
    );

    _ringScale = Tween<double>(begin: 0.8, end: 1.6).animate(
      CurvedAnimation(parent: _checkCtrl, curve: Curves.easeOut),
    );

    _contentSlide = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic),
    );

    _checkCtrl.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _particleCtrl.repeat();
        _contentCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    _particleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PremiumViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A1F0D), Color(0xFF0D1117)],
              ),
            ),
          ),

          // Confetti particles
          ...List.generate(20, (i) => _buildParticle(i)),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 60),

                        // Success animation
                        _buildSuccessAnimation(),
                        const SizedBox(height: 28),

                        // Title
                        AnimatedBuilder(
                          animation: _contentCtrl,
                          builder: (_, child) => Transform.translate(
                            offset: Offset(0, _contentSlide.value),
                            child: Opacity(
                                opacity: _contentCtrl.value, child: child),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                'Pembayaran Berhasil! \u{1f389}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Selamat! Akun kamu sekarang\nsudah Premium Seumur Hidup.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Receipt
                        AnimatedBuilder(
                          animation: _contentCtrl,
                          builder: (_, child) => Transform.translate(
                            offset: Offset(0, _contentSlide.value * 1.5),
                            child: Opacity(
                                opacity: _contentCtrl.value, child: child),
                          ),
                          child: _buildReceipt(vm),
                        ),
                        const SizedBox(height: 20),

                        // Benefits aktif
                        AnimatedBuilder(
                          animation: _contentCtrl,
                          builder: (_, child) => Transform.translate(
                            offset: Offset(0, _contentSlide.value * 2),
                            child: Opacity(
                                opacity: _contentCtrl.value, child: child),
                          ),
                          child: _buildBenefits(),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Bottom button
                AnimatedBuilder(
                  animation: _contentCtrl,
                  builder: (_, child) =>
                      Opacity(opacity: _contentCtrl.value, child: child),
                  child: _buildBottomButton(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return AnimatedBuilder(
      animation: _checkCtrl,
      builder: (_, __) => SizedBox(
        width: 140,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: _ringScale.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF22C55E)
                        .withOpacity(1 - _checkCtrl.value),
                    width: 2,
                  ),
                ),
              ),
            ),
            FadeTransition(
              opacity: _checkOpacity,
              child: ScaleTransition(
                scale: _checkScale,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF22C55E), Color(0xFF4ADE80)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22C55E).withOpacity(0.45),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 52),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticle(int index) {
    final rng = Random(index * 42);
    final colors = [
      const Color(0xFFFFD700),
      const Color(0xFF22C55E),
      const Color(0xFF9B7FC4),
      const Color(0xFFFFA500),
      const Color(0xFF60A5FA),
    ];
    final color = colors[index % colors.length];
    final size = rng.nextDouble() * 8 + 4;
    final startX = rng.nextDouble();
    final startY = rng.nextDouble() * 0.5;
    final dur = rng.nextDouble() * 1000 + 1000;

    return AnimatedBuilder(
      animation: _particleCtrl,
      builder: (_, __) {
        final t = (_particleCtrl.value * 2000 % dur) / dur;
        final x = startX + sin(t * pi * 2 + index) * 0.05;
        final y = startY + t * 0.6;
        final opacity = (1 - t) * 0.7;
        if (opacity <= 0) return const SizedBox.shrink();
        return Positioned(
          left: MediaQuery.of(context).size.width * x,
          top: MediaQuery.of(context).size.height * y,
          child: Opacity(
            opacity: opacity,
            child: Transform.rotate(
              angle: t * pi * 4,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color,
                  shape:
                      index % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius:
                      index % 2 != 0 ? BorderRadius.circular(2) : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceipt(PremiumViewModel vm) {
    final purchased = vm.premiumPurchasedAt;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        children: [
          _row('Paket', 'Premium Seumur Hidup'),
          const SizedBox(height: 10),
          _row('Order ID',
              vm.currentOrderId?.split('-').last ?? '-',
              valueColor: const Color(0xFF9CA3AF)),
          const SizedBox(height: 10),
          _row('Tanggal Beli', _formatDate(purchased)),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withOpacity(0.06), height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Dibayar',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              Text(
                'Rp 100.000',
                style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.45), fontSize: 13)),
        Text(value,
            style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildBenefits() {
    final perks = PremiumViewModel.benefits;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(colors: [Color(0xFF0A1A0F), Color(0xFF112214)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFF22C55E).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.workspace_premium_rounded,
                  color: Color(0xFFFFD700), size: 18),
              SizedBox(width: 8),
              Text('Fitur Premium Aktif',
                  style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          ...perks.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Color(0xFF22C55E), size: 16),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['title']!,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        Text(p['subtitle']!,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        border:
            Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
          (_) => false,
        ),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_rounded, color: Colors.black, size: 22),
              SizedBox(width: 10),
              Text('Mulai Gunakan Premium',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    const m = [
      'Jan','Feb','Mar','Apr','Mei','Jun',
      'Jul','Agu','Sep','Okt','Nov','Des'
    ];
    return '${date.day} ${m[date.month - 1]} ${date.year}';
  }
}

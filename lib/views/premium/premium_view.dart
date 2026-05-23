import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../viewmodels/premium_viewmodel.dart';
import '../../data/config/midtrans_config.dart';
import 'payment_view.dart';

class PremiumView extends StatefulWidget {
  const PremiumView({super.key});

  @override
  State<PremiumView> createState() => _PremiumViewState();
}

class _PremiumViewState extends State<PremiumView>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _slideAnim = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _slideCtrl.forward();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PremiumViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A1A0F),
      body: Stack(
        children: [
          // Background radial glow
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFD4A017).withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── AppBar ──────────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 15),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: AnimatedBuilder(
                      animation: _slideCtrl,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, _slideAnim.value),
                        child: Opacity(opacity: _fadeAnim.value, child: child),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),

                            // ── Medal icon ────────────────────────────
                            AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (_, child) => Transform.scale(
                                scale: _pulseAnim.value,
                                child: child,
                              ),
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFD700),
                                      Color(0xFFFFA500),
                                      Color(0xFFE8890C),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700)
                                          .withOpacity(0.45),
                                      blurRadius: 32,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Ribbon bottom
                                    Positioned(
                                      bottom: 10,
                                      child: Container(
                                        width: 28,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFCC8800),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Color(0xFF1A0A00),
                                      size: 44,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── Sudah premium badge ───────────────────
                            if (vm.isPremium) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF22C55E).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF22C55E)
                                        .withOpacity(0.4),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified_rounded,
                                        color: Color(0xFF22C55E), size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'Premium Aktif · Seumur Hidup',
                                      style: TextStyle(
                                        color: Color(0xFF22C55E),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // ── Judul ─────────────────────────────────
                            Text(
                              vm.isPremium
                                  ? 'Kamu Sudah Premium! 🎉'
                                  : 'Upgrade ke Premium',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              vm.isPremium
                                  ? 'Nikmati semua fitur eksklusif BizPrice'
                                  : 'Bayar sekali, nikmati selamanya',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.80),
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // ── Benefit cards ─────────────────────────
                            ...PremiumViewModel.benefits.map(
                              (b) => _BenefitCard(
                                title: b['title']!,
                                subtitle: b['subtitle']!,
                                iconKey: b['icon']!,
                                isActive: vm.isPremium,
                              ),
                            ),

                            const SizedBox(height: 28),

                            // ── Error ─────────────────────────────────
                            if (vm.errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.red.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: Colors.redAccent, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        vm.errorMessage!,
                                        style: const TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Bottom CTA ────────────────────────────────────────
                if (!vm.isPremium)
                  _BottomCTA(
                    isLoading: vm.paymentProcessing,
                    onTap: () => _onSubscribe(context, vm),
                  ),

                if (vm.isPremium)
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF22C55E).withOpacity(0.4),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: Color(0xFF22C55E), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Fitur Premium Sudah Aktif',
                              style: TextStyle(
                                color: Color(0xFF22C55E),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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

  Future<void> _onSubscribe(
      BuildContext context, PremiumViewModel vm) async {
    HapticFeedback.mediumImpact();
    vm.clearError();

    final ok = await vm.createMidtransTransaction();
    if (!ok || !context.mounted) return;

    if (kIsWeb) {
      final url = vm.snapUrl;
      if (url != null) {
        final messenger = ScaffoldMessenger.of(context);
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          messenger.showSnackBar(
            const SnackBar(content: Text('Gagal membuka link pembayaran')),
          );
        }
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: vm,
            child: const PaymentView(),
          ),
        ),
      );
    }
  }
}

// ── Benefit Card ─────────────────────────────────────────────────────────────

class _BenefitCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconKey;
  final bool isActive;

  const _BenefitCard({
    required this.title,
    required this.subtitle,
    required this.iconKey,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _icon(iconKey);
    final iconColor = _iconColor(iconKey);
    final iconBg = _iconBg(iconKey);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111E14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? const Color(0xFF22C55E).withOpacity(0.25)
              : Colors.white.withOpacity(0.07),
        ),
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.78),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Checkmark
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFFFD700),
              boxShadow: [
                BoxShadow(
                  color: (isActive
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFFFD700))
                      .withOpacity(0.3),
                  blurRadius: 8,
                )
              ],
            ),
            child: const Icon(Icons.check, color: Colors.black, size: 16),
          ),
        ],
      ),
    );
  }

  IconData _icon(String key) {
    switch (key) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'analytics':
        return Icons.bar_chart_rounded;
      case 'unlock':
        return Icons.lock_open_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  Color _iconColor(String key) {
    switch (key) {
      case 'pdf':
        return const Color(0xFFFFD700);
      case 'analytics':
        return const Color(0xFF4ADE80);
      case 'unlock':
        return const Color(0xFFFF8C42);
      default:
        return const Color(0xFFFFD700);
    }
  }

  Color _iconBg(String key) {
    switch (key) {
      case 'pdf':
        return const Color(0xFFFFD700).withOpacity(0.12);
      case 'analytics':
        return const Color(0xFF4ADE80).withOpacity(0.12);
      case 'unlock':
        return const Color(0xFFFF8C42).withOpacity(0.12);
      default:
        return const Color(0xFFFFD700).withOpacity(0.12);
    }
  }
}

// ── Bottom CTA ───────────────────────────────────────────────────────────────

class _BottomCTA extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _BottomCTA({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1A0F),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: isLoading ? null : onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                gradient: isLoading
                    ? const LinearGradient(
                        colors: [Color(0xFF4B3A00), Color(0xFF4B3A00)])
                    : const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isLoading
                    ? null
                    : [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.35),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
              ),
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFD700),
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bolt_rounded,
                            color: Colors.black, size: 22),
                        SizedBox(width: 6),
                        Text(
                          'Langganan Sekarang',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded,
                            color: Colors.black, size: 18),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Hanya Rp ${_fmt(MidtransConfig.premiumPrice)} SEUMUR HIDUP 🎉',
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int price) {
    final s = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

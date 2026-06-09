import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../shared/colors.dart';
import '../home/main_navigation.dart';
import 'welcome_view.dart';

class EmailVerificationView extends StatefulWidget {
  const EmailVerificationView({super.key});

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late AnimationController _sparkleCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _pulseAnim;

  Timer? _timer;
  int _cooldownSeconds = 0;
  bool _checkingStatus = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Otomatis cek verifikasi setiap 5 detik agar pengguna tidak harus menekan tombol
    _startAutoCheckTimer();
  }

  void _startAutoCheckTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final authVm = Provider.of<AuthViewModel>(context, listen: false);
      final isVerified = await authVm.checkIfEmailVerified();
      if (isVerified && mounted) {
        _timer?.cancel();
        _navigateToDashboard();
      }
    });
  }

  void _navigateToDashboard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email berhasil diverifikasi! \u{1f389} Selamat datang.'),
        backgroundColor: AppColors.successGreen,
      ),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
      (route) => false,
    );
  }

  void _startCooldown() {
    setState(() => _cooldownSeconds = 60);
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownSeconds == 0) {
        timer.cancel();
      } else {
        setState(() => _cooldownSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    _sparkleCtrl.dispose();
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthViewModel>(context);
    final userEmail = authVm.currentUser?.email ?? 'email Anda';

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background
          _buildBackground(),

          // 2. Grid Overlay (Aesthetics)
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter(color: const Color(0xFF6DFC9A))),
          ),

          // 3. Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Animated pulse envelope icon
                      Center(
                        child: AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnim.value,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF6DFC9A).withOpacity(0.12),
                                  border: Border.all(
                                    color: const Color(0xFF6DFC9A).withOpacity(0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6DFC9A).withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.mark_email_unread_rounded,
                                  color: Color(0xFF6DFC9A),
                                  size: 48,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Main glassmorphism card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Verifikasi Email Anda',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 16),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: 'Kami telah mengirimkan tautan verifikasi ke:\n',
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  color: AppColors.white.withOpacity(0.7),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                                children: [
                                  TextSpan(
                                    text: userEmail,
                                    style: const TextStyle(
                                      color: Color(0xFF6DFC9A),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '\n\nSilakan periksa kotak masuk (atau folder spam) Anda dan klik tautan tersebut untuk mengaktifkan akun Anda.',
                                    style: TextStyle(
                                      color: AppColors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Button "Saya Sudah Verifikasi"
                            GestureDetector(
                              onTap: (_checkingStatus || authVm.isLoading)
                                  ? null
                                  : () async {
                                      setState(() => _checkingStatus = true);
                                      final isVerified = await authVm.checkIfEmailVerified();
                                      setState(() => _checkingStatus = false);

                                      if (!mounted) return;

                                      if (isVerified) {
                                        _navigateToDashboard();
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              authVm.errorMessage ??
                                                  'Email Anda belum diverifikasi. Silakan periksa kembali email Anda.',
                                            ),
                                            backgroundColor: AppColors.errorRed,
                                          ),
                                        );
                                      }
                                    },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.accentYellow,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accentYellow.withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: (_checkingStatus || authVm.isLoading)
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: AppColors.textDark,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'Saya Sudah Verifikasi',
                                          style: TextStyle(
                                            fontFamily: 'Lexend',
                                            color: AppColors.textDark,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Resend email button
                            TextButton(
                              onPressed: (_cooldownSeconds > 0 || authVm.isLoading)
                                  ? null
                                  : () async {
                                      final success = await authVm.sendVerificationEmail();
                                      if (!mounted) return;
                                      if (success) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Email verifikasi baru telah dikirim! \u{1f4e9}'),
                                            backgroundColor: AppColors.successGreen,
                                          ),
                                        );
                                        _startCooldown();
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              authVm.errorMessage ??
                                                  'Gagal mengirim email verifikasi.',
                                            ),
                                            backgroundColor: AppColors.errorRed,
                                          ),
                                        );
                                      }
                                    },
                              child: Text(
                                _cooldownSeconds > 0
                                    ? 'Kirim Ulang Email ($_cooldownSeconds s)'
                                    : 'Kirim Ulang Email',
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  color: _cooldownSeconds > 0
                                      ? AppColors.white.withOpacity(0.4)
                                      : const Color(0xFF6DFC9A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ⚠️ Spam Warning Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107).withOpacity(0.10),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFFFC107).withOpacity(0.45),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFFFC107),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Email tidak muncul di inbox?',
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      color: Color(0xFFFFC107),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Cek folder Spam atau Junk di Gmail. Email verifikasi kadang masuk ke sana secara otomatis. Tandai sebagai "Bukan Spam" agar email berikutnya langsung masuk inbox.',
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      color: const Color(0xFFFFC107).withOpacity(0.85),
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sign Out / Back button
                      TextButton.icon(
                        onPressed: () async {
                          await authVm.logout();
                          if (!mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const WelcomeView()),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 18),
                        label: const Text(
                          'Kembali ke Halaman Utama / Keluar',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const Color _bg1 = Color(0xFF061D12);
  static const Color _bg2 = Color(0xFF0D2E1E);
  static const Color _bg3 = Color(0xFF08351F);
  static const Color _green = Color(0xFF6DFC9A);

  Widget _buildBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_bg1, _bg2, _bg3],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Radial glow bottom left
          Positioned(
            bottom: -100,
            left: -100,
            child: _glowOrb(300, const Color(0xFF0E3D22), 0.6),
          ),
          // Radial glow top right
          Positioned(
            top: -100,
            right: -100,
            child: _glowOrb(300, const Color(0xFF0E3D22), 0.4),
          ),

          // Top left rings
          Positioned(
            top: -80,
            left: -80,
            child: CustomPaint(
              size: const Size(200, 200),
              painter: _ThinRingPainter(color: _green),
            ),
          ),
          Positioned(
            top: -20,
            left: -100,
            child: CustomPaint(
              size: const Size(280, 280),
              painter: _ThinRingPainter(color: _green),
            ),
          ),

          // Bottom right rings
          Positioned(
            bottom: -50,
            right: -80,
            child: CustomPaint(
              size: const Size(300, 300),
              painter: _ThinRingPainter(color: _green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowOrb(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(opacity),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _green.withOpacity(0.06),
            blurRadius: size * 0.5,
            spreadRadius: size * 0.04,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Thin Ring Painter
// ═══════════════════════════════════════════════
class _ThinRingPainter extends CustomPainter {
  final Color color;
  _ThinRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(_ThinRingPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════
//  Grid overlay
// ═══════════════════════════════════════════════
class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.04)
      ..strokeWidth = 0.5;
    const step = 38.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter o) => false;
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../shared/colors.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  late AnimationController _animController;
  late AnimationController _sparkleCtrl;
  late AnimationController _floatCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animController.dispose();
    _sparkleCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background
          _buildBackground(),

          // 2. Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      // Logo
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // Main card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            const Center(
                              child: Text(
                                'Forgot Password',
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Center(
                              child: Text(
                                'Enter your email to reset password',
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  color: Color(0xFF6DFC9A),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Email
                            _buildLabel('Email'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _emailController,
                              hint: 'Enter Email',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 32),

                            // Reset Button
                            Consumer<AuthViewModel>(
                              builder: (context, vm, _) {
                                return GestureDetector(
                                  onTap: vm.isLoading
                                      ? null
                                      : () async {
                                          final success =
                                              await vm.resetPassword(
                                            _emailController.text.trim(),
                                          );
                                          if (!mounted) return;
                                          if (success) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Password reset link sent to your email.'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                            Navigator.pop(context);
                                          } else if (vm.errorMessage != null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(vm.errorMessage!),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: AppColors.accentYellow,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.accentYellow
                                              .withValues(alpha: 0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: vm.isLoading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                color: AppColors.textDark,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : const Text(
                                              'Send Reset Link',
                                              style: TextStyle(
                                                fontFamily: 'Lexend',
                                                color: AppColors.textDark,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),

                            // Already have account
                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: RichText(
                                  text: const TextSpan(
                                    text: "Already have another account? ",
                                    style: TextStyle(
                                      fontFamily: 'Lexend',
                                      color: Color(0xFF6DFC9A),
                                      fontSize: 13,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Sign in',
                                        style: TextStyle(
                                          color: AppColors.accentYellow,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
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
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Back button
          SafeArea(
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.arrow_back_ios_new,
                            color: AppColors.textPrimary, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Back',
                          style: TextStyle(
                            fontFamily: 'Lexend',
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Lexend',
        color: Color(0xFF6DFC9A),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: 'Lexend',
        color: Colors.white,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.white.withValues(alpha: 0.4),
          fontSize: 14,
        ),
        filled: true,
        fillColor: AppColors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppColors.white.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppColors.white.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.accentYellow, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          Positioned(
            bottom: -120,
            right: -20,
            child: CustomPaint(
              size: const Size(250, 250),
              painter: _ThinRingPainter(color: _green),
            ),
          ),

          // Left star
          _animatedSparkle(
            top: 250,
            left: 30,
            size: 14,
            delay: 0.5,
          ),

          // Bottom right star
          _animatedSparkle(
            bottom: 200,
            right: 40,
            size: 32,
            delay: 1.0,
          ),

          // Top right cluster
          _animatedSparkle(
            top: 100,
            right: 100,
            size: 55,
            delay: 0.0,
          ),
          _animatedSparkle(
            top: 130,
            right: 40,
            size: 30,
            delay: 0.3,
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

  Widget _animatedSparkle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _floatCtrl,
      builder: (context, child) {
        final floatOffset = sin((_floatCtrl.value * 2 * pi) + delay * 2 * pi) * 10;
        
        return Positioned(
          top: top != null ? top + floatOffset : null,
          bottom: bottom != null ? bottom - floatOffset : null,
          left: left,
          right: right,
          child: AnimatedBuilder(
            animation: _sparkleCtrl,
            builder: (context, child) {
              final scale = 0.8 + 0.2 * sin((_sparkleCtrl.value * 2 * pi) + delay * pi);
              final opacity = 0.5 + 0.5 * sin((_sparkleCtrl.value * 2 * pi) + delay * pi);
              
              return Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: scale,
                  child: _Sparkle(size: size, color: _green),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ThinRingPainter extends CustomPainter {
  final Color color;
  _ThinRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = color.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(_ThinRingPainter o) => o.color != color;
}

class _Sparkle extends StatelessWidget {
  final double size;
  final Color color;
  const _Sparkle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SparklePainter(color),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final Color color;
  _SparklePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final inner = r * 0.22;
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4) - pi / 2;
      final rad = (i % 2 == 0) ? r : inner;
      final x = cx + rad * cos(angle);
      final y = cy + rad * sin(angle);
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
  bool shouldRepaint(_SparklePainter o) => o.color != color;
}

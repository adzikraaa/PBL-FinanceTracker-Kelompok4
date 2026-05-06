import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/auth/welcome_view.dart';
import '../views/home/main_navigation.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  // Float animation
  late AnimationController _floatController;
  late Animation<double> _floatAnim;

  // Glow animation
  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  // Fade in scale
  late AnimationController _fadeInController;
  late Animation<double> _fadeScaleAnim;
  late Animation<double> _fadeOpacityAnim;

  // Text fade
  late AnimationController _textFadeController;
  late Animation<double> _textFadeAnim;

  // Tagline fade
  late AnimationController _taglineFadeController;
  late Animation<double> _taglineFadeAnim;

  // Shimmer
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnim;

  // Ripple 1
  late AnimationController _ripple1Controller;
  late Animation<double> _ripple1Scale;
  late Animation<double> _ripple1Opacity;

  // Ripple 2
  late AnimationController _ripple2Controller;
  late Animation<double> _ripple2Scale;
  late Animation<double> _ripple2Opacity;

  // Sparkles
  late AnimationController _sparkle1Controller;
  late AnimationController _sparkle2Controller;
  late AnimationController _sparkle3Controller;
  late AnimationController _sparkle4Controller;
  late AnimationController _sparkle5Controller;

  // Loading dots
  late AnimationController _dotsController;
  late Animation<double> _dot1Anim;
  late Animation<double> _dot2Anim;
  late Animation<double> _dot3Anim;

  @override
  void initState() {
    super.initState();

    // Float
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1750),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Glow
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Fade in scale
    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeScaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _fadeInController, curve: Curves.elasticOut),
    );
    _fadeOpacityAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeInController, curve: Curves.easeOut),
    );

    // Text fade
    _textFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _textFadeController.forward();
    });
    _textFadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textFadeController, curve: Curves.easeOut),
    );

    // Tagline fade
    _taglineFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _taglineFadeController.forward();
    });
    _taglineFadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _taglineFadeController, curve: Curves.easeOut),
    );

    // Shimmer
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Ripple 1
    _ripple1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _ripple1Scale = Tween<double>(begin: 0.8, end: 2.2).animate(
      CurvedAnimation(parent: _ripple1Controller, curve: Curves.easeOut),
    );
    _ripple1Opacity = Tween<double>(begin: 0.15, end: 0).animate(
      CurvedAnimation(parent: _ripple1Controller, curve: Curves.easeOut),
    );

    // Ripple 2 (delayed)
    _ripple2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _ripple2Controller.repeat();
    });
    _ripple2Scale = Tween<double>(begin: 0.8, end: 2.8).animate(
      CurvedAnimation(parent: _ripple2Controller, curve: Curves.easeOut),
    );
    _ripple2Opacity = Tween<double>(begin: 0.1, end: 0).animate(
      CurvedAnimation(parent: _ripple2Controller, curve: Curves.easeOut),
    );

    // Sparkles
    _sparkle1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _sparkle2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _sparkle2Controller.repeat(reverse: true);
    });
    _sparkle3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3100),
    );
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _sparkle3Controller.repeat(reverse: true);
    });
    _sparkle4Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _sparkle4Controller.repeat(reverse: true);
    });
    _sparkle5Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _sparkle5Controller.repeat(reverse: true);
    });

    // Loading dots
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _dot1Anim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 33),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.3), weight: 33),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 34),
    ]).animate(_dotsController);
    _dot2Anim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 33),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 33),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.3), weight: 34),
    ]).animate(_dotsController);
    _dot3Anim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.3), weight: 33),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 33),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 34),
    ]).animate(_dotsController);
    // Auto-redirect setelah loading selesai
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              user != null ? MainNavigation() : const WelcomeView(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _glowController.dispose();
    _fadeInController.dispose();
    _textFadeController.dispose();
    _taglineFadeController.dispose();
    _shimmerController.dispose();
    _ripple1Controller.dispose();
    _ripple2Controller.dispose();
    _sparkle1Controller.dispose();
    _sparkle2Controller.dispose();
    _sparkle3Controller.dispose();
    _sparkle4Controller.dispose();
    _sparkle5Controller.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  Widget _buildSparkle(AnimationController controller, double size) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        return Opacity(
          opacity: t,
          child: Transform.scale(
            scale: 0.3 + (t * 0.7),
            child: CustomPaint(
              size: Size(size, size),
              painter: _StarPainter(color: const Color(0xFF4ade80)),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: const Color(0xFF030e08),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF030e08),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.4),
              radius: 1.2,
              colors: [
                Color(0xFF0d3d22),
                Color(0xFF071c10),
                Color(0xFF030e08),
              ],
              stops: [0.0, 0.4, 1.0],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Corner decorative circles
              Positioned(
                top: -40,
                right: -40,
                child: _buildCircleBorder(140, 0.12),
              ),
              Positioned(
                top: -20,
                right: -20,
                child: _buildCircleBorder(90, 0.08),
              ),
              Positioned(
                bottom: -50,
                left: -50,
                child: _buildCircleBorder(160, 0.10),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: _buildCircleBorder(100, 0.06),
              ),

              // Ripple 1
              AnimatedBuilder(
                animation: _ripple1Controller,
                builder: (_, __) => Transform.scale(
                  scale: _ripple1Scale.value,
                  child: Opacity(
                    opacity: _ripple1Opacity.value,
                    child: _buildCircleBorder(160, 1.0),
                  ),
                ),
              ),

              // Ripple 2
              AnimatedBuilder(
                animation: _ripple2Controller,
                builder: (_, __) => Transform.scale(
                  scale: _ripple2Scale.value,
                  child: Opacity(
                    opacity: _ripple2Opacity.value,
                    child: _buildCircleBorder(160, 1.0),
                  ),
                ),
              ),

              // Sparkle top-center
              Positioned(
                top: size.height * 0.12,
                left: size.width * 0.35,
                child: _buildSparkle(_sparkle1Controller, 28),
              ),

              // Sparkle top-right large
              Positioned(
                top: size.height * 0.09,
                right: size.width * 0.15,
                child: _buildSparkle(_sparkle2Controller, 20),
              ),

              // Sparkle top-right small
              Positioned(
                top: size.height * 0.14,
                right: size.width * 0.10,
                child: _buildSparkle(_sparkle3Controller, 14),
              ),

              // Sparkle bottom-right
              Positioned(
                bottom: size.height * 0.22,
                right: size.width * 0.08,
                child: _buildSparkle(_sparkle4Controller, 22),
              ),

              // Sparkle left middle
              Positioned(
                top: size.height * 0.52,
                left: size.width * 0.07,
                child: _buildSparkle(_sparkle5Controller, 12),
              ),

              // Main content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _floatController,
                      _fadeInController,
                      _glowController,
                    ]),
                    builder: (_, __) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnim.value),
                        child: FadeTransition(
                          opacity: _fadeOpacityAnim,
                          child: ScaleTransition(
                            scale: _fadeScaleAnim,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF4ade80).withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4ade80).withOpacity(
                                      0.3 + (_glowAnim.value * 0.4),
                                    ),
                                    blurRadius: 20 + (_glowAnim.value * 15),
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18.5),
                                child: Image.asset(
                                  'assets/images/logo.png', // Ganti dengan path logo kamu
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // Brand name
                  FadeTransition(
                    opacity: _textFadeAnim,
                    child: const Text(
                      'BizPrice',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4ade80),
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(
                            color: Color(0xFF4ade80),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tagline
                  FadeTransition(
                    opacity: _taglineFadeAnim,
                    child: const Text(
                      'Ayo manage uangmu agar bisa jadi CEO!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xBFFFFFFF),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Loading section
                  FadeTransition(
                    opacity: _taglineFadeAnim,
                    child: Column(
                      children: [
                        // Shimmer bar
                        SizedBox(
                          width: 120,
                          height: 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: AnimatedBuilder(
                              animation: _shimmerAnim,
                              builder: (_, __) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4ade80).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: ShaderMask(
                                    shaderCallback: (bounds) {
                                      return LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: const [
                                          Colors.transparent,
                                          Color(0xFF4ade80),
                                          Colors.transparent,
                                        ],
                                        stops: [
                                          _shimmerAnim.value - 0.3,
                                          _shimmerAnim.value,
                                          _shimmerAnim.value + 0.3,
                                        ].map((s) => s.clamp(0.0, 1.0)).toList(),
                                      ).createShader(bounds);
                                    },
                                    child: Container(
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Dots
                        AnimatedBuilder(
                          animation: _dotsController,
                          builder: (_, __) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Loading',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.45),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Opacity(
                                  opacity: _dot1Anim.value,
                                  child: const Text(
                                    '.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF4ade80),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Opacity(
                                  opacity: _dot2Anim.value,
                                  child: const Text(
                                    '.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF4ade80),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Opacity(
                                  opacity: _dot3Anim.value,
                                  child: const Text(
                                    '.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF4ade80),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleBorder(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF4ade80).withOpacity(opacity),
          width: 1,
        ),
      ),
    );
  }
}

// Custom painter for star/sparkle shape
class _StarPainter extends CustomPainter {
  final Color color;
  _StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final path = Path();
    // 4-point star
    path.moveTo(cx, 0);
    path.lineTo(cx + cx * 0.15, cy - cy * 0.15);
    path.lineTo(size.width, cy);
    path.lineTo(cx + cx * 0.15, cy + cy * 0.15);
    path.lineTo(cx, size.height);
    path.lineTo(cx - cx * 0.15, cy + cy * 0.15);
    path.lineTo(0, cy);
    path.lineTo(cx - cx * 0.15, cy - cy * 0.15);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) => false;
}
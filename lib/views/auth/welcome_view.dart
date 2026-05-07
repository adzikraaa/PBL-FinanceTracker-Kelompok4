import 'dart:math';
import 'package:flutter/material.dart';

import 'login_view.dart';
import 'register_view.dart';

// ═══════════════════════════════════════════════════════════════
//  WelcomeView — Dark green premium welcome page
//  Colors  : bg gradient #061D12 → #0D2E1E → #08351F
//  Text    : #C6EBD3 (off-white) · #6DFC9A (bright green)
//  Features: Staggered entrance · Sparkle pulse · Floating orbs
//            Rotating glow ring · Shimmer title · Swipe buttons
// ═══════════════════════════════════════════════════════════════

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView>
    with TickerProviderStateMixin {

  // Controllers
  late final AnimationController _entranceCtrl;
  late final AnimationController _sparkleCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _rotateCtrl;
  late final AnimationController _shimmerCtrl;

  // Entrance animations
  late final Animation<double> _masterFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<Offset> _btnSlide;
  late final Animation<double> _titleFade;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _btnFade;

  // Colors
  static const Color _bg1       = Color(0xFF061D12);
  static const Color _bg2       = Color(0xFF0D2E1E);
  static const Color _bg3       = Color(0xFF08351F);
  static const Color _green     = Color(0xFF6DFC9A);
  static const Color _textLight = Color(0xFFC6EBD3);
  static const Color _textMuted = Color(0xFF5A8C6E);
  static const Color _orbColor  = Color(0xFF0E3D22);
  static const Color _btnSignIn = Color(0xFF0C2A18);

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // Staggered entrance
    _masterFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.1, 0.6, curve: Curves.easeOutCubic),
    ));
    _titleFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.1, 0.55, curve: Curves.easeIn),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.3, 0.75, curve: Curves.easeOutCubic),
    ));
    _subtitleFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
    );
    _btnSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
    ));
    _btnFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.55, 0.95, curve: Curves.easeIn),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _entranceCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _sparkleCtrl.dispose();
    _floatCtrl.dispose();
    _rotateCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
            // Background orbs
            ..._buildOrbs(),

            // Rotating glow ring
            _buildGlowRing(),

            // Grid overlay
            Positioned.fill(
              child: CustomPaint(painter: _GridPainter(color: _green)),
            ),

            // Content
            Positioned.fill(
              child: SafeArea(
              child: FadeTransition(
                opacity: _masterFade,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sparkle cluster top-right
                    Padding(
                      padding: const EdgeInsets.only(top: 16, right: 24),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _AnimatedSparkleCluster(
                          controller: _sparkleCtrl,
                          color: _green,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: FadeTransition(
                        opacity: _titleFade,
                        child: SlideTransition(
                          position: _titleSlide,
                          child: _buildTitleBlock(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: FadeTransition(
                        opacity: _subtitleFade,
                        child: SlideTransition(
                          position: _subtitleSlide,
                          child: const Text(
                            'Take control of your business finances and\nreach your goals effortlessly!',
                            style: TextStyle(
                              color: _textMuted,
                              fontSize: 14.5,
                              height: 1.65,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Bottom sparkle
                    _buildBottomSparkle(),

                    const SizedBox(height: 16),

                    // Buttons
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, bottom: 32),
                      child: FadeTransition(
                        opacity: _btnFade,
                        child: SlideTransition(
                          position: _btnSlide,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SwipeButton(
                                label: 'Sign up',
                                backgroundColor: _green,
                                thumbColor: _bg1,
                                labelColor: _bg1,
                                arrowColor: _green,
                                onCompleted: () {
                                  Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const RegisterView()));
                                },
                              ),
                              const SizedBox(height: 14),
                              _SwipeButton(
                                label: 'Sign in',
                                backgroundColor: _btnSignIn,
                                thumbColor: _green,
                                labelColor: _textLight,
                                arrowColor: _bg1,
                                borderColor: const Color(0xFF1A4D2E),
                                onCompleted: () {
                                  Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const LoginView()));
                                },
                              ),
                            ],
                          ),
                        ),
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
    );
  }

  // Title: WELCOME TO + BizPrice Tracker with shimmer
  Widget _buildTitleBlock() {
    return AnimatedBuilder(
      animation: _shimmerCtrl,
      builder: (_, __) {
        final t = _shimmerCtrl.value;
        final stops = [
          (t - 0.3).clamp(0.0, 1.0),
          t.clamp(0.0, 1.0),
          (t + 0.3).clamp(0.0, 1.0),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WELCOME\nTO',
              style: TextStyle(
                color: _textLight,
                fontSize: 54,
                fontWeight: FontWeight.w900,
                height: 1.0,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: const [
                  Color(0xFF39C96E),
                  Color(0xFF6DFC9A),
                  Color(0xFFB2FFCF),
                  Color(0xFF6DFC9A),
                  Color(0xFF39C96E),
                ],
                stops: [0.0, stops[0], stops[1], stops[2], 1.0],
              ).createShader(bounds),
              child: const Text(
                'BizPrice\nTracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  letterSpacing: -1.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Background floating orbs
  List<Widget> _buildOrbs() {
    return [
      AnimatedBuilder(
        animation: _floatCtrl,
        builder: (_, __) {
          final dy = sin(_floatCtrl.value * pi) * 14;
          return Positioned(
            top: 20 + dy,
            right: -55,
            child: _glowOrb(220, _orbColor, 0.9),
          );
        },
      ),
      AnimatedBuilder(
        animation: _floatCtrl,
        builder: (_, __) {
          final dy = cos(_floatCtrl.value * pi) * 10;
          return Positioned(
            top: 60 + dy,
            left: -60,
            child: _glowOrb(170, _orbColor, 0.8),
          );
        },
      ),
      AnimatedBuilder(
        animation: _floatCtrl,
        builder: (_, __) {
          final dy = sin(_floatCtrl.value * pi + 0.8) * 12;
          return Positioned(
            bottom: 160 + dy,
            right: 10,
            child: _glowOrb(90, _orbColor, 0.85),
          );
        },
      ),
      AnimatedBuilder(
        animation: _floatCtrl,
        builder: (_, __) {
          final dy = cos(_floatCtrl.value * pi + 1.2) * 8;
          return Positioned(
            bottom: 260 + dy,
            left: -20,
            child: _glowOrb(75, _orbColor, 0.7),
          );
        },
      ),
    ];
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

  // Rotating glow ring
  Widget _buildGlowRing() {
    return Positioned(
      top: -80,
      right: -80,
      child: AnimatedBuilder(
        animation: _rotateCtrl,
        builder: (_, __) => Transform.rotate(
          angle: _rotateCtrl.value * 2 * pi,
          child: CustomPaint(
            size: const Size(280, 280),
            painter: _RingPainter(color: _green),
          ),
        ),
      ),
    );
  }

  // Bottom right floating sparkle
  Widget _buildBottomSparkle() {
    return AnimatedBuilder(
      animation: _floatCtrl,
      builder: (_, __) {
        final dy = sin(_floatCtrl.value * pi * 1.3) * 8;
        return Padding(
  padding: EdgeInsets.only(right: 42, bottom: (4 + dy).clamp(0.0, 20.0)),
          child: Align(
            alignment: Alignment.centerRight,
            child: AnimatedBuilder(
              animation: _sparkleCtrl,
              builder: (_, __) => Opacity(
                opacity: 0.5 + 0.5 * _sparkleCtrl.value,
                child: Transform.scale(
                  scale: 0.85 + 0.2 * _sparkleCtrl.value,
                  child: _Sparkle(size: 30, color: _green),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════
//  Sparkle cluster widget
// ═══════════════════════════════════════════════
class _AnimatedSparkleCluster extends StatelessWidget {
  final AnimationController controller;
  final Color color;
  const _AnimatedSparkleCluster(
      {required this.controller, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        return SizedBox(
          width: 80,
          height: 72,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: Opacity(
                  opacity: 0.65 + 0.35 * t,
                  child: Transform.scale(
                    scale: 0.88 + 0.16 * t,
                    child: _Sparkle(size: 44, color: color),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Opacity(
                  opacity: 0.45 + 0.35 * (1 - t),
                  child: Transform.scale(
                    scale: 0.82 + 0.16 * (1 - t),
                    child: _Sparkle(size: 28, color: color),
                  ),
                ),
              ),
              Positioned(
                top: 22,
                left: 6,
                child: Opacity(
                  opacity: 0.25 + 0.5 * t,
                  child: _Sparkle(size: 13, color: color),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════
//  4-point sparkle
// ═══════════════════════════════════════════════
class _Sparkle extends StatelessWidget {
  final double size;
  final Color color;
  const _Sparkle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _SparklePainter(color));
}

class _SparklePainter extends CustomPainter {
  final Color color;
  _SparklePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final cx = size.width / 2, cy = size.height / 2;
    final r = size.width / 2, inner = r * 0.22;
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4) - pi / 2;
      final rad = (i % 2 == 0) ? r : inner;
      final x = cx + rad * cos(angle);
      final y = cy + rad * sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklePainter o) => o.color != color;
}

// ═══════════════════════════════════════════════
//  Rotating ring painter
// ═══════════════════════════════════════════════
class _RingPainter extends CustomPainter {
  final Color color;
  _RingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = size.width / 2 - 4;

    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = color.withOpacity(0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    final dashPaint = Paint()
      ..color = color.withOpacity(0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    const dashCount = 24;
    const dashLen = 0.12;
    for (int i = 0; i < dashCount; i++) {
      final start = (2 * pi / dashCount) * i;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r - 12),
        start,
        dashLen,
        false,
        dashPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.color != color;
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

// ═══════════════════════════════════════════════
//  Swipe-to-action button
// ═══════════════════════════════════════════════
class _SwipeButton extends StatefulWidget {
  final String label;
  final Color backgroundColor;
  final Color thumbColor;
  final Color labelColor;
  final Color arrowColor;
  final Color? borderColor;
  final VoidCallback onCompleted;

  const _SwipeButton({
    required this.label,
    required this.backgroundColor,
    required this.thumbColor,
    required this.labelColor,
    required this.arrowColor,
    this.borderColor,
    required this.onCompleted,
  });

  @override
  State<_SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<_SwipeButton>
    with SingleTickerProviderStateMixin {
  double _dragX = 0;
  bool _completed = false;
  late AnimationController _resetCtrl;

  static const double _h     = 58;
  static const double _thumb = 46;
  static const double _pad   = 6;

  @override
  void initState() {
    super.initState();
    _resetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void dispose() {
    _resetCtrl.dispose();
    super.dispose();
  }

  double _maxDrag(double w) => w - _thumb - _pad * 2;

  void _onUpdate(DragUpdateDetails d, double max) {
    if (_completed) return;
    setState(() => _dragX = (_dragX + d.delta.dx).clamp(0, max));
    if (_dragX >= max * 0.90) _complete(max);
  }

  void _complete(double max) {
    if (_completed) return;
    setState(() { _completed = true; _dragX = max; });
    widget.onCompleted();
    Future.delayed(const Duration(milliseconds: 800), _reset);
  }

  void _reset() {
    if (!mounted) return;
    final start = _dragX;
    final anim = Tween<double>(begin: start, end: 0).animate(
      CurvedAnimation(parent: _resetCtrl, curve: Curves.easeOutCubic),
    );
    anim.addListener(() {
      if (mounted) setState(() => _dragX = anim.value);
    });
    _resetCtrl.forward(from: 0).then((_) {
      if (mounted) setState(() { _dragX = 0; _completed = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, box) {
      final w   = box.maxWidth;
      final safeW = w < _thumb ? _thumb.toDouble() : w;
      final max = _maxDrag(safeW);
      final progress = max > 0 ? (_dragX / max).clamp(0.0, 1.0) : 0.0;

      return GestureDetector(
        onHorizontalDragUpdate: (d) => _onUpdate(d, max),
        onHorizontalDragEnd: (_) {
          if (!_completed && _dragX < max * 0.90) _reset();
        },
        child: Container(
          width: w,
          height: _h,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(50),
            border: widget.borderColor != null
                ? Border.all(color: widget.borderColor!, width: 1.5)
                : null,
            boxShadow: widget.borderColor == null
                ? [
                    BoxShadow(
                      color: widget.thumbColor.withOpacity(0.28),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.hardEdge,
            children: [

              // Slide trail
              Positioned(
                left: _pad,
                top: _pad,
                bottom: _pad,
                child: Container(
                  width: (_thumb + _dragX).clamp(_thumb.toDouble(), safeW),
                  decoration: BoxDecoration(
                    color: widget.thumbColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),

              // Label
              Positioned.fill(
                child: Opacity(
                  opacity: (1 - progress * 1.8).clamp(0.0, 1.0),
                  child: Center(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.labelColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),

              // Chevron hints
              if (_dragX < 8)
                Positioned(
                  right: 14,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chevron_right,
                          color: widget.labelColor.withOpacity(0.2), size: 15),
                      Icon(Icons.chevron_right,
                          color: widget.labelColor.withOpacity(0.4), size: 15),
                      Icon(Icons.chevron_right,
                          color: widget.labelColor.withOpacity(0.65), size: 15),
                    ],
                  ),
                ),

              // Thumb circle
              Positioned(
                left: _pad + _dragX,
                top: (_h - _thumb) / 2,
                child: Container(
                  width: _thumb,
                  height: _thumb,
                  decoration: BoxDecoration(
                    color: widget.thumbColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.thumbColor.withOpacity(0.4),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    _completed
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded,
                    color: widget.arrowColor,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
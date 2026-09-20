import 'package:flutter/material.dart';
import 'dart:math';

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

class StarSparkleBackground extends StatefulWidget {
  final int count;
  final double maxY;

  const StarSparkleBackground({super.key, this.count = 20, this.maxY = 1.0});

  @override
  State<StarSparkleBackground> createState() => _StarSparkleBackgroundState();
}

class _StarSparkleBackgroundState extends State<StarSparkleBackground> with SingleTickerProviderStateMixin {
  late AnimationController _sparkleController;
  late List<_Sparkle> _sparkles;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _sparkles = List.generate(
        widget.count,
        (_) => _Sparkle(
              x: _rng.nextDouble(),
              y: _rng.nextDouble() * widget.maxY,
              size: _rng.nextDouble() * 8 + 4,
              opacity: _rng.nextDouble() * 0.7 + 0.3,
              phase: _rng.nextDouble() * 2 * pi,
              speed: _rng.nextDouble() * 1.5 + 0.5,
            ));
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
}

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

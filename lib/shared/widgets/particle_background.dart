import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ParticleBackground extends StatefulWidget {
  final Widget child;

  const ParticleBackground({super.key, required this.child});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    for (int i = 0; i < 40; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 2 + 0.5,
        speedX: (_random.nextDouble() - 0.5) * 0.001,
        speedY: (_random.nextDouble() - 0.5) * 0.001,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppColors.background),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _ParticlePainter(_particles),
              size: Size.infinite,
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _Particle {
  double x, y, size, speedX, speedY;
  _Particle({required this.x, required this.y, required this.size, required this.speedX, required this.speedY});

  void update() {
    x += speedX;
    y += speedY;
    if (x < 0) x = 1; else if (x > 1) x = 0;
    if (y < 0) y = 1; else if (y > 1) y = 0;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  _ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary.withValues(alpha: 0.15);
    for (var p in particles) {
      p.update();
      canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

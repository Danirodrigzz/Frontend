import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

/// Widget que añade orbes de luz animados y difuminados al fondo.
/// Se recomienda usar como base en un Stack.
class AnimatedOrbsBackground extends StatelessWidget {
  const AnimatedOrbsBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Orbe superior izquierda (Cian/Primario)
        Positioned(
          top: -100,
          left: -50,
          child: _AnimatedOrb(
            size: 280,
            color: AppColors.primary.withValues(alpha: 0.15),
            duration: 8.seconds,
            offset: const Offset(30, 20),
          ),
        ),
        
        // Orbe inferior derecha (Índigo)
        Positioned(
          bottom: 100,
          right: -100,
          child: _AnimatedOrb(
            size: 320,
            color: const Color(0xFF6366F1).withValues(alpha: 0.12),
            duration: 10.seconds,
            offset: const Offset(-40, -30),
          ),
        ),
        
        // Orbe central derecha (Púrpura)
        Positioned(
          top: 250,
          right: 50,
          child: _AnimatedOrb(
            size: 180,
            color: const Color(0xFFA855F7).withValues(alpha: 0.1),
            duration: 7.seconds,
            offset: const Offset(-20, 40),
          ),
        ),

        // Orbe extra para dispositivos más pequeños (Esmeralda)
        Positioned(
          bottom: -50,
          left: 100,
          child: _AnimatedOrb(
            size: 200,
            color: const Color(0xFF10B981).withValues(alpha: 0.08),
            duration: 9.seconds,
            offset: const Offset(40, -20),
          ),
        ),
      ],
    );
  }
}

class _AnimatedOrb extends StatelessWidget {
  final double size;
  final Color color;
  final Duration duration;
  final Offset offset;

  const _AnimatedOrb({
    required this.size,
    required this.color,
    required this.duration,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0.4),
            Colors.transparent,
          ],
        ),
      ),
    )
    .animate(onPlay: (controller) => controller.repeat(reverse: true))
    .move(
      begin: Offset.zero,
      end: offset,
      duration: duration,
      curve: Curves.easeInOutSine,
    );
  }
}

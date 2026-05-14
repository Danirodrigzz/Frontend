import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool highlight;
  final VoidCallback? onTap;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 8,
    this.highlight = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: highlight 
                ? AppColors.primary.withValues(alpha: 0.05) 
                : AppColors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: highlight ? AppColors.primary : AppColors.border,
                width: highlight ? 1.5 : 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

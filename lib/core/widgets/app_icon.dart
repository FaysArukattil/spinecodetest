import 'package:flutter/material.dart';

/// Renders the square/rounded app icon with the Plantlets logo on a pure white background.
class AppIcon extends StatelessWidget {
  final double size;
  final double borderRadius;
  final bool withBorder;
  final bool withShadow;

  const AppIcon({
    super.key,
    this.size = 64,
    this.borderRadius = 16,
    this.withBorder = true,
    this.withShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: withBorder
            ? Border.all(color: const Color(0xFFE5E7EB), width: 1)
            : null,
        boxShadow: withShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          'assets/images/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

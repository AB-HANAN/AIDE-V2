import 'package:flutter/material.dart';

class HoldButton extends StatelessWidget {
  const HoldButton({
    super.key,
    required this.label,
    required this.onDown,
    required this.onUp,
    this.size = 86,
    this.icon,
  });

  final String label;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final double size;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return GestureDetector(
      onTapDown: (_) => onDown(),
      onTapUp: (_) => onUp(),
      onTapCancel: onUp,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isLight ? Colors.black.withValues(alpha: 0.08) : const Color(0xFF1E2630),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isLight ? Colors.black.withValues(alpha: 0.15) : Colors.white12,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(
              icon,
              size: 24,
              color: isLight ? Colors.black87 : Colors.white,
            ),
            if (icon != null) const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isLight ? Colors.black87 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
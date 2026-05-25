import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AideShell extends StatelessWidget {
  const AideShell({
    super.key,
    required this.child,
    this.showBack = false,
    this.onBack,
    this.trailing,
  });

  final Widget child;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLightTheme = brightness == Brightness.light;

    return Scaffold(
      body: Container(
        decoration: isLightTheme
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFF0F4F8),
                    const Color(0xFFE8F0F8),
                    const Color(0xFFF0E8F8),
                    const Color(0xFFF8F0E8),
                  ],
                  stops: const [0.0, 0.33, 0.66, 1.0],
                ),
              )
            : const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AideColors.background,
                    AideColors.backgroundSoft,
                    Color(0xFF05070F),
                  ],
                ),
              ),
        child: Stack(
          children: [
            if (!isLightTheme) ...[
              const _Aura(alignment: Alignment(1.12, -0.84), color: Color(0x30EF6A3B), size: 190),
              const _Aura(alignment: Alignment(-1.06, -0.45), color: Color(0x187D6BFF), size: 220),
              const _Aura(alignment: Alignment(0.82, 0.96), color: Color(0x1544E3C1), size: 220),
              Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _GridPainter()))),
            ],
            SafeArea(
              child: Column(
                children: [
                  if (showBack)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: onBack ?? () => Navigator.of(context).maybePop(),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isLightTheme
                                    ? Colors.black.withValues(alpha: 0.08)
                                    : Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isLightTheme
                                      ? Colors.black.withValues(alpha: 0.1)
                                      : Colors.white.withValues(alpha: 0.06),
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: isLightTheme ? const Color(0xDD000000) : Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (trailing != null) trailing!,
                        ],
                      ),
                    ),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AidePanel extends StatelessWidget {
  const AidePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 22,
    this.color,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isLightTheme = brightness == Brightness.light;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isLightTheme
            ? Colors.white.withValues(alpha: 0.9)
            : (color ?? AideColors.card),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isLightTheme
              ? Colors.black.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: isLightTheme
                ? Colors.black.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.28),
            blurRadius: isLightTheme ? 12 : 24,
            offset: Offset(0, isLightTheme ? 4 : 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AideChip extends StatelessWidget {
  const AideChip({super.key, required this.label, this.color = AideColors.primary});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isLightTheme ? color.withValues(alpha: 0.12) : color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: isLightTheme ? 0.35 : 0.26)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class AideSectionTitle extends StatelessWidget {
  const AideSectionTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).brightness == Brightness.light ? Colors.black87 : Colors.white,
      ),
    );
  }
}

class AideTextField extends StatelessWidget {
  const AideTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.hintText,
    this.maxLength,
    this.onChanged,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? hintText;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLength: maxLength,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        counterText: '',
      ),
    );
  }
}

class _Aura extends StatelessWidget {
  const _Aura({required this.alignment, required this.color, required this.size});
  final Alignment alignment;
  final Color color;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [BoxShadow(color: color, blurRadius: 120, spreadRadius: 8)],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.018)..strokeWidth = 1;
    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

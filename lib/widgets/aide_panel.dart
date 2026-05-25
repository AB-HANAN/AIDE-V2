import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AidePanel extends StatelessWidget {
  final Widget child;
  final double radius;
  final Color? color;
  final EdgeInsets? padding;
  final Border? border;

  const AidePanel({
    super.key,
    required this.child,
    this.radius = 16,
    this.color,
    this.padding,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? AideColors.panel,
        borderRadius: BorderRadius.circular(radius),
        border: border,
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }
}

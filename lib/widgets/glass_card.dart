import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),

        // ============================================================
        // SEMICLASSICAL NAVY / ROSE CARD
        // ============================================================

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xE8243154),
            Color(0xE61D2948),
            Color(0xE62A203D),
          ],
          stops: [
            0.0,
            0.55,
            1.0,
          ],
        ),

        // ============================================================
        // SOFT ROSE BORDER
        // ============================================================

        border: Border.all(
          color: const Color(0xFFFFB4C8),
          width: 1.1,
        ),

        // ============================================================
        // DEPTH
        // ============================================================

        boxShadow: [
          BoxShadow(
            color: const Color(0xFF050A18).withOpacity(.30),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFFFF7FA8).withOpacity(.07),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}

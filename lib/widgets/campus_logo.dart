import 'package:flutter/material.dart';

class CampusLogo extends StatelessWidget {
  final double size;

  const CampusLogo({
    super.key,
    this.size = 65,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * .3),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8C70FF),
            Color(0xFFB86EFF),
            Color(0xFFFF72B6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C7BFF).withOpacity(.28),
            blurRadius: 28,
          ),
        ],
      ),
      child: Icon(
        Icons.all_inclusive_rounded,
        color: Colors.white,
        size: size * .58,
      ),
    );
  }
}

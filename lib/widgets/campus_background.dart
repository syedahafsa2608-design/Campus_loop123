import 'dart:ui';
import 'package:flutter/material.dart';

class CampusBackground extends StatelessWidget {
  final Widget child;

  const CampusBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ============================================================
        // MAIN BACKGROUND
        // ============================================================

        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF101A35),
                Color(0xFF18284A),
                Color(0xFF251D3D),
                Color(0xFF351E36),
              ],
              stops: [
                0.0,
                0.38,
                0.72,
                1.0,
              ],
            ),
          ),
        ),

        // ============================================================
        // PINK LIGHT
        // ============================================================

        Positioned(
          top: -100,
          left: -80,
          child: _SoftLight(
            size: 330,
            color: Color(0xFFFF7FA8),
          ),
        ),

        // ============================================================
        // BLUE LIGHT
        // ============================================================

        Positioned(
          top: 170,
          right: -120,
          child: _SoftLight(
            size: 360,
            color: Color(0xFF668CFF),
          ),
        ),

        // ============================================================
        // ROSE LIGHT
        // ============================================================

        Positioned(
          bottom: 100,
          left: -120,
          child: _SoftLight(
            size: 320,
            color: Color(0xFFD96B91),
          ),
        ),

        // ============================================================
        // SOFT GOLD
        // ============================================================

        Positioned(
          bottom: -100,
          right: -100,
          child: _SoftLight(
            size: 280,
            color: Color(0xFFD7A86E),
          ),
        ),

        // ============================================================
        // DECORATIVE CAMPUS
        // ============================================================

        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: CustomPaint(
              size: const Size(
                double.infinity,
                215,
              ),
              painter: _CampusPainter(),
            ),
          ),
        ),

        // ============================================================
        // FLOATING DECORATION 1
        // ============================================================

        Positioned(
          top: 105,
          right: 25,
          child: _DecorativeGlass(
            size: 68,
            icon: Icons.menu_book_rounded,
            rotation: 0.12,
          ),
        ),

        // ============================================================
        // FLOATING DECORATION 2
        // ============================================================

        Positioned(
          top: 355,
          left: 20,
          child: _DecorativeGlass(
            size: 52,
            icon: Icons.school_rounded,
            rotation: -0.16,
          ),
        ),

        // ============================================================
        // FLOATING DECORATION 3
        // ============================================================

        Positioned(
          bottom: 155,
          right: 24,
          child: _DecorativeGlass(
            size: 58,
            icon: Icons.people_alt_rounded,
            rotation: 0.10,
          ),
        ),

        // ============================================================
        // ACTUAL SCREEN
        // ============================================================

        child,
      ],
    );
  }
}

// ====================================================================
// SOFT LIGHT
// ====================================================================

class _SoftLight extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftLight({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: 55,
        sigmaY: 55,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.18),
        ),
      ),
    );
  }
}

// ====================================================================
// DECORATIVE GLASS OBJECT
// ====================================================================

class _DecorativeGlass extends StatelessWidget {
  final double size;
  final IconData icon;
  final double rotation;

  const _DecorativeGlass({
    required this.size,
    required this.icon,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF172541).withOpacity(0.82),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFB5CA).withOpacity(0.28),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF7FA8).withOpacity(0.12),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFFFFB6C9),
          size: size * 0.38,
        ),
      ),
    );
  }
}

// ====================================================================
// CAMPUS PAINTING
// ====================================================================

class _CampusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // --------------------------------------------------------------
    // GROUND
    // --------------------------------------------------------------

    final groundPaint = Paint()
      ..color = const Color(0xFF080F22).withOpacity(0.72);

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        size.height * 0.70,
        size.width,
        size.height * 0.30,
      ),
      groundPaint,
    );

    // --------------------------------------------------------------
    // BUILDING
    // --------------------------------------------------------------

    final buildingPaint = Paint()
      ..color = const Color(0xFF0B1428).withOpacity(0.90);

    final building = Rect.fromLTWH(
      size.width * 0.23,
      size.height * 0.29,
      size.width * 0.54,
      size.height * 0.48,
    );

    canvas.drawRect(
      building,
      buildingPaint,
    );

    // --------------------------------------------------------------
    // ROOF
    // --------------------------------------------------------------

    final roof = Path()
      ..moveTo(
        size.width * 0.17,
        size.height * 0.29,
      )
      ..lineTo(
        size.width * 0.50,
        size.height * 0.06,
      )
      ..lineTo(
        size.width * 0.83,
        size.height * 0.29,
      )
      ..close();

    canvas.drawPath(
      roof,
      buildingPaint,
    );

    // --------------------------------------------------------------
    // ROOF HIGHLIGHT
    // --------------------------------------------------------------

    final roofLine = Paint()
      ..color = const Color(0xFFFFA9C0).withOpacity(0.25)
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(
        size.width * 0.17,
        size.height * 0.29,
      ),
      Offset(
        size.width * 0.50,
        size.height * 0.06,
      ),
      roofLine,
    );

    canvas.drawLine(
      Offset(
        size.width * 0.50,
        size.height * 0.06,
      ),
      Offset(
        size.width * 0.83,
        size.height * 0.29,
      ),
      roofLine,
    );

    // --------------------------------------------------------------
    // ENTRANCE
    // --------------------------------------------------------------

    final entrancePaint = Paint()
      ..color = const Color(0xFF050B19).withOpacity(0.95);

    final entrance = Rect.fromLTWH(
      size.width * 0.43,
      size.height * 0.52,
      size.width * 0.14,
      size.height * 0.25,
    );

    canvas.drawRect(
      entrance,
      entrancePaint,
    );

    // --------------------------------------------------------------
    // WINDOWS
    // --------------------------------------------------------------

    final windowPaint = Paint()
      ..color = const Color(0xFFFFB56D).withOpacity(0.30);

    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < 5; col++) {
        final x = size.width * 0.285 + col * size.width * 0.09;

        final y = size.height * 0.38 + row * size.height * 0.13;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              x,
              y,
              size.width * 0.045,
              size.height * 0.065,
            ),
            const Radius.circular(4),
          ),
          windowPaint,
        );
      }
    }

    // --------------------------------------------------------------
    // PATHWAY
    // --------------------------------------------------------------

    final pathPaint = Paint()
      ..color = const Color(0xFFFFB48B).withOpacity(0.18);

    final pathway = Path()
      ..moveTo(
        size.width * 0.40,
        size.height,
      )
      ..lineTo(
        size.width * 0.46,
        size.height * 0.72,
      )
      ..lineTo(
        size.width * 0.54,
        size.height * 0.72,
      )
      ..lineTo(
        size.width * 0.60,
        size.height,
      )
      ..close();

    canvas.drawPath(
      pathway,
      pathPaint,
    );

    // --------------------------------------------------------------
    // TREES
    // --------------------------------------------------------------

    final treePaint = Paint()
      ..color = const Color(0xFF496C72).withOpacity(0.55);

    _drawTree(
      canvas,
      Offset(
        size.width * 0.12,
        size.height * 0.68,
      ),
      treePaint,
    );

    _drawTree(
      canvas,
      Offset(
        size.width * 0.88,
        size.height * 0.68,
      ),
      treePaint,
    );

    _drawTree(
      canvas,
      Offset(
        size.width * 0.055,
        size.height * 0.76,
      ),
      treePaint,
    );

    _drawTree(
      canvas,
      Offset(
        size.width * 0.945,
        size.height * 0.76,
      ),
      treePaint,
    );
  }

  // ==================================================================
  // TREE
  // ==================================================================

  void _drawTree(
    Canvas canvas,
    Offset position,
    Paint paint,
  ) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF8B6259).withOpacity(0.45);

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(
          position.dx,
          position.dy + 18,
        ),
        width: 7,
        height: 36,
      ),
      trunkPaint,
    );

    canvas.drawCircle(
      Offset(
        position.dx,
        position.dy - 5,
      ),
      28,
      paint,
    );

    canvas.drawCircle(
      Offset(
        position.dx - 18,
        position.dy + 5,
      ),
      20,
      paint,
    );

    canvas.drawCircle(
      Offset(
        position.dx + 18,
        position.dy + 5,
      ),
      20,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

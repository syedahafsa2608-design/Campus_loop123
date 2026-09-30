import 'dart:ui';

import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ============================================================
          // PINK + LAVENDER + BLUE BACKGROUND
          // ============================================================

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFC4DE),
                  Color(0xFFE8D7FA),
                  Color(0xFFC9DDFF),
                  Color(0xFF91C8FF),
                ],
              ),
            ),
          ),

          // Pink glow
          Positioned(
            top: -100,
            left: -100,
            child: _GlowOrb(
              size: 300,
              color: const Color(0xFFFF55A5),
            ),
          ),

          // Purple glow
          Positioned(
            top: 220,
            right: -110,
            child: _GlowOrb(
              size: 290,
              color: const Color(0xFF8870F0),
            ),
          ),

          // Blue glow
          Positioned(
            bottom: -110,
            left: -90,
            child: _GlowOrb(
              size: 320,
              color: const Color(0xFF4E9CF5),
            ),
          ),

          // Small pink glow
          Positioned(
            bottom: 180,
            right: -80,
            child: _GlowOrb(
              size: 210,
              color: const Color(0xFFFF7BB8),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 18,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // ======================================================
                  // LOGO
                  // ======================================================

                  Row(
                    children: [
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(17),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF5FA8),
                              Color(0xFF7563E8),
                              Color(0xFF4D99F2),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF806FE6).withOpacity(.25),
                              blurRadius: 22,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.all_inclusive_rounded,
                          color: Colors.white,
                          size: 31,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'CampusLoop',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF29256B),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ======================================================
                  // CAMPUS VISUAL
                  // ======================================================

                  Container(
                    height: 275,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF9FD8FF),
                          Color(0xFFDCCBFA),
                          Color(0xFFFFCBE3),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(.75),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF665BC8).withOpacity(.14),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Stack(
                        children: [
                          // ------------------------------------------------
                          // SUN
                          // ------------------------------------------------

                          Positioned(
                            top: 24,
                            right: 28,
                            child: Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFFD76E),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD76E)
                                        .withOpacity(.55),
                                    blurRadius: 35,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ------------------------------------------------
                          // CLOUDS
                          // ------------------------------------------------

                          const Positioned(
                            top: 55,
                            left: 25,
                            child: _Cloud(),
                          ),

                          const Positioned(
                            top: 105,
                            right: 115,
                            child: _Cloud(
                              scale: .7,
                            ),
                          ),

                          // ------------------------------------------------
                          // COLLEGE
                          // ------------------------------------------------

                          const Positioned(
                            left: 38,
                            right: 38,
                            top: 80,
                            child: _CollegeBuilding(),
                          ),

                          // ------------------------------------------------
                          // GROUND
                          // ------------------------------------------------

                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 55,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF9BDDB8),
                                    Color(0xFFD4F0D9),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // ------------------------------------------------
                          // BOOK
                          // ------------------------------------------------

                          const Positioned(
                            top: 25,
                            left: 18,
                            child: _FloatingIcon(
                              icon: Icons.menu_book_rounded,
                              color: Color(0xFF7161E7),
                            ),
                          ),

                          // ------------------------------------------------
                          // LAPTOP
                          // ------------------------------------------------

                          const Positioned(
                            right: 18,
                            bottom: 65,
                            child: _FloatingIcon(
                              icon: Icons.laptop_mac_rounded,
                              color: Color(0xFF3E91EA),
                            ),
                          ),

                          // ------------------------------------------------
                          // SHOPPING
                          // ------------------------------------------------

                          const Positioned(
                            left: 25,
                            bottom: 62,
                            child: _FloatingIcon(
                              icon: Icons.shopping_bag_rounded,
                              color: Color(0xFFFF5FA8),
                            ),
                          ),

                          // ------------------------------------------------
                          // TRAVEL
                          // ------------------------------------------------

                          const Positioned(
                            right: 75,
                            top: 45,
                            child: _FloatingIcon(
                              icon: Icons.directions_car_rounded,
                              color: Color(0xFF42A878),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ======================================================
                  // MAIN TEXT
                  // ======================================================

                  const Text(
                    'Everything you need,\non campus.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF29256B),
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'CampusLoop connects students with the people, '
                    'things and resources around them.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.5,
                      height: 1.5,
                      color: Color(0xFF5E5A86),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Buy & sell • Find books • Share rides • Connect',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7565B5),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ======================================================
                  // GET STARTED BUTTON
                  // ======================================================

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF5FA8),
                            Color(0xFF8867E9),
                            Color(0xFF4D99F2),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7867E0).withOpacity(.28),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Let's Get Started",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ======================================================
                  // SIGN IN
                  // ======================================================

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5E5A7A),
                        ),
                        children: [
                          TextSpan(
                            text: 'Already have an account? ',
                          ),
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF6253CF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// COLLEGE BUILDING
// ======================================================================

class _CollegeBuilding extends StatelessWidget {
  const _CollegeBuilding();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.78),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF665A9A).withOpacity(.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Roof
          Container(
            height: 20,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF5FA8),
                  Color(0xFF8068E8),
                  Color(0xFF589CF0),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'CAMPUS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
              color: Color(0xFF45435B),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Window(),
                _Window(),
                Container(
                  width: 38,
                  height: 70,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF7868D5),
                        Color(0xFF9B82E8),
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                ),
                _Window(),
                _Window(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Window extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFF98D9FF),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
    );
  }
}

// ======================================================================
// FLOATING ICON
// ======================================================================

class _FloatingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _FloatingIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.48),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(.75),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(.20),
                blurRadius: 18,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: color,
            size: 27,
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// CLOUD
// ======================================================================

class _Cloud extends StatelessWidget {
  final double scale;

  const _Cloud({
    this.scale = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 75,
        height: 25,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.70),
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}

// ======================================================================
// GLOW ORB
// ======================================================================

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: 45,
        sigmaY: 45,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(.18),
        ),
      ),
    );
  }
}

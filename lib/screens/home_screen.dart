import 'dart:math' as math;
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/campus_logo.dart';
import 'books_screen.dart';
import 'buy_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'sell_screen.dart';
import 'travel_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Controls pulse + rotation animations.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final name = user?.displayName?.isNotEmpty == true
        ? user!.displayName!.split(' ').first
        : 'there';

    return Scaffold(
      backgroundColor: const Color(0xFF0D1716),
      body: Stack(
        children: [
          // BACKGROUND GLOWS
          _Glow(
            top: -100,
            left: -100,
            size: 300,
            color: const Color(0xFF176B68),
          ),

          _Glow(
            top: 280,
            right: -130,
            size: 320,
            color: const Color(0xFF315D46),
          ),

          _Glow(
            bottom: -120,
            left: -80,
            size: 300,
            color: const Color(0xFF76533C),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOP BAR
                  Row(
                    children: [
                      const CampusLogo(size: 50),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'CampusLoop',
                          style: TextStyle(
                            color: Color(0xFFE4ECE8),
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _TopButton(
                        icon: Icons.notifications_none_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 9),
                      _TopButton(
                        icon: Icons.person_outline_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),

                  // WELCOME
                  Text(
                    'Hey, $name',
                    style: const TextStyle(
                      color: Color(0xFF9EB1A7),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Your campus,\nconnected.',
                    style: TextStyle(
                      color: Color(0xFFEAF1ED),
                      fontSize: 35,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),

                  const SizedBox(height: 13),

                  const Text(
                    'Find people, things and opportunities\naround your campus.',
                    style: TextStyle(
                      color: Color(0xFF899C93),
                      fontSize: 14.5,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 26),

                  // PULSING FEATURE
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final pulse = 1 +
                          (math.sin(_animationController.value * math.pi * 2) *
                              0.012);

                      return Transform.scale(
                        scale: pulse,
                        child: child,
                      );
                    },
                    child: _MainGlassCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TravelScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Explore CampusLoop',
                    style: TextStyle(
                      color: Color(0xFFE0E9E4),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // SELL
                  _FeatureCard(
                    icon: Icons.sell_rounded,
                    title: 'Sell Something',
                    description:
                        'Sell things you no longer need to other students.',
                    accent: const Color(0xFFC49A72),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SellScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // BUY
                  _FeatureCard(
                    icon: Icons.shopping_bag_rounded,
                    title: 'Buy Something',
                    description:
                        'Discover useful and affordable items from students.',
                    accent: const Color(0xFF5FA9A1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BuyScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // BOOKS
                  _FeatureCard(
                    icon: Icons.menu_book_rounded,
                    title: 'Books',
                    description:
                        'Buy, sell and find textbooks around your campus.',
                    accent: const Color(0xFF8EA879),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BooksScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 22),

                  // ROTATING DECORATION
                  Center(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _animationController.value * math.pi * 2,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF17302C).withOpacity(.75),
                          border: Border.all(
                            color: const Color(0xFF6F8F7A).withOpacity(.20),
                          ),
                        ),
                        child: const Icon(
                          Icons.all_inclusive_rounded,
                          color: Color(0xFF9EBBAA),
                          size: 25,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Center(
                    child: Text(
                      'Everything you need, right on campus.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF71847B),
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// MAIN GLASS CARD
// ================================================================

class _MainGlassCard extends StatelessWidget {
  final VoidCallback onTap;

  const _MainGlassCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF176B68),
                    Color(0xFF4D8270),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF176B68).withOpacity(.35),
                    blurRadius: 22,
                  ),
                ],
              ),
              child: const Icon(
                Icons.directions_car_filled_rounded,
                color: Color(0xFFE9F2ED),
                size: 29,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Travel with a Friend',
                    style: TextStyle(
                      color: Color(0xFFE6EEE9),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Find students going your way and share the journey.',
                    style: TextStyle(
                      color: Color(0xFF8EA198),
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF718A80),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// FEATURE CARD
// ================================================================

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accent;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _GlassContainer(
        padding: const EdgeInsets.all(17),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                color: accent.withOpacity(.14),
                border: Border.all(
                  color: accent.withOpacity(.25),
                ),
              ),
              child: Icon(
                icon,
                color: accent,
                size: 25,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFE1EAE5),
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF7F9289),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF60766D),
              size: 13,
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// GLASS CONTAINER
// ================================================================

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _GlassContainer({
    required this.child,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xFF172522).withOpacity(.72),
            border: Border.all(
              color: const Color(0xFF8AA69B).withOpacity(.16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.22),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ================================================================
// TOP BUTTON
// ================================================================

class _TopButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFF1B2C29).withOpacity(.70),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFF8AA69B).withOpacity(.16),
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFA5B6AF),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// BACKGROUND GLOW
// ================================================================

class _Glow extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final Color color;

  const _Glow({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: 70,
          sigmaY: 70,
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(.18),
          ),
        ),
      ),
    );
  }
}

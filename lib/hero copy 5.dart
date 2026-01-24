import 'dart:io';
import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:fullscreen_window/fullscreen_window.dart';
import 'package:google_fonts/google_fonts.dart';

// Main App Entry Point
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Start with splash screen
    );
  }
}

// Splash Screen with Logo Animation
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _smokeController;
  late AnimationController _buttonController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoRotateAnimation;

  late Animation<double> _smokeFadeAnimation;
  late Animation<double> _smokeScaleAnimation;
  late Animation<double> _smokeBlurAnimation;

  late Animation<double> _buttonFadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;

  bool _startSmoke = false;

  @override
  void initState() {
    super.initState();

    // Logo Animation Controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _logoRotateAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Button Animation Controller
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeIn,
      ),
    );

    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.easeOut,
      ),
    );

    // Smoke Animation Controller
    _smokeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _smokeFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _smokeController,
        curve: Curves.easeInOut,
      ),
    );

    _smokeScaleAnimation = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(
        parent: _smokeController,
        curve: Curves.easeOut,
      ),
    );

    _smokeBlurAnimation = Tween<double>(begin: 0.0, end: 30.0).animate(
      CurvedAnimation(
        parent: _smokeController,
        curve: Curves.easeIn,
      ),
    );

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _buttonController.forward();
      }
    });

    _smokeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Navigate to HeroPage with fade transition
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HeroPage(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _buttonController.dispose();
    _smokeController.dispose();
    super.dispose();
  }

  void _onExploreMore() {
    setState(() {
      _startSmoke = true;
    });
    _smokeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // White Background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
          ),

          // Splash Content with Smoke Effect
          AnimatedBuilder(
            animation: _smokeController,
            builder: (context, child) {
              return Opacity(
                opacity: _startSmoke ? _smokeFadeAnimation.value : 1.0,
                child: Transform.scale(
                  scale: _startSmoke ? _smokeScaleAnimation.value : 1.0,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: _startSmoke
                          ? Colors.white.withOpacity(
                              1 - _smokeBlurAnimation.value / 30,
                            )
                          : Colors.white,
                    ),
                    child: child,
                  ),
                ),
              );
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Animated Logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoFadeAnimation.value,
                        child: Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Transform.rotate(
                            angle: _logoRotateAnimation.value,
                            child: Container(
                              constraints: const BoxConstraints(
                                maxWidth: 400,
                                maxHeight: 400,
                              ),
                              padding: const EdgeInsets.all(40),
                              child: Image.asset(
                                'assets/images/NASTURE VISTA MASTER LOGO - 01 - REVISED.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const Spacer(),

                  // Explore More Button
                  SlideTransition(
                    position: _buttonSlideAnimation,
                    child: FadeTransition(
                      opacity: _buttonFadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 80),
                        child: ElevatedButton(
                          onPressed: _onExploreMore,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                            shadowColor:
                                const Color(0xFF2E7D32).withOpacity(0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'EXPLORE MORE',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
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

// Hero Page with Premium Design (BLUR FIXED)
class HeroPage extends StatefulWidget {
  const HeroPage({super.key});

  @override
  State<HeroPage> createState() => _HeroPageState();
}

class _HeroPageState extends State<HeroPage> with TickerProviderStateMixin {
  final Map<String, String> routes = {
    'location': '/location',
    'views': '/views',
    'plans': '/plans',
    'gallery': '/gallery',
    'walkthrough': '/walkthrough',
    'amenities': '/amenities',
  };

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _buttonController;
  late List<Animation<double>> _buttonAnimations;
  late AnimationController _sunRotationController; // For rotating sun rays

  @override
  void initState() {
    super.initState();

    // Enable fullscreen automatically
    FullScreenWindow.setFullScreen(true);

    // Fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Sun Rotation Animation (Continuous)
    _sunRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 35), // Slow continuous rotation
    )..repeat();

    // Staggered animation for buttons
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _buttonAnimations = List.generate(7, (index) {
      final start = index * 0.1;
      final end = start + 0.4;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _buttonController,
          curve: Interval(start, end, curve: Curves.easeOutBack),
        ),
      );
    });

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _buttonController.dispose();
    _sunRotationController.dispose();
    super.dispose();
  }

  bool _isRightAligned = false;
  bool _isContentVisible = true; // For Fade In/Out
  Duration _layoutDuration = const Duration(milliseconds: 1000); // Dynamic duration for flip

  void _handleFlip() {
    setState(() {
      _isContentVisible = false; // Start Fade Out
      // We set duration to zero so the layout change happens instantly *while hidden*
      _layoutDuration = Duration.zero;
    });

    // Wait for Fade Out to finish (400ms)
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _isRightAligned = !_isRightAligned; // Snap to new side
      });

      // Small delay to ensure frame updates before fading back in
      Future.delayed(const Duration(milliseconds: 50), () {
        if (!mounted) return;
        setState(() {
          _layoutDuration = const Duration(milliseconds: 1000); // Restore smooth duration for other moves
          _isContentVisible = true; // Fade In
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// 1. ✅ STATIC SHARP BACKGROUND (NO BLUR EVER)
          Positioned.fill(
            child: Image.asset(
              'assets/build/Entry Gate Cam.jpg',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high, // Extra sharpness
            ),
          ),

          /// 2. Dark Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                  stops: const [0.0, 0.2, 0.6, 1.0],
                ),
              ),
            ),
          ),

          /// 5. Custom "Sun" Navigation Buttons (Vertical Left or Right)
          AnimatedPositioned(
            duration: _layoutDuration, // Dynamic Duration
            curve: Curves.easeInOutCubicEmphasized,
            top: 0,
            bottom: 0,
            left: _isRightAligned ? null : 40,
            right: _isRightAligned ? 40 : null,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: _isContentVisible ? 1.0 : 0.0,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildSunButton(Icons.home_rounded, 'Home', () => Navigator.pop(context), 0),
                      const SizedBox(height: 15),
                      buildSunButton(Icons.location_on_rounded, 'Location', () => Navigator.pushNamed(context, '/location'), 1),
                      const SizedBox(height: 15),
                      buildSunButton(Icons.map_rounded, 'Plans', () => Navigator.pushNamed(context, '/plans'), 2),
                      const SizedBox(height: 15),
                      buildSunButton(Icons.photo_library_rounded, 'Gallery', () => Navigator.pushNamed(context, '/gallery'), 3),
                      const SizedBox(height: 15),
                      buildSunButton(Icons.videocam_rounded, 'TOUR', () => Navigator.pushNamed(context, '/walkthrough'), 4),
                      const SizedBox(height: 15),
                      buildSunButton(Icons.spa_rounded, 'Amenities', () => Navigator.pushNamed(context, '/amenities'), 5),
                      const SizedBox(height: 15),
                      // Flip Button (Triggers Fade Flip)
                      buildSunButton(
                        Icons.swap_horiz_rounded,
                        _isRightAligned ? 'Left' : 'Right',
                        _handleFlip, // Use the new handler
                        6
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSunButton(IconData icon, String text, VoidCallback onTap, int index) {
    return AnimatedBuilder(
      animation: _buttonAnimations[index],
      builder: (context, child) {
        double slide = 50 * (1.0 - _buttonAnimations[index].value);
        return Transform.translate(
          offset: Offset(_isRightAligned ? slide : -slide, 0),
          child: Opacity(
            opacity: _buttonAnimations[index].value,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onTap,
                child: SizedBox(
                  width: 100, // Slightly larger for better rays
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 1. Rotating Wavy Rays Background (Real Sun Effect)
                      AnimatedBuilder(
                        animation: _sunRotationController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _sunRotationController.value * 2 * 3.14159,
                            child: CustomPaint(
                              size: const Size(100, 100),
                              painter: RealSunRaysPainter(),
                            ),
                          );
                        },
                      ),

                      // 2. Static Sun Body (Glowing Center)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [
                              Color(0xFFFFF176), // Light Yellow core
                              Color(0xFFFFD54F), // Amber
                              Color(0xFFFF6F00), // Deep Orange
                            ],
                            stops: [0.2, 0.6, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6D00).withOpacity(0.6),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: const Color(0xFFFFAB00).withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 5,
                            )
                          ],
                          border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, color: Colors.brown[900], size: 20), // Dark icon for contrast on bright sun
                            Text(
                              text.toUpperCase(),
                              style: GoogleFonts.montserrat(
                                fontSize: 6.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.brown[900]
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Realistic Wavy Sun Rays
class RealSunRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double radius = size.width / 2;
    final double innerRadius = radius * 0.55;

    // Vibrant Fire Gradient for Rays
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFFFCA28), // Amber Accent
          Color(0xFFFF8F00), // Amber Dark
          Color(0xFFD84315), // Deep Red-Orange at tips
        ],
        stops: [0.4, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.save();
    canvas.translate(cx, cy);

    // Draw wavy flames
    int rayCount = 16; // 16 rays for "Surya" look
    double angleStep = (2 * 3.14159) / rayCount;

    for (int i = 0; i < rayCount; i++) {
      Path path = Path();

      // We draw one ray pointing upwards (negative Y), then rotate
      // Start at inner circle
      path.moveTo(0, -innerRadius);

      // Control points for curvy wave "S" shape
      // Left curve going out
      path.quadraticBezierTo(
        -radius * 0.25, -radius * 0.75, // Control point
        0, -radius // Tip point
      );

      // Right curve coming back
      path.quadraticBezierTo(
        radius * 0.25, -radius * 0.75, // Control point
        0, -innerRadius // Back to base
      );

      path.close();

      canvas.drawPath(path, paint);
      canvas.rotate(angleStep);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

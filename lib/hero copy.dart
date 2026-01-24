import 'dart:io';
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

// Hero Page (Your existing code)
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

  bool isFullscreen = false;

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _buttonController;
  late List<Animation<double>> _buttonAnimations;

  @override
  void initState() {
    super.initState();

    // Fade animation for background and logos
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Staggered animation for buttons
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Create staggered animations for each button
    _buttonAnimations = List.generate(7, (index) {
      final start = index * 0.1;
      final end = start + 0.4;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _buttonController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  /// Toggle fullscreen mode
  void _toggleFullscreen() async {
    isFullscreen = !isFullscreen;
    await FullScreenWindow.setFullScreen(isFullscreen);
    setState(() {});
  }

  /// Build main menu button (for bottom row)
  Widget buildButton(IconData icon, String text, VoidCallback onTap, int index) {
    return AnimatedBuilder(
      animation: _buttonAnimations[index],
      builder: (context, child) {
        return Opacity(
          opacity: _buttonAnimations[index].value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _buttonAnimations[index].value)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.white.withOpacity(0.8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white.withOpacity(0.8)),
                        ),
                        child: Center(
                          child: Icon(icon, size: 16, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        text.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.2,
                          fontSize: 12,
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

  /// Build round icon button (only for fullscreen)
  Widget buildRoundIconButton(IconData icon, VoidCallback onTap, int index) {
    return AnimatedBuilder(
      animation: _buttonAnimations[index],
      builder: (context, child) {
        return Opacity(
          opacity: _buttonAnimations[index].value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _buttonAnimations[index].value)),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(icon, color: Colors.white, size: 26),
                onPressed: onTap,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          /// Background image with fade in
          FadeTransition(
            opacity: _fadeAnimation,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Image.asset(
                'assets/images/Aerial View 02.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// Dark overlay
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          /// Top-left branding
          Positioned(
            top: 10,
            left: 40,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                width: 180,
                height: 110,
                child: Image.asset('assets/images/Envy_Logo.png'),
              ),
            ),
          ),

          /// Top-right badge
          Positioned(
            top: 10,
            right: 40,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 90,
                    child: Image.asset('assets/images/bldg__1.png'),
                  ),
                  const SizedBox(width: 2),
                  SizedBox(
                    width: 120,
                    height: 90,
                    child: Image.asset('assets/images/bldg__2.png'),
                  ),
                ],
              ),
            ),
          ),

          /// Bottom menu buttons in a row (center horizontally)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildButton(Icons.location_on, 'LOCATION',
                        () => Navigator.pushNamed(context, routes['location']!), 0),
                    // buildButton(Icons.remove_red_eye, 'VIEWS',
                    //     () => Navigator.pushNamed(context, routes['views']!), 1),
                    buildButton(Icons.map, 'PLANS',
                        () => Navigator.pushNamed(context, routes['plans']!), 2),
                    buildButton(Icons.photo, 'GALLERY',
                        () => Navigator.pushNamed(context, routes['gallery']!), 3),
                    buildButton(Icons.video_camera_back, 'WALKTHROUGH',
                        () => Navigator.pushNamed(context, routes['walkthrough']!), 4),
                    // buildButton(Icons.apartment, 'AMENITIES',
                    //     () => Navigator.pushNamed(context, routes['amenities']!), 5),
                    // Fullscreen button as last menu item
                    buildRoundIconButton(
                      isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      _toggleFullscreen,
                      6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

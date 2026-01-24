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


// Hero Page with Premium Design
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
  late AnimationController _bgController; // For Ken Burns effect
  late Animation<double> _bgScaleAnimation;
  late AnimationController _buttonController;
  late List<Animation<double>> _buttonAnimations;

  @override
  void initState() {
    super.initState();

    // Enable fullscreen automatically when page loads
    FullScreenWindow.setFullScreen(true);

    // Fade animation for specific elements
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // Background Ken Burns Effect (Slow Zoom)
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // Slow movement
    )..repeat(reverse: true);
    
    _bgScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOutSine),
    );

    // Staggered animation for buttons
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Create staggered animations for each button (6 buttons now: Home, Location, Plans, Gallery, Walkthrough, Flip)
    _buttonAnimations = List.generate(6, (index) {
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
    _bgController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  bool _isRightAligned = false; // State for layout side

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// 1. Ken Burns Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bgScaleAnimation.value,
                  child: Image.asset(
                    'assets/images/Aerial View 02.jpg',
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),

          /// 2. Texturized Dark Overlay (Vignette)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3), // Top shadow
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.5), // Bottom shade
                  ],
                  stops: const [0.0, 0.2, 0.6, 1.0],
                ),
              ),
            ),
          ),

          /// 3. Top-left branding
          Positioned(
            top: 20,
            left: 40,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                width: 180,
                child: Image.asset('assets/images/Oyster Group Horizontal Logo.jpg'),
              ),
            ),
          ),

          /// 4. Custom "Mandir Gate" Navigation Buttons (Vertical Left or Right)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800), // Smooth flip duration
            curve: Curves.easeInOutCubicEmphasized, // Smooth curve
            top: 0,
            bottom: 0,
            left: _isRightAligned ? null : 30, // Left side
            right: _isRightAligned ? 30 : null, // Right side
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     buildDockButton(Icons.home_rounded, 'Home', () => Navigator.pop(context), 0),
                     const SizedBox(height: 18),
                     buildDockButton(Icons.location_on_rounded, 'Location', () => Navigator.pushNamed(context, routes['location']!), 1),
                     const SizedBox(height: 18),
                     buildDockButton(Icons.map_rounded, 'Plans', () => Navigator.pushNamed(context, routes['plans']!), 2),
                     const SizedBox(height: 18),
                     buildDockButton(Icons.photo_library_rounded, 'Gallery', () => Navigator.pushNamed(context, routes['gallery']!), 3),
                     const SizedBox(height: 18),
                     buildDockButton(Icons.videocam_rounded, 'Walkthrough', () => Navigator.pushNamed(context, routes['walkthrough']!), 4),
                     const SizedBox(height: 18),
                     // Flip Button added to the list
                     buildDockButton(
                       Icons.swap_horiz_rounded, 
                       _isRightAligned ? 'Left' : 'Right', 
                       () {
                         setState(() {
                           _isRightAligned = !_isRightAligned;
                         });
                       }, 
                       5
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// 5. Badges (Bottom Right/Left - Opposite to Buttons)
          AnimatedPositioned(
             duration: const Duration(milliseconds: 800),
             curve: Curves.easeInOutCubicEmphasized,
             bottom: 40,
             right: _isRightAligned ? null : 40,
             left: _isRightAligned ? 40 : null,
             child: FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                children: [
                   Container(
                    decoration: BoxDecoration(
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                    ),
                    width: 100,
                    height: 75,
                    child: Image.asset('assets/images/bldg__1.png'),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                    ),
                    width: 100,
                    height: 75,
                    child: Image.asset('assets/images/bldg__2.png'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build premium separate Mandir-shaped orange button
  Widget buildDockButton(IconData icon, String text, VoidCallback onTap, int index) {
    return AnimatedBuilder(
      animation: _buttonAnimations[index],
      builder: (context, child) {
        // Simple slide in effect
        double slide = 50 * (1.0 - _buttonAnimations[index].value);
        return Transform.translate(
           // Slide from negative X or positive X depending on alignment? 
           // Simpler: Just slide up or fade in. Let's do a side slide.
          offset: Offset(_isRightAligned ? slide : -slide, 0),
          child: Opacity(
            opacity: _buttonAnimations[index].value,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onTap,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Shadow
                        Transform.translate(
                          offset: const Offset(3, 3), // Smaller shadow offset
                          child: CustomPaint(
                            size: const Size(80, 100), // Reduced Size
                            painter: MandirShadowPainter(),
                          ),
                        ),
                        
                        // Main Shape
                        CustomPaint(
                          size: const Size(80, 100), // Reduced Size
                          painter: MandirShapePainter(
                             color: const Color(0xFFFF6D00), 
                             gradientColors: [
                               const Color(0xFFFF9100), 
                               const Color(0xFFEF6C00), 
                             ]
                          ),
                          child: SizedBox(
                            width: 80, // Reduced Width
                            height: 100, // Reduced Height
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                 // Icon inside the body
                                 const Spacer(flex: 2), 
                                 Icon(icon, color: Colors.white, size: 24, shadows: [ // Reduced Icon Size
                                   Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: const Offset(0,2))
                                 ]),
                                 
                                 const SizedBox(height: 4), // Reduced spacing
                                 
                                 // Text Inside
                                 Text(
                                  text.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 7.5, // Reduced Font Size
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    shadows: [
                                       Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: const Offset(0,2))
                                    ]
                                  ),
                                ),
                                const SizedBox(height: 12), // Reduced bottom padding
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Stepped Wedding/Temple Cake Style Roof
class MandirShapePainter extends CustomPainter {
  final Color color;
  final List<Color> gradientColors;

  MandirShapePainter({required this.color, required this.gradientColors});

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;
    
    // Proportions
    double roofTotalH = h * 0.35; // Total roof height
    double bodyH = h - roofTotalH; // Main body height
    
    // We want a stepped roof effect.
    // Let's create a path that goes:
    // Top point -> Step 1 -> Step 2 -> Step 3 -> Body
    
    Path path = Path();
    
    // Top Triangle Tip
    path.moveTo(w / 2, 0);
    
    // Steps
    int steps = 3;
    double stepHeight = roofTotalH / steps;
    
    // Draw right side of roof
    for (int i = 1; i <= steps; i++) {
      double currentY = i * stepHeight;
      // Width expands as we go down
      // Linear expansion from top(0) to body width(w)
      double currentHalfWidth = (w * 0.5) * (i / steps); // This makes a straight triangle
      // To make it stepped, we go out then down
      
      // Traditional Mandir Shikhar style is often curved or stepped
      // Let's do strict steps: 
      // specific widths for each step level
      
      // Step 1 (Top)
      // Step 2 (Middle)
      // Step 3 (Base of roof)
    }
    
    // Simplified Stepped Path
    // Top Tip
    path.moveTo(w / 2, 0);
    path.lineTo(w * 0.65, roofTotalH * 0.33);
    path.lineTo(w * 0.60, roofTotalH * 0.33); // Inset
    path.lineTo(w * 0.80, roofTotalH * 0.66);
    path.lineTo(w * 0.75, roofTotalH * 0.66); // Inset
    path.lineTo(w, roofTotalH); // Base of roof right
    
    // Body Right
    path.lineTo(w * 0.95, roofTotalH); // Slight inset for body connection? No, flush
    path.lineTo(w * 0.95, h);
    
    // Bottom
    path.lineTo(w * 0.05, h);
    
    // Body Left
    path.lineTo(w * 0.05, roofTotalH);
    
    // Roof Left
    path.lineTo(0, roofTotalH); // Base of roof left
    path.lineTo(w * 0.25, roofTotalH * 0.66); // Inset
    path.lineTo(w * 0.20, roofTotalH * 0.66);
    path.lineTo(w * 0.40, roofTotalH * 0.33); // Inset
    path.lineTo(w * 0.35, roofTotalH * 0.33);
    
    path.close();

    // Paint with Gradient
    Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(path, paint);

    // Add a border
    Paint borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
      
    canvas.drawPath(path, borderPaint);
    
    // Inner details - Horizontal lines on roof steps
    Paint linePaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
      
    canvas.drawLine(Offset(w*0.35, roofTotalH*0.33), Offset(w*0.65, roofTotalH*0.33), linePaint);
    canvas.drawLine(Offset(w*0.20, roofTotalH*0.66), Offset(w*0.80, roofTotalH*0.66), linePaint);
    canvas.drawLine(Offset(0, roofTotalH), Offset(w, roofTotalH), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MandirShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;
    double roofTotalH = h * 0.35;

    Path path = Path();
     // Top Tip
    path.moveTo(w / 2, 0);
    path.lineTo(w * 0.65, roofTotalH * 0.33);
    path.lineTo(w * 0.60, roofTotalH * 0.33); // Inset
    path.lineTo(w * 0.80, roofTotalH * 0.66);
    path.lineTo(w * 0.75, roofTotalH * 0.66); // Inset
    path.lineTo(w, roofTotalH); // Base of roof right
    path.lineTo(w * 0.95, roofTotalH);
    path.lineTo(w * 0.95, h);
    path.lineTo(w * 0.05, h);
    path.lineTo(w * 0.05, roofTotalH);
    path.lineTo(0, roofTotalH); 
    path.lineTo(w * 0.25, roofTotalH * 0.66); // Inset
    path.lineTo(w * 0.20, roofTotalH * 0.66);
    path.lineTo(w * 0.40, roofTotalH * 0.33); // Inset
    path.lineTo(w * 0.35, roofTotalH * 0.33);
    path.close();

    canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

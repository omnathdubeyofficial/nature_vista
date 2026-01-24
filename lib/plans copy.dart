import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class PlansPage extends StatefulWidget {
  const PlansPage({Key? key}) : super(key: key);

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isMenuVisible = true;
  bool _isRightAligned = false;

  // Fade Animation State for Flip
  bool _isContentVisible = true;
  Duration _layoutDuration = const Duration(milliseconds: 1000);

  late AnimationController _menuController;
  late AnimationController _imageController;
  late AnimationController _fadeController;

  late Animation<double> _imageFadeAnimation;
  late Animation<double> _fadeAnimation;

  final List<String> menuTitles = [
    "Master Layout 32 Acres",
    "Typical Floor Plan (OLIVE)",
    "Typical Floor Plan (OAK)",
    "Refuge Floor Plan (OLIVE)",
    "Refuge Floor Plan (OAK)",
    "1BHK Unit Plan",
    "2BHK Unit Plan",
    "3BHK + Study",
    "3BHK Grand",
    "4BHK Grand",
  ];

  final List<String> imagePaths = [
    "assets/plans/MASTER_LAYOUT_NATURE_VISTA+2_(untag).jpg",
    "assets/plans/14.png",
    "assets/plans/15.png",
    "assets/plans/16.png",
    "assets/plans/17.png",
    "assets/plans/18.png",
    "assets/plans/19.png",
    "assets/plans/20.png",
    "assets/plans/21.png",
    "assets/plans/22.png",
  ];

  @override
  void initState() {
    super.initState();

    _menuController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));

    _imageController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 850));
    _imageFadeAnimation =
        CurvedAnimation(parent: _imageController, curve: Curves.easeInOutCubic);

    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOutCubic);

    _menuController.forward();
    _imageController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _menuController.dispose();
    _imageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onMenuTap(int index) {
    if (_selectedIndex != index) {
      _imageController.reverse().then((_) {
        setState(() => _selectedIndex = index);
        _imageController.forward();
      });
    }
  }

  void _toggleMenu() {
    setState(() {
      _isMenuVisible = !_isMenuVisible;
      if (_isMenuVisible) {
        _menuController.forward();
      } else {
        _menuController.reverse();
      }
    });
  }

  void _handleFlip() {
    setState(() {
      _isContentVisible = false;
      _layoutDuration = Duration.zero;
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _isRightAligned = !_isRightAligned;
      });

      Future.delayed(const Duration(milliseconds: 50), () {
        if (!mounted) return;
        setState(() {
          _layoutDuration = const Duration(milliseconds: 1000);
          _isContentVisible = true;
        });
      });
    });
  }

  void _closePage() async {
    await Future.wait([
      _menuController.reverse(),
      _imageController.reverse(),
    ]);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    final Color darkBg = const Color(0xFF1A1A1A);
    final Color panelColor = const Color(0xFF121212);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: _isContentVisible ? 1.0 : 0.0,
        child: AnimatedContainer(
          duration: _layoutDuration,
          curve: Curves.easeInOutCubic,
          child: Row(
            textDirection:
                _isRightAligned ? TextDirection.rtl : TextDirection.ltr,
            children: [
              // MENU PANEL
              AnimatedContainer(
                duration: _layoutDuration,
                curve: Curves.easeInOutCubic,
                width: _isMenuVisible ? 380 : 0, // Wider for premium look
                child: _isMenuVisible
                    ? Container(
                        decoration: BoxDecoration(
                          color: panelColor,
                          border: Border(
                            right: BorderSide(
                                color: const Color(0xFFB8860B).withOpacity(0.3),
                                width: 1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 30,
                              offset: const Offset(10, 0),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 60),
                            // TITLE SECTION
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  Text(
                                    "FLOOR PLANS",
                                    style: GoogleFonts.cinzel(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFD4AF37), // Gold
                                      letterSpacing: 4,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    height: 2,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          const Color(0xFFD4AF37),
                                          Colors.transparent
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),

                            // MENU LIST
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                itemCount: menuTitles.length,
                                itemBuilder: (context, index) {
                                  final bool isSelected =
                                      _selectedIndex == index;
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: RoyalMenuButton(
                                      title: menuTitles[index],
                                      isSelected: isSelected,
                                      onTap: () => _onMenuTap(index),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // BOTTOM CONTROLS
                            Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.8)
                                  ],
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  RoyalControlPill(
                                    icon: Icons.flip_camera_android_rounded,
                                    label: "FLIP VIEW",
                                    onTap: _handleFlip,
                                  ),
                                  const SizedBox(width: 15),
                                  RoyalControlPill(
                                    icon: Icons.close_rounded,
                                    label: "CLOSE",
                                    onTap: _closePage,
                                    isDestructive: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // IMAGE VIEWER SECTION
              Expanded(
                child: Stack(
                  children: [
                    // Background Texture
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F0F0F),
                          image: DecorationImage(
                            image: AssetImage("assets/images/hero.png"), // Fallback if exists
                            fit: BoxFit.cover,
                            opacity: 0.15,
                          ),
                        ),
                      ),
                    ),

                    // Main Plan Image
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: FadeTransition(
                        opacity: _imageFadeAnimation,
                        child: InteractiveViewer(
                          panEnabled: true,
                          boundaryMargin: const EdgeInsets.all(double.infinity),
                          minScale: 0.1,
                          maxScale: 15.0,
                          child: Center(
                            child: Hero(
                              tag: 'plan_${menuTitles[_selectedIndex]}',
                              child: Container(
                                margin: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 50,
                                      spreadRadius: -10,
                                    )
                                  ],
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.asset(
                                    imagePaths[_selectedIndex],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // TOGGLE MENU BUTTON (Floating)
                    Positioned(
                      top: 40,
                      left: _isRightAligned && !_isMenuVisible
                          ? 30
                          : (!_isRightAligned && !_isMenuVisible ? 30 : null),
                      right: _isRightAligned && _isMenuVisible
                          ? null
                          : (_isRightAligned ? 30 : null),
                      child: _isMenuVisible
                          ? const SizedBox.shrink()
                          : MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: _toggleMenu,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFD4AF37), Color(0xFF8B6914)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFD4AF37).withOpacity(0.4),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      )
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.menu_rounded,
                                    color: Colors.black87,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// 1. ROYAL MENU BUTTON WIDGET
// --------------------------------------------------------------------------
class RoyalMenuButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const RoyalMenuButton({
    Key? key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
        builder: (context, value, child) {
          return CustomPaint(
            painter: RoyalButtonPainter(
              isSelected: isSelected,
              animationValue: value,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
              child: Row(
                children: [
                  // Diamond Indicator (Scales with animation)
                  Transform.scale(
                    scale: value, 
                    child: Opacity(
                      opacity: value,
                      child: Container(
                        margin: const EdgeInsets.only(right: 15),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3E2723), // Dark Brown
                          shape: BoxShape.rectangle,
                        ),
                        transform: Matrix4.rotationZ(0.785), // Rotate 45deg
                      ),
                    ),
                  ),
                  
                  // Text
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      style: GoogleFonts.cinzel(
                        color: Color.lerp(
                          Colors.white.withOpacity(0.6),
                          const Color(0xFF3E2723), // Dark brown for selected
                          value
                        ),
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        letterSpacing: 1.2,
                        shadows: isSelected 
                        ? [] 
                        : [Shadow(color: Colors.black, blurRadius: 2)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// --------------------------------------------------------------------------
// 2. THE CUSTOM PAINTER (The "Behtreen" Part)
// --------------------------------------------------------------------------
class RoyalButtonPainter extends CustomPainter {
  final bool isSelected;
  final double animationValue; // 0.0 to 1.0

  RoyalButtonPainter({required this.isSelected, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    if (animationValue == 0) return; // Save resources if not selected

    final w = size.width;
    final h = size.height;
    final paint = Paint();

    // 1. Background Gradient (Gold to Orange-Gold)
    final Rect rect = Rect.fromLTWH(0, 0, w, h);
    paint.shader = LinearGradient(
      colors: [
        const Color(0xFFFFF8E1), // Cream White
        const Color(0xFFFFECB3), // Pale Gold
        const Color(0xFFFFCA28), // Amber
      ],
      stops: const [0.0, 0.5, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(rect);

    // 2. Chamfered Shape (Cut Corners)
    final double cut = 12.0 * animationValue; // Animate corner cut
    final Path path = Path()
      ..moveTo(cut, 0)
      ..lineTo(w - cut, 0)
      ..lineTo(w, cut)
      ..lineTo(w, h - cut)
      ..lineTo(w - cut, h)
      ..lineTo(cut, h)
      ..lineTo(0, h - cut)
      ..lineTo(0, cut)
      ..close();

    // Draw Shadow
    canvas.drawShadow(path, const Color(0xFFFF6F00).withOpacity(0.4 * animationValue), 8, true);
    
    // Draw Fill
    canvas.drawPath(path, paint);

    // 3. Metallic Border
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF8D6E63), // Brown
          const Color(0xFFFFD54F), // Gold
          const Color(0xFF8D6E63), // Brown
        ],
      ).createShader(rect);

    canvas.drawPath(path, borderPaint);

    // 4. Inner Highlight (Bevel Effect)
    final Path innerPath = Path()
      ..moveTo(cut + 2, 2)
      ..lineTo(w - cut - 2, 2)
      ..lineTo(w - 2, cut + 2)
      ..lineTo(w - 2, h - cut - 2)
      ..lineTo(w - cut - 2, h - 2)
      ..lineTo(cut + 2, h - 2)
      ..lineTo(2, h - cut - 2)
      ..lineTo(2, cut + 2)
      ..close();

    canvas.drawPath(innerPath, Paint()..color = Colors.white.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(RoyalButtonPainter oldDelegate) => 
      oldDelegate.animationValue != animationValue;
}

// --------------------------------------------------------------------------
// 3. ROYAL CONTROL PILL (Flip / Close Buttons)
// --------------------------------------------------------------------------
class RoyalControlPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const RoyalControlPill({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = isDestructive ? const Color(0xFFE53935) : const Color(0xFFD4AF37);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05), // Glass effect
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: primaryColor.withOpacity(0.5),
            width: 1.5
          ),
          boxShadow: [
             BoxShadow(
               color: primaryColor.withOpacity(0.1),
               blurRadius: 10,
               spreadRadius: 1
             )
          ]
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryColor, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.cinzel(
                color: primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

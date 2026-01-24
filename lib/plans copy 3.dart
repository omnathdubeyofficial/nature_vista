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

  // GESTURE VARIABLES
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  double _rotation = 0.0;

  Offset _startingOffset = Offset.zero;
  Offset _startingFocalPoint = Offset.zero;
  double _startingScale = 1.0;
  double _startingRotation = 0.0;

  final List<String> menuTitles = [
    "Master Layout 32 Acres",
    "Typical Floor Plan",
    // "Typical Floor Plan (OAK)",
    "Refuge Floor Plan",
    // "Refuge Floor Plan (OAK)",
    "1BHK-B Unit Plan",
    "2BHK-B Unit Plan",
    "1 BHK-B X 2 (3.5 BHK) WITH STUDY",
    "3BHK Grand",
    "2 BHK-C + 2 BHK-B (4.5 BHK)+1",
  ];

  final List<String> imagePaths = [
    "assets/plans/MASTER_LAYOUT_NATURE_VISTA+2_(untag).jpg",
    "assets/plans/typical untg...jpg",
    // "assets/plans/typical untg...jpg",
    "assets/plans/refuge untg.jpg",
    // "assets/plans/refuge untg.jpg",
    "assets/plans/1bhk-b untg.jpg",
    "assets/plans/2bhk-b untg.jpg",
    "assets/plans/1 BHK-B X 2=JODI FLATS (3.5 BHK) WITH STUDY untg.jpg",
    "assets/plans/3 bhk grand untg.jpg",
    "assets/plans/2 BHK-C + 2 BHK-B = JODI FLATS (4.5 BHK)+1 untg.jpg",
  ];

  @override
  void initState() {
    super.initState();

    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _imageFadeAnimation =
        CurvedAnimation(parent: _imageController, curve: Curves.easeInOutCubic);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
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
        setState(() {
          _selectedIndex = index;
          _scale = 1.0;
          _rotation = 0.0;
          _offset = Offset.zero;
        });
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

  // GESTURE HANDLERS
  void _handleScaleStart(ScaleStartDetails details) {
    _startingOffset = _offset;
    _startingFocalPoint = details.focalPoint;
    _startingScale = _scale;
    _startingRotation = _rotation;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      double tempScale = _startingScale * details.scale;
      if (tempScale < 0.1) tempScale = 0.1;
      if (tempScale > 15.0) tempScale = 15.0;
      _scale = tempScale;

      _rotation = _startingRotation + details.rotation;

      final Offset delta = details.focalPoint - _startingFocalPoint;
      _offset = _startingOffset + delta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pure white background
      backgroundColor: Colors.white,
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
                width: _isMenuVisible ? 380 : 0,
                child: _isMenuVisible
                    ? Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDE7),
                          border: Border(
                            right: BorderSide(
                              color: Colors.orange.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 60),
                            // TITLE SECTION
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  Text(
                                    "FLOOR PLANS",
                                    style: GoogleFonts.cinzel(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFFE65100),
                                      letterSpacing: 4,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    height: 2,
                                    width: 80,
                                    color: const Color(0xFFE65100),
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
                                    child: ScallopedMenuButton(
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
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  RoyalIconButton(
                                    icon: Icons.flip_camera_android_rounded,
                                    onTap: _handleFlip,
                                  ),
                                  RoyalIconButton(
                                    icon: Icons.close_rounded,
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
                    // Plain white background
                    Positioned.fill(
                      child: Container(
                        color: Colors.white,
                      ),
                    ),

                    // Main Plan Image (With Gesture Detector)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: FadeTransition(
                        opacity: _imageFadeAnimation,
                        child: GestureDetector(
                          onScaleStart: _handleScaleStart,
                          onScaleUpdate: _handleScaleUpdate,
                          behavior: HitTestBehavior.translucent,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.transparent,
                            child: Center(
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..translate(_offset.dx, _offset.dy)
                                  ..rotateZ(_rotation)
                                  ..scale(_scale),
                                child: Hero(
                                  tag: 'plan_${menuTitles[_selectedIndex]}',
                                  child: Container(
                                    // Shadow removed here
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.asset(
                                        imagePaths[_selectedIndex],
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error,
                                            stackTrace) {
                                          return Container(
                                            width: 400,
                                            height: 300,
                                            color: Colors.grey[200],
                                            child: const Center(
                                              child: Text(
                                                "Image Not Found",
                                                style: TextStyle(
                                                    color: Colors.black87),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // TOGGLE MENU BUTTON
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
                                      colors: [
                                        Color(0xFFFF9800),
                                        Color(0xFFEF6C00)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.menu_rounded,
                                    color: Colors.white,
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
// 1. SCALLOPED MENU BUTTON
// --------------------------------------------------------------------------
class ScallopedMenuButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const ScallopedMenuButton({
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
        curve: Curves.easeOut,
        tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
        builder: (context, value, child) {
          return CustomPaint(
            painter: ScallopedButtonPainter(
              isSelected: isSelected,
              animationValue: value,
            ),
            child: Container(
              height: 55,
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                title.toUpperCase(),
                style: GoogleFonts.cinzel(
                  fontSize: 14,
                  color:
                      isSelected ? Colors.white : const Color(0xFFE65100),
                  fontWeight:
                      isSelected ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}

// --------------------------------------------------------------------------
// 2. THE CUSTOM PAINTER
// --------------------------------------------------------------------------
class ScallopedButtonPainter extends CustomPainter {
  final bool isSelected;
  final double animationValue;

  ScallopedButtonPainter({
    required this.isSelected,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint();

    final Color activeColor = const Color(0xFFFF9100);
    final Color inactiveBorderColor =
        const Color(0xFFFF9100).withOpacity(0.5);

    final path = Path();
    final double bumpSize = h / 3;

    path.moveTo(bumpSize, 0);
    path.lineTo(w - bumpSize, 0);
    path.quadraticBezierTo(
        w, bumpSize * 0.5, w - (bumpSize * 0.2), bumpSize);
    path.quadraticBezierTo(w + (bumpSize * 0.2), h * 0.5,
        w - (bumpSize * 0.2), h - bumpSize);
    path.quadraticBezierTo(
        w, h - (bumpSize * 0.5), w - bumpSize, h);
    path.lineTo(bumpSize, h);
    path.quadraticBezierTo(
        0, h - (bumpSize * 0.5), bumpSize * 0.2, h - bumpSize);
    path.quadraticBezierTo(
        -(bumpSize * 0.2), h * 0.5, bumpSize * 0.2, bumpSize);
    path.quadraticBezierTo(0, bumpSize * 0.5, bumpSize, 0);
    path.close();

    if (isSelected || animationValue > 0) {
      paint.color = activeColor.withOpacity(animationValue);
      paint.style = PaintingStyle.fill;
      canvas.drawPath(path, paint);
    } else {
      final borderPaint = Paint()
        ..color = inactiveBorderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(ScallopedButtonPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.isSelected != isSelected;
}

// --------------------------------------------------------------------------
// 3. SIMPLE ICON BUTTON
// --------------------------------------------------------------------------
class RoyalIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const RoyalIconButton({
    Key? key,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFE65100),
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: const Color(0xFFE65100),
          size: 24,
        ),
      ),
    );
  }
}

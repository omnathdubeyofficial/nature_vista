import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({Key? key}) : super(key: key);

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> with TickerProviderStateMixin {
  static const _prefsKeyMenuRight = 'plans_menu_right_aligned';

  bool _isMenuVisible = true;
  bool _isRightAligned = false;

  // Flip fade
  bool _isContentVisible = true;
  Duration _layoutDuration = const Duration(milliseconds: 1000);

  late AnimationController _menuController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Max 2 images
  final List<_PlanImageState> _activeImages = []; // paint order matters (last = top)

  final List<String> menuTitles = [
    "Master Layout 32 Acres",
    "Typical Floor Plan",
    "Refuge Floor Plan",
    "1BHK-B Unit Plan",
    "2BHK-B Unit Plan",
    "1 BHK-B X 2 (3.5 BHK) WITH STUDY",
    "3BHK Grand",
    "2 BHK-C + 2 BHK-B (4.5 BHK)+1",
  ];

  final List<String> imagePaths = [
    "assets/plans/MASTER_LAYOUT_NATURE_VISTA+2_(untag).jpg",
    "assets/plans/typical untg...jpg",
    "assets/plans/refuge untg.jpg",
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

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOutCubic);

    _menuController.forward();
    _fadeController.forward();

    _loadMenuAlignment();

    // Default: first plan open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addOrFocusImage(0, animate: false);
    });
  }

  Future<void> _loadMenuAlignment() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_prefsKeyMenuRight);
    if (!mounted) return;
    setState(() => _isRightAligned = saved ?? false);
  }

  Future<void> _saveMenuAlignment() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyMenuRight, _isRightAligned);
  }

  @override
  void dispose() {
    _menuController.dispose();
    _fadeController.dispose();
    for (final img in _activeImages) {
      img.controller.dispose();
    }
    super.dispose();
  }

  int? _slotForIndex(int planIndex) {
    final found = _activeImages.where((e) => e.planIndex == planIndex);
    if (found.isEmpty) return null;
    return found.first.slot;
  }

  int? _firstEmptySlot() {
    final used = _activeImages.map((e) => e.slot).toSet();
    if (!used.contains(0)) return 0;
    if (!used.contains(1)) return 1;
    return null;
  }

  void _focusImage(int planIndex) {
    final i = _activeImages.indexWhere((e) => e.planIndex == planIndex);
    if (i == -1) return;
    setState(() {
      final item = _activeImages.removeAt(i);
      _activeImages.add(item); // last paints on top
    });
  }

  void _addOrFocusImage(int planIndex, {bool animate = true}) {
    // Already visible? just focus/top
    final existing = _activeImages.any((e) => e.planIndex == planIndex);
    if (existing) {
      _focusImage(planIndex);
      return;
    }

    // Max 2
    if (_activeImages.length >= 2) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color(0xFFFFFDE7),
            title: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFFE65100),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Maximum Limit Reached',
                  style: GoogleFonts.cinzel(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE65100),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You can view a maximum of 2 floor plans at once for easy comparison.',
                  style: GoogleFonts.cinzel(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFE65100).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFFE65100),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Please close one plan by tapping the X button to view another.',
                          style: GoogleFonts.cinzel(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'OK',
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    final slot = _firstEmptySlot();
    if (slot == null) return;

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    final fade =
        CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);

    final state = _PlanImageState(
      planIndex: planIndex,
      slot: slot,
      controller: controller,
      fadeAnimation: fade,
    );

    setState(() {
      _activeImages.add(state); // newly added becomes top
    });

    if (animate) {
      controller.forward();
    } else {
      controller.value = 1.0;
    }
  }

  void _removeImage(int planIndex) {
    final idx = _activeImages.indexWhere((e) => e.planIndex == planIndex);
    if (idx == -1) return;

    final img = _activeImages[idx];
    img.controller.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _activeImages.removeWhere((e) => e.planIndex == planIndex);
      });
      img.controller.dispose();
    });
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

    Future.delayed(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      setState(() {
        _isRightAligned = !_isRightAligned;
      });
      await _saveMenuAlignment();

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
    await _saveMenuAlignment();
    await _menuController.reverse();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                itemCount: menuTitles.length,
                                itemBuilder: (context, index) {
                                  final bool isSelected =
                                      _activeImages.any((e) => e.planIndex == index);
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: ScallopedMenuButton(
                                      title: menuTitles[index],
                                      isSelected: isSelected,
                                      onTap: () => _addOrFocusImage(index),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Bottom controls: gap 50% less
                            Container(
                              padding: const EdgeInsets.all(30),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RoyalIconButton(
                                    icon: Icons.flip_camera_android_rounded,
                                    onTap: _handleFlip,
                                  ),
                                  const SizedBox(width: 18),
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
                    Positioned.fill(child: Container(color: Colors.white)),

                    // Comparison area (max 2)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        final h = constraints.maxHeight;
                        
                        // Determine if single or dual view
                        final isSingleView = _activeImages.length == 1;
                        final half = w / 2;

                        if (_activeImages.isEmpty) {
                          return Center(
                            child: Text(
                              'Select a floor plan from menu',
                              style: GoogleFonts.cinzel(
                                fontSize: 18,
                                color: Colors.grey[400],
                                letterSpacing: 2,
                              ),
                            ),
                          );
                        }

                        // Important: allow visual overflow while zooming
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Divider when 2 images are active
                            if (!isSingleView)
                              Positioned(
                                left: half - 1,
                                top: 0,
                                bottom: 0,
                                child: Container(width: 2, color: Colors.grey[250]),
                              ),

                            // Paint in list order (last on top)
                            for (final img in _activeImages)
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeInOutCubic,
                                left: isSingleView 
                                    ? 0 
                                    : (img.slot == 0 ? 0 : half),
                                top: 0,
                                width: isSingleView ? w : half,
                                height: h,
                                child: FadeTransition(
                                  opacity: img.fadeAnimation,
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: InteractiveImageViewer(
                                      key: ValueKey('plan_${img.planIndex}_${img.slot}'),
                                      imagePath: imagePaths[img.planIndex],
                                      title: menuTitles[img.planIndex],
                                      onClose: () => _removeImage(img.planIndex),
                                      onFocus: () => _focusImage(img.planIndex),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),

                    // Toggle menu button (when menu hidden)
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
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFFF9800),
                                        Color(0xFFEF6C00),
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

// Holds each plan’s slot + animation (slot: 0=left, 1=right)
class _PlanImageState {
  final int planIndex;
  final int slot;
  final AnimationController controller;
  final Animation<double> fadeAnimation;

  _PlanImageState({
    required this.planIndex,
    required this.slot,
    required this.controller,
    required this.fadeAnimation,
  });
}

// --------------------------------------------------------------------------
// INTERACTIVE IMAGE VIEWER (per-image gestures + top-right X)
// --------------------------------------------------------------------------
class InteractiveImageViewer extends StatefulWidget {
  final String imagePath;
  final String title;
  final VoidCallback onClose;
  final VoidCallback onFocus;

  const InteractiveImageViewer({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.onClose,
    required this.onFocus,
  }) : super(key: key);

  @override
  State<InteractiveImageViewer> createState() => _InteractiveImageViewerState();
}

class _InteractiveImageViewerState extends State<InteractiveImageViewer> with SingleTickerProviderStateMixin {
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  double _rotation = 0.0;

  Offset _startingOffset = Offset.zero;
  Offset _startingFocalPoint = Offset.zero;
  double _startingScale = 1.0;
  double _startingRotation = 0.0;

  // Animation controller for smooth zoom
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _offsetAnimation;

  // Double-tap zoom state
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    // Initialize with dummy animations to avoid null errors before first double-tap
    _scaleAnimation = const AlwaysStoppedAnimation(1.0);
    _offsetAnimation = const AlwaysStoppedAnimation(Offset.zero);

    _animController.addListener(() {
      setState(() {
        _scale = _scaleAnimation.value;
        _offset = _offsetAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleScaleStart(ScaleStartDetails details) {
    widget.onFocus();
    if (_animController.isAnimating) return;
    _startingOffset = _offset;
    _startingFocalPoint = details.focalPoint;
    _startingScale = _scale;
    _startingRotation = _rotation;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_animController.isAnimating) return;
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

  void _handleDoubleTap(TapDownDetails details) {
    widget.onFocus();
    
    if (_animController.isAnimating) return;

    Offset targetOffset;
    double targetScale;

    if (_isZoomed) {
      targetScale = 1.0;
      targetOffset = Offset.zero;
      _isZoomed = false;
    } else {
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final localPosition = renderBox.globalToLocal(details.globalPosition);
        final containerSize = renderBox.size;
        
        final centerX = containerSize.width / 2;
        final centerY = containerSize.height / 2;
        
        targetScale = 3.0;
        targetOffset = Offset(
          (centerX - localPosition.dx) * (targetScale - 1),
          (centerY - localPosition.dy) * (targetScale - 1),
        );
        _isZoomed = true;
      } else {
        return;
      }
    }

    _scaleAnimation = Tween<double>(begin: _scale, end: targetScale).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutCubic),
    );
    _offsetAnimation = Tween<Offset>(begin: _offset, end: targetOffset).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutCubic),
    );

    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: widget.onFocus,
          onDoubleTapDown: _handleDoubleTap,
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
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.asset(
                      widget.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 400,
                          height: 300,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Text(
                              "Image Not Found",
                              style: TextStyle(color: Colors.black87),
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

        // Top-right close (X) - per image
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFE65100),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------------------------------
// SCALLOPED MENU BUTTON
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
                  color: isSelected ? Colors.white : const Color(0xFFE65100),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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
// SCALLOPED BUTTON PAINTER
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

    const Color activeColor = Color(0xFFFF9100);
    final Color inactiveBorderColor = const Color(0xFFFF9100).withOpacity(0.5);

    final path = Path();
    final double bumpSize = h / 3;

    path.moveTo(bumpSize, 0);
    path.lineTo(w - bumpSize, 0);
    path.quadraticBezierTo(w, bumpSize * 0.5, w - (bumpSize * 0.2), bumpSize);
    path.quadraticBezierTo(
        w + (bumpSize * 0.2), h * 0.5, w - (bumpSize * 0.2), h - bumpSize);
    path.quadraticBezierTo(w, h - (bumpSize * 0.5), w - bumpSize, h);
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
// ROYAL ICON BUTTON
// --------------------------------------------------------------------------
class RoyalIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool isDisabled;

  const RoyalIconButton({
    Key? key,
    required this.icon,
    this.onTap,
    this.isDestructive = false,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = isDisabled ? Colors.grey : const Color(0xFFE65100);
    
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isDisabled ? 0.3 : 0.5),
          shape: BoxShape.circle,
          border: Border.all(
            color: primaryColor,
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: primaryColor,
          size: 24,
        ),
      ),
    );
  }
}

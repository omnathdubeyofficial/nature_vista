import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Building1Page extends StatefulWidget {
  const Building1Page({Key? key}) : super(key: key);

  @override
  State<Building1Page> createState() => _Building1PageState();
}

class _Building1PageState extends State<Building1Page> with TickerProviderStateMixin {
  static const _prefsKeyMenuRight = 'building_1_menu_right_aligned';

  bool _isMenuVisible = true;
  bool _isRightAligned = false;
  final Duration _layoutDuration = const Duration(milliseconds: 1000);

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<_PlanImageState> _activeImages = [];

  final List<String> menuTitles = [
    "Typical Floor Plan",
    "1BHK-A Unit Plan",
    "2BHK-A Unit Plan",
    "3BHK Grand",
    "3.5 BHK Unit Plan",
    "Refuge Floor Plan",
  ];

  final List<String> imagePaths = [
    "assets/buildingone/A-4 FLOOR PLAN-V1_C2C-TYPICAL FLOUR PLAN.pdf.png",
    "assets/buildingone/A-4 FLOOR PLAN-V1_C2C-1BHK-A.pdf.png",
    "assets/buildingone/A-4 FLOOR PLAN-V1_C2C-2BHK-A.pdf.png",
    "assets/buildingone/A-4 FLOOR PLAN-V1_C2C-3BHK GRAND.pdf.png",
    "assets/buildingone/A-4 FLOOR PLAN-V1_C2C-3.5 BHK.pdf.png",
    "assets/buildingone/refuge_floor_plan_b_1.png",
  ];

  bool _isCompareMode = true;
  double _sidebarOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic);
    _fadeController.forward();
    _loadMenuAlignment();
    // Start with the first image active
    WidgetsBinding.instance.addPostFrameCallback((_) => _addOrFocusImage(0, animate: false));
  }

  Future<void> _loadMenuAlignment() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isRightAligned = prefs.getBool(_prefsKeyMenuRight) ?? false;
      _isCompareMode = prefs.getBool('building_1_compare_mode') ?? true;
    });
  }

  Future<void> _saveMenuAlignment() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyMenuRight, _isRightAligned);
    await prefs.setBool('building_1_compare_mode', _isCompareMode);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    for (final img in _activeImages) img.controller.dispose();
    super.dispose();
  }

  void _focusImage(int planIndex) {
    setState(() {
      final i = _activeImages.indexWhere((e) => e.planIndex == planIndex);
      if (i == -1) return;
      final item = _activeImages.removeAt(i);
      _activeImages.add(item);
    });
  }

  void _addOrFocusImage(int planIndex, {bool animate = true}) {
    if (_activeImages.any((e) => e.planIndex == planIndex)) {
      if (_activeImages.length > 1) {
        _removeImage(planIndex);
      }
      return;
    }

    if (!_isCompareMode) {
      // Single selection mode
      if (_activeImages.isNotEmpty) {
        // Clear existing instantly (or could fade)
        for (var img in List.from(_activeImages)) {
          _removeImage(img.planIndex, immediate: true);
        }
      }
    } else if (_activeImages.length >= 4) {
      _showRoyalDialog(
        title: "Comparison Limit",
        message: "You can compare up to 4 images at once. Please close one to add another.",
        icon: Icons.info_outline,
      );
      return;
    }

    final controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    final fade = CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);
    final state = _PlanImageState(planIndex: planIndex, slot: _activeImages.length, controller: controller, fadeAnimation: fade);
    setState(() => _activeImages.add(state));
    if (animate) controller.forward(); else controller.value = 1.0;
  }

  void _showRoyalDialog({required String title, required String message, required IconData icon}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFBF9F6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFFF9100), width: 1)),
        title: Row(
          children: [
            Icon(icon, color: const Color(0xFFE65100), size: 28),
            const SizedBox(width: 12),
            Text(title, style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, color: const Color(0xFFE65100), fontSize: 18)),
          ],
        ),
        content: Text(message, style: GoogleFonts.inter(color: Colors.black87, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(backgroundColor: const Color(0xFFE65100), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text("OK", style: GoogleFonts.cinzel(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _removeImage(int planIndex, {bool immediate = false}) {
    final idx = _activeImages.indexWhere((e) => e.planIndex == planIndex);
    if (idx == -1) return;
    final img = _activeImages[idx];
    if (immediate) {
      setState(() => _activeImages.removeAt(idx));
      img.controller.dispose();
    } else {
      img.controller.reverse().then((_) {
        if (!mounted) return;
        setState(() => _activeImages.removeWhere((e) => e.planIndex == planIndex));
        img.controller.dispose();
      });
    }
  }

  void _handleFlip() async {
    // Smooth transition
    setState(() => _sidebarOpacity = 0.0);
    await Future.delayed(const Duration(milliseconds: 400));
    
    setState(() {
      _isRightAligned = !_isRightAligned;
    });
    _saveMenuAlignment();

    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => _sidebarOpacity = 1.0);
  }

  void _toggleCompareMode() {
    setState(() {
      _isCompareMode = !_isCompareMode;
      // If turning off compare mode, keep only the last selected image
      if (!_isCompareMode && _activeImages.length > 1) {
        final last = _activeImages.last;
        for (var img in List.from(_activeImages)) {
          if (img != last) _removeImage(img.planIndex, immediate: true);
        }
      }
    });
    _saveMenuAlignment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Decorative Background
            const Positioned(
              right: -50,
              top: -50,
              child: ExperienceAura(color: Color(0xFFFFE0B2)),
            ),

            Row(
              textDirection: _isRightAligned ? TextDirection.rtl : TextDirection.ltr,
              children: [
                // GLASS SIDEBAR
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _sidebarOpacity,
                  child: AnimatedContainer(
                    duration: _layoutDuration,
                    curve: Curves.easeInOutQuart,
                    width: _isMenuVisible ? 400 : 0,
                    child: ClipRect(
                      child: OverflowBox(
                        minWidth: 400,
                        maxWidth: 400,
                        alignment: _isRightAligned ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            border: Border(
                              right: _isRightAligned ? BorderSide.none : BorderSide(color: Colors.orange.withOpacity(0.1), width: 1),
                              left: _isRightAligned ? BorderSide(color: Colors.orange.withOpacity(0.1), width: 1) : BorderSide.none,
                            ),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Column(
                              children: [
                                const SizedBox(height: 80),
                                Text(
                                  "BUILDING 1",
                                  style: GoogleFonts.cinzel(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFE65100),
                                    letterSpacing: 4,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  width: 40,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF9100),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                
                                // COMPARE MODE TOGGLE
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 40),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "COMPARE MODE",
                                        style: GoogleFonts.cinzel(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFE65100),
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      Switch(
                                        value: _isCompareMode,
                                        onChanged: (_) => _toggleCompareMode(),
                                        activeColor: const Color(0xFFFF9100),
                                        activeTrackColor: const Color(0xFFFFE0B2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 30),
                                    itemCount: menuTitles.length,
                                    itemBuilder: (context, index) => _buildSidebarItem(index),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(40),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ExperienceIconButton(
                                          icon: Icons.flip_camera_android_rounded,
                                          onTap: _handleFlip,
                                          tooltip: 'Swap Layout',
                                        ),
                                        const SizedBox(width: 15),
                                        ExperienceIconButton(
                                          icon: Icons.close,
                                          onTap: () => Navigator.pop(context),
                                          isDestructive: true,
                                          tooltip: 'Close',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // MAIN VIEWER AREA
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(child: Container(color: Colors.transparent)),
                      _buildGridImages(),
                    ],
                  ),
                ),
              ],
            ),
            
            // SIDEBAR TOGGLE BUTTON (Experience Style)
            AnimatedPositioned(
              duration: _layoutDuration,
              curve: Curves.easeInOutQuart,
              top: 40,
              left: _isRightAligned ? null : (_isMenuVisible ? 370 : 30),
              right: _isRightAligned ? (_isMenuVisible ? 370 : 30) : null,
              child: GestureDetector(
                onTap: () => setState(() => _isMenuVisible = !_isMenuVisible),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9100),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF9100).withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isMenuVisible ? (_isRightAligned ? Icons.chevron_right : Icons.chevron_left) : Icons.menu,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridImages() {
    if (_activeImages.isEmpty) {
      return Center(
        child: Text(
          "Select Unit Plans from Sidebar to Compare",
          style: GoogleFonts.cinzel(color: Colors.orange.withOpacity(0.3), fontSize: 18, letterSpacing: 2),
        ),
      );
    }
    
    int count = _activeImages.length;
    return LayoutBuilder(
      builder: (context, constraints) {
        double w = constraints.maxWidth;
        double h = constraints.maxHeight;
        
        return Stack(
          children: [
            for (int i = 0; i < count; i++)
              _buildGridItem(_activeImages[i], i, count, w, h),
          ],
        );
      }
    );
  }

  Widget _buildGridItem(_PlanImageState img, int index, int total, double w, double h) {
    double itemW = total == 1 ? w : w / 2;
    double itemH = total <= 2 ? h : h / 2;
    
    double left = (total > 1 && (index == 1 || index == 3)) ? w / 2 : 0;
    double top = (total > 2 && (index == 2 || index == 3)) ? h / 2 : 0;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutQuart,
      left: left,
      top: top,
      width: itemW,
      height: itemH,
      child: FadeTransition(
        opacity: img.fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: InteractiveImageViewer(
            imagePath: imagePaths[img.planIndex],
            title: menuTitles[img.planIndex],
            onFocus: () => _focusImage(img.planIndex),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem(int index) {
    bool isActive = _activeImages.any((img) => img.planIndex == index);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () => _addOrFocusImage(index),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: CustomPaint(
              painter: ScallopedSidebarButtonPainter(
                isActive: isActive,
              ),
              child: Center(
                child: Text(
                  menuTitles[index].toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : const Color(0xFFE65100),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ExperienceAura extends StatelessWidget {
  final Color color;
  const ExperienceAura({Key? key, required this.color}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.2), Colors.transparent],
        ),
      ),
    );
  }
}

class _PlanImageState {
  final int planIndex;
  final int slot;
  final AnimationController controller;
  final Animation<double> fadeAnimation;
  _PlanImageState({required this.planIndex, required this.slot, required this.controller, required this.fadeAnimation});
}

class InteractiveImageViewer extends StatefulWidget {
  final String imagePath;
  final String title;
  final VoidCallback onFocus;
  const InteractiveImageViewer({Key? key, required this.imagePath, required this.title, required this.onFocus}) : super(key: key);
  @override
  State<InteractiveImageViewer> createState() => _InteractiveImageViewerState();
}

class _InteractiveImageViewerState extends State<InteractiveImageViewer> {
  final TransformationController _transformationController = TransformationController();
  bool _isZoomed = false;

  void _handleDoubleTap(TapDownDetails details) {
    widget.onFocus();
    if (_isZoomed) {
      _transformationController.value = Matrix4.identity();
      setState(() => _isZoomed = false);
    } else {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final localOffset = box.globalToLocal(details.globalPosition);
      
      _transformationController.value = Matrix4.identity()
        ..translate(localOffset.dx, localOffset.dy)
        ..scale(3.0)
        ..translate(-localOffset.dx, -localOffset.dy);
      setState(() => _isZoomed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GestureDetector(
        onDoubleTapDown: _handleDoubleTap,
        onTap: widget.onFocus,
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 1.0,
          maxScale: 10.0,
          onInteractionEnd: (details) {
            final scale = _transformationController.value.getMaxScaleOnAxis();
            if (scale <= 1.01 && _isZoomed) setState(() => _isZoomed = false);
            else if (scale > 1.01 && !_isZoomed) setState(() => _isZoomed = true);
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(widget.imagePath, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}

class ScallopedSidebarButtonPainter extends CustomPainter {
  final bool isActive;

  ScallopedSidebarButtonPainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint();
    final path = Path();
    final double bumpSize = h / 3.5;

    path.moveTo(bumpSize, 0);
    path.lineTo(w - bumpSize, 0);
    path.quadraticBezierTo(w, bumpSize * 0.5, w - (bumpSize * 0.2), bumpSize);
    path.quadraticBezierTo(w + (bumpSize * 0.2), h * 0.5, w - (bumpSize * 0.2), h - bumpSize);
    path.quadraticBezierTo(w, h - (bumpSize * 0.5), w - bumpSize, h);
    path.lineTo(bumpSize, h);
    path.quadraticBezierTo(0, h - (bumpSize * 0.5), bumpSize * 0.2, h - bumpSize);
    path.quadraticBezierTo(-(bumpSize * 0.2), h * 0.5, bumpSize * 0.2, bumpSize);
    path.quadraticBezierTo(0, bumpSize * 0.5, bumpSize, 0);
    path.close();

    if (isActive) {
      paint.color = const Color(0xFFFF9100);
      paint.style = PaintingStyle.fill;
      canvas.drawShadow(path, Colors.black.withOpacity(0.3), 6.0, true);
    } else {
      paint.color = const Color(0xFFFFE0B2).withOpacity(0.3);
      paint.style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = const Color(0xFFFF9100).withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawPath(path, borderPaint);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ExperienceIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
  final String? tooltip;
  const ExperienceIconButton({Key? key, required this.icon, required this.onTap, this.isDestructive = false, this.tooltip}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              gradient: isDestructive 
                ? LinearGradient(colors: [const Color(0xFFFFE0B2).withOpacity(0.1), const Color(0xFFFFF3E0).withOpacity(0.05)])
                : const LinearGradient(colors: [Color(0xFFFF9100), Color(0xFFFFAB40)]),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFF9100), width: 1.5),
            ),
            child: Icon(
              icon, 
              color: isDestructive ? const Color(0xFFFF9100) : Colors.white, 
              size: 24
            ),
          ),
        ),
      ),
    );
  }
}

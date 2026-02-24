import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MasterLayoutPage extends StatefulWidget {
  const MasterLayoutPage({Key? key}) : super(key: key);

  @override
  State<MasterLayoutPage> createState() => _MasterLayoutPageState();
}

class _MasterLayoutPageState extends State<MasterLayoutPage> with TickerProviderStateMixin {
  bool _isRightAligned = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final TransformationController _transformationController = TransformationController();
  bool _isZoomed = false;

  final String imagePath = "assets/master_layout/master_layout.jpg";

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic);
    _fadeController.forward();
    _loadAlignment();
  }

  Future<void> _loadAlignment() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isRightAligned = prefs.getBool('master_layout_btns_right') ?? false);
  }

  Future<void> _saveAlignment() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('master_layout_btns_right', _isRightAligned);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap(TapDownDetails details) {
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
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // MAIN IMAGE VIEWER
            Positioned.fill(
              child: GestureDetector(
                onDoubleTapDown: _handleDoubleTap,
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 1.0,
                  maxScale: 10.0,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  onInteractionEnd: (details) {
                    // Update zoom state if user pinches back to 1.0
                    final scale = _transformationController.value.getMaxScaleOnAxis();
                    if (scale <= 1.01 && _isZoomed) {
                      setState(() => _isZoomed = false);
                    } else if (scale > 1.01 && !_isZoomed) {
                      setState(() => _isZoomed = true);
                    }
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFF9100).withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // PREMIUM NAVIGATION CONTROLS
            AnimatedAlign(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOutQuart,
              alignment: _isRightAligned ? Alignment.bottomRight : Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF9100).withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ExperienceIconButton(
                        icon: Icons.flip_camera_android_rounded,
                        onTap: () {
                          setState(() => _isRightAligned = !_isRightAligned);
                          _saveAlignment();
                        },
                        tooltip: 'Swap Position',
                      ),
                      const SizedBox(width: 12),
                      ExperienceIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.pop(context),
                        isDestructive: true,
                        tooltip: 'Go Back',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExperienceIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
  final String? tooltip;

  const ExperienceIconButton({
    Key? key,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
    this.tooltip,
  }) : super(key: key);

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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDestructive 
                  ? [const Color(0xFFFF9100).withOpacity(0.1), const Color(0xFFFFB74D).withOpacity(0.05)]
                  : [const Color(0xFFFF9100), const Color(0xFFFFB74D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                if (!isDestructive)
                  BoxShadow(
                    color: const Color(0xFFFF9100).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Icon(
              icon, 
              color: isDestructive ? const Color(0xFFFF9100) : Colors.white, 
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

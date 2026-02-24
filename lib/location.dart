import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'locationvideo.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage>
    with TickerProviderStateMixin {
  late AnimationController _imageController;
  late AnimationController _zoomAnimController;
  late Animation<double> _zoomScaleAnimation;
  late Animation<Offset> _zoomOffsetAnimation;

  // --- Current State Variables ---
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  double _rotation = 0.0;

  // --- Session Start Variables (For Gesture Calculation) ---
  Offset _startingOffset = Offset.zero;
  Offset _startingFocalPoint = Offset.zero; // Touch start point on screen
  double _startingScale = 1.0;
  double _startingRotation = 0.0;

  // --- Layout State Variables ---
  bool _isRightAligned = false;
  bool _areButtonsVisible = true;

  @override
  void initState() {
    super.initState();
    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _zoomAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _zoomScaleAnimation = const AlwaysStoppedAnimation(1.0);
    _zoomOffsetAnimation = const AlwaysStoppedAnimation(Offset.zero);

    _zoomAnimController.addListener(() {
      setState(() {
        _scale = _zoomScaleAnimation.value;
        _offset = _zoomOffsetAnimation.value;
      });
    });

    _loadFlipAlignment();

    Future.delayed(const Duration(milliseconds: 200), () {
      _imageController.forward();
    });
  }

  Future<void> _loadFlipAlignment() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool('location_flip_right_aligned');
    if (!mounted) return;
    setState(() => _isRightAligned = saved ?? false);
  }

  Future<void> _saveFlipAlignment() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_flip_right_aligned', _isRightAligned);
  }

  @override
  void dispose() {
    _imageController.dispose();
    _zoomAnimController.dispose();
    super.dispose();
  }

  void _closePage() {
    _imageController.reverse().then((_) {
      Navigator.pop(context);
    });
  }

  void _goToVideoPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationVideo()),
    );
  }

  void _toggleButtonPosition() async {
    setState(() {
      _areButtonsVisible = false;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _isRightAligned = !_isRightAligned;
      _areButtonsVisible = true;
    });

    await _saveFlipAlignment();
  }

  // --- 🛠️ FIXED GESTURE LOGIC ---
  
  // Double-tap zoom state
  bool _isZoomed = false;

  void _handleScaleStart(ScaleStartDetails details) {
    if (_zoomAnimController.isAnimating) return;
    // Jab touch shuru ho, purani values aur touch point save kar lo
    _startingOffset = _offset;
    _startingFocalPoint = details.focalPoint; // Screen par ungli kaha rakhi
    _startingScale = _scale;
    _startingRotation = _rotation;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_zoomAnimController.isAnimating) return;
    setState(() {
      // 1. Zoom Logic (details.scale is relative to start of gesture)
      double tempScale = _startingScale * details.scale;
      // Limits set kiye hain taaki image gayab na ho jaye, range 0.1x se 8.0x
      if (tempScale < 0.1) tempScale = 0.1;
      if (tempScale > 8.0) tempScale = 8.0;
      _scale = tempScale;

      // 2. Rotation Logic (details.rotation is also relative to start)
      _rotation = _startingRotation + details.rotation;

      // 3. Pan/Move Logic (Fixed)
      // Current finger position - Start finger position = Movement Delta
      final Offset delta = details.focalPoint - _startingFocalPoint;
      
      // Purani position me naya delta add karo
      _offset = _startingOffset + delta;
    });
  }

  void _handleDoubleTap(TapDownDetails details) {
    if (_zoomAnimController.isAnimating) return;

    Offset targetOffset;
    double targetScale;

    if (_isZoomed) {
      targetScale = 1.0;
      targetOffset = Offset.zero;
      _isZoomed = false;
    } else {
      final Size screenSize = MediaQuery.of(context).size;
      final localPosition = details.globalPosition;
      
      final centerX = screenSize.width / 2;
      final centerY = screenSize.height / 2;
      
      targetScale = 3.0;
      targetOffset = Offset(
        (centerX - localPosition.dx) * (targetScale - 1),
        (centerY - localPosition.dy) * (targetScale - 1),
      );
      _isZoomed = true;
    }

    _zoomScaleAnimation = Tween<double>(begin: _scale, end: targetScale).animate(
      CurvedAnimation(parent: _zoomAnimController, curve: Curves.easeInOutCubic),
    );
    _zoomOffsetAnimation = Tween<Offset>(begin: _offset, end: targetOffset).animate(
      CurvedAnimation(parent: _zoomAnimController, curve: Curves.easeInOutCubic),
    );

    _zoomAnimController.forward(from: 0.0);
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFF9100),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// 1. Background Image (Movable, Zoomable, Rotatable)
          Positioned.fill(
            child: GestureDetector(
              onDoubleTapDown: _handleDoubleTap,
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              behavior: HitTestBehavior.translucent, // Ensures touches everywhere are detected
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _imageController,
                  curve: Curves.easeInOut,
                ),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent, // Transparent needed for hit testing
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translate(_offset.dx, _offset.dy) // Move first
                      ..rotateZ(_rotation)               // Then Rotate
                      ..scale(_scale),                   // Then Scale
                    child: Image.asset(
                      'assets/location/location.jpg',
                      fit: BoxFit.contain, // Shows full image
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// 2. Floating Buttons (Close, Play, Flip)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 10),
            bottom: 40,
            left: _isRightAligned ? null : 20,
            right: _isRightAligned ? 20 : null,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _areButtonsVisible ? 1.0 : 0.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCircleButton(
                    icon: Icons.close,
                    onTap: _closePage,
                  ),
                  const SizedBox(width: 15),
                  _buildCircleButton(
                    icon: Icons.play_arrow,
                    onTap: _goToVideoPage,
                  ),
                  const SizedBox(width: 15),
                  _buildCircleButton(
                    icon: Icons.swap_horiz,
                    onTap: _toggleButtonPosition,
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

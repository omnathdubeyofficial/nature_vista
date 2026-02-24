import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'walkthrough.dart';

class TourVideoPage extends StatefulWidget {
  const TourVideoPage({Key? key}) : super(key: key);

  @override
  State<TourVideoPage> createState() => _TourVideoPageState();
}

class _TourVideoPageState extends State<TourVideoPage> with TickerProviderStateMixin {
  bool _isSwapped = false;
  double _controlsOpacity = 1.0;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  
  late final AnimationController _swapController;
  late final Animation<double> _swapAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();

    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _swapAnimation = CurvedAnimation(
      parent: _swapController,
      curve: Curves.easeInOutBack,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _swapController.dispose();
    super.dispose();
  }

  void _handleSwap() async {
    // START FADE OUT
    setState(() {
      _controlsOpacity = 0.0;
    });

    // Wait for fade out to complete fully
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _isSwapped = !_isSwapped;
      if (_isSwapped) {
        _swapController.forward();
      } else {
        _swapController.reverse();
      }
    });

    // Small delay to let layout settle
    await Future.delayed(const Duration(milliseconds: 100));

    // START FADE IN
    setState(() {
      _controlsOpacity = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // BACKGROUND SCROLL IMAGE (Full Visibility)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: Image.asset(
                  'assets/newback/tourbackgaund.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.brown.shade900),
                ),
              ),
            ),

            // SIDE-BY-SIDE CONTENT ANIMATED
            Positioned.fill(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _controlsOpacity,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    textDirection: _isSwapped ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      // BUTTONS COLUMN
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _videoButton('CITY REVEALER', Icons.play_circle_fill_rounded, 'assets/tourvideo/Ayodhya City Revealer CGI HD.mp4'),
                          const SizedBox(height: 18),
                          _videoButton('CITY TEASER 1', Icons.play_circle_fill_rounded, 'assets/tourvideo/Ayodhya City Teaser 1.mp4'),
                          const SizedBox(height: 18),
                          _videoButton('CITY TEASER 2', Icons.play_circle_fill_rounded, 'assets/tourvideo/Ayodhya City Teaser 2.mp4'),
                          const SizedBox(height: 18),
                          _videoButton('LOGO FORMATION', Icons.play_circle_fill_rounded, 'assets/tourvideo/Ayodhya Logo Formation vvv2.mp4'),
                          const SizedBox(height: 18),
                          _videoButton('WALKTHROUGH TOUR', Icons.play_circle_fill_rounded, 'assets/tourvideo/wolkthrow.mp4'),
                          const SizedBox(height: 35),
                          // SWAP & BACK BUTTONS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _circleIcon(
                                icon: Icons.arrow_back_rounded,
                                onTap: () => Navigator.pop(context),
                                tooltip: 'Go Back',
                              ),
                              const SizedBox(width: 20),
                              _circleIcon(
                                icon: Icons.swap_horiz_rounded,
                                onTap: _handleSwap,
                                tooltip: 'Swap Side',
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      // PRECISE GAP
                      const SizedBox(width: 80),
                      
                      // LOGO COLUMN
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Hero(
                            tag: 'app_logo',
                            child: Image.asset(
                              'assets/images/ffe8add9-2237-444a-b0f0-6b9d75af6337-1.png',
                              width: 230, // Slightly smaller for better tightness
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
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

  Widget _animatedPositionedControl({required int index, required Widget child}) {
    // Corrected for swap logic inside the new layout
    return Positioned(child: child);
  }

  Widget _videoButton(String label, IconData icon, String videoPath) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WalkthroughPage(videoPath: videoPath)),
      ),
      child: SizedBox(
        width: 320,
        height: 60,
        child: CustomPaint(
          painter: ScallopedButtonPainter(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 15),
                Text(
                  label,
                  style: GoogleFonts.cinzel(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleIcon({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFF9100), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFFFF9100), size: 30),
        ),
      ),
    );
  }
}

class ScallopedButtonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height, paint = Paint();
    final path = Path();
    final double bumpSize = h / 3;

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

    paint.shader = const LinearGradient(
      colors: [Color(0xFFFF9100), Color(0xFFFF6D00)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

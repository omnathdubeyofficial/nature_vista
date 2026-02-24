import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';
import 'hero.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // MediaKit Controllers
  late final Player _player;
  late final VideoController _videoController;
  
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      // Create a Player instance
      _player = Player();
      // Create a VideoController instance
      _videoController = VideoController(
        _player, 
        configuration: const VideoControllerConfiguration(
          enableHardwareAcceleration: true,
        ),
      );

      String videoPath;
      if (Platform.isWindows) {
        // On Windows, load directly from the executable's relative path for "mini second" loading
        final String exeDir = File(Platform.resolvedExecutable).parent.path;
        videoPath = "$exeDir\\data\\flutter_assets\\assets/tourvideo/wolkthrow.mp4";
        
        // Fallback for debug mode or if the file isn't at the expected production path
        if (!await File(videoPath).exists()) {
          debugPrint("Production video path not found, falling back to asset loading...");
          final byteData = await rootBundle.load('assets/tourvideo/wolkthrow.mp4');
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/bg.mp4');
          await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
          videoPath = file.path;
        }
      } else {
        // For other platforms, keep existing logic
        final byteData = await rootBundle.load('assets/tourvideo/wolkthrow.mp4');
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/bg.mp4');
        await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
        videoPath = file.path;
      }

      // Configure playback BEFORE opening to ensure settings apply
      await _player.setVolume(100); // Unmuted as requested
      await _player.setPlaylistMode(PlaylistMode.loop); // Loop indefinitely

      // Open and Play
      await _player.open(Media(videoPath), play: true);
      
      // Force play again just in case 'play: true' didn't catch
      await _player.play();

      setState(() {
        _videoReady = true;
      });
    } catch (e) {
      debugPrint("Error initializing MediaKit video: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _goToHeroPage() {
    // Stop video to save resources
    _player.pause();
    
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const HeroPage(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ).then((_) {
      // Resume video when returning
      _player.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🎥 VIDEO BACKGROUND
          Positioned.fill(
            child: _videoReady
                ? SizedBox.expand(
                    child: Video(
                      controller: _videoController,
                      controls: null,
                      fit: BoxFit.cover, 
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
          ),

          // 🌑 DARK OVERLAY
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),

          // 🔘 EXPLORE BUTTON (SCALLOPED DESIGN)
          Positioned(
            bottom: 60, // Raised slightly for better visibility
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _goToHeroPage,
                child: SizedBox(
                  width: 280, // Increased width for the "Explore More" text
                  height: 65, // Standard height for this design
                  child: CustomPaint(
                    painter: ScallopedButtonPainter(),
                    child: Center(
                      child: Text(
                        'EXPLORE MORE',
                        style: GoogleFonts.cinzel(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2.0,
                          shadows: [
                             Shadow(
                               color: Colors.black.withOpacity(0.3),
                               offset: const Offset(0, 2),
                               blurRadius: 2
                             )
                          ]
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// THE CUSTOM PAINTER (The "3-Bump" Scallop Shape - Exact Replica)
// --------------------------------------------------------------------------
class ScallopedButtonPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint();

    // COLOR: Solid Orange (Exact match from your previous request)
    final Color activeColor = const Color(0xFFFF9100); 
    
    final path = Path();
    // Bumps size logic
    final double bumpSize = h / 2.8; 

    // 1. Start Top-Left (inset to allow for bumps)
    path.moveTo(bumpSize, 0);
    
    // 2. Top Line
    path.lineTo(w - bumpSize, 0);
    
    // 3. Right Side Bumps (Three Curves)
    // Top Bump
    path.quadraticBezierTo(w, bumpSize * 0.5, w - (bumpSize * 0.2), bumpSize);
    // Middle Bump (Larger protrusion)
    path.quadraticBezierTo(w + (bumpSize * 0.2), h * 0.5, w - (bumpSize * 0.2), h - bumpSize);
    // Bottom Bump
    path.quadraticBezierTo(w, h - (bumpSize * 0.5), w - bumpSize, h);

    // 4. Bottom Line
    path.lineTo(bumpSize, h);

    // 5. Left Side Bumps (Mirror of Right)
    // Bottom Bump
    path.quadraticBezierTo(0, h - (bumpSize * 0.5), bumpSize * 0.2, h - bumpSize);
    // Middle Bump
    path.quadraticBezierTo(-(bumpSize * 0.2), h * 0.5, bumpSize * 0.2, bumpSize);
    // Top Bump
    path.quadraticBezierTo(0, bumpSize * 0.5, bumpSize, 0);

    path.close();

    // PAINT FILL
    paint.color = activeColor;
    paint.style = PaintingStyle.fill;
    
    // ADD SHADOW for depth (Optional but looks better on video bg)
    canvas.drawShadow(path, Colors.black.withOpacity(0.4), 8.0, true);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

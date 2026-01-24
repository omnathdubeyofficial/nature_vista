import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'hero.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  late AnimationController bgCtrl;
  late AnimationController glowCtrl;
  late AnimationController loopCtrl;

  final images = List.generate(5, (_) => 'assets/img/image.png');

  static const double imageGap = 40;
  static const int loopSeconds = 20;

  @override
  void initState() {
    super.initState();

    bgCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 14))
          ..repeat();

    glowCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);

    loopCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: loopSeconds))
          ..repeat();
  }

  @override
  void dispose() {
    bgCtrl.dispose();
    glowCtrl.dispose();
    loopCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final imageHeight = size.height * 0.42;
    final imageWidth = imageHeight * 0.65;
    final totalItemWidth = imageWidth + imageGap;
    final loopWidth = totalItemWidth * images.length;

    return Scaffold(
      backgroundColor: const Color(0xFF120101),
      body: Stack(
        children: [
          // BACKGROUND
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2B0000),
                    Color(0xFF7A0A0A),
                    Color(0xFFFF9800),
                  ],
                ),
              ),
            ),
          ),

          // RAYS
          AnimatedBuilder(
            animation: bgCtrl,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: DivineRaysPainter(bgCtrl.value),
            ),
          ),

          // 🔁 CONTINUOUS IMAGE LOOP WITH GAP
          Positioned(
            top: size.height * .26,
            left: 0,
            right: 0,
            height: imageHeight,
            child: AnimatedBuilder(
              animation: loopCtrl,
              builder: (_, __) {
                final offsetX = loopCtrl.value * loopWidth;

                return Stack(
                  children: List.generate(images.length * 2, (i) {
                    final x = (i * totalItemWidth - offsetX) % loopWidth;

                    return Positioned(
                      left: x,
                      child: AnimatedBuilder(
                        animation: glowCtrl,
                        builder: (_, __) => Transform.scale(
                          scale: 1 + glowCtrl.value * 0.03,
                          child: Image.asset(
                            images[i % images.length],
                            height: imageHeight,
                            width: imageWidth,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),

          const ParticleOverlay(),

          // TITLE
          Positioned(
            top: size.height * .1,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  "JAI SHREE RAM",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    letterSpacing: 6,
                    color: Colors.amberAccent,
                  ),
                ),
                const SizedBox(height: 12),
                ShaderMask(
                  shaderCallback: (r) => const LinearGradient(
                    colors: [Colors.amber, Colors.white, Colors.amber],
                  ).createShader(r),
                  child: Text(
                    "AYODHYA",
                    style: GoogleFonts.cinzel(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // BUTTON
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(child: _startButton()),
          ),
        ],
      ),
    );
  }

  Widget _startButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(60),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HeroPage()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFA000), Color(0xFFFFD54F)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(.6),
              blurRadius: 40,
            ),
          ],
        ),
        child: Text(
          "Start Journey",
          style: GoogleFonts.cinzel(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3A0000),
          ),
        ),
      ),
    );
  }
}

/* ================= DIVINE RAYS ================= */

class DivineRaysPainter extends CustomPainter {
  final double value;
  DivineRaysPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .3);
    final paint = Paint()
      ..color = Colors.amber.withOpacity(.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);

    for (int i = 0; i < 14; i++) {
      final angle = (i * 25 + value * 25) * pi / 180;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(center.dx + 1200 * cos(angle - .08),
            center.dy + 1200 * sin(angle - .08))
        ..lineTo(center.dx + 1200 * cos(angle + .08),
            center.dy + 1200 * sin(angle + .08))
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

/* ================= PARTICLES ================= */

class ParticleOverlay extends StatefulWidget {
  const ParticleOverlay({Key? key}) : super(key: key);

  @override
  State<ParticleOverlay> createState() => _ParticleOverlayState();
}

class _ParticleOverlayState extends State<ParticleOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController ctrl;

  final particles =
      List.generate(30, (_) => Offset(Random().nextDouble(), Random().nextDouble()));

  @override
  void initState() {
    super.initState();
    ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => CustomPaint(
        size: Size.infinite,
        painter: ParticlePainter(particles, ctrl.value),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Offset> particles;
  final double progress;

  ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.amberAccent.withOpacity(.4);

    for (final p in particles) {
      final y = (p.dy + progress) % 1;
      canvas.drawCircle(
        Offset(p.dx * size.width, y * size.height),
        2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

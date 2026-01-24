import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart';

class GardenPage extends StatefulWidget {
  const GardenPage({Key? key}) : super(key: key);

  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  bool _isTransitioning = false;
  bool _imagesPreloaded = false;
  late AnimationController _buttonAnimationController;

  final List<Map<String, String>> _gardenData = [
    {
      'image': 'assets/build/Cafe Area.jpg',
      'title': 'Cafe & Relaxation Zone',
    },
    {
      'image': 'assets/build/Kidsplay cam.jpg',
      'title': 'Kids Play Area',
    },
    {
      'image': 'assets/build/CAM STORY WALK.jpg',
      'title': 'Nature Walkway',
    },
    {
      'image': 'assets/build/Aerial Cam .jpg',
      'title': 'Aerial Green View',
    },
    {
      'image': 'assets/build/Entry Gate Cam.jpg',
      'title': 'Grand Entrance',
    },
  ];

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPreloaded) {
      _precacheImages();
      _imagesPreloaded = true;
    }
  }

  Future<void> _precacheImages() async {
    for (var data in _gardenData) {
      try {
        await precacheImage(AssetImage(data['image']!), context);
      } catch (e) {
        debugPrint('Error precaching image: ${data['image']}');
      }
    }
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _goToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
      (route) => false,
    );
  }

  void _changePage(int newPage) {
    if (_isTransitioning || newPage < 0 || newPage >= _gardenData.length) return;

    setState(() {
      _isTransitioning = true;
      _currentPage = newPage;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isTransitioning = false);
    });
  }

  void _nextPage() {
    if (_currentPage < _gardenData.length - 1 && !_isTransitioning) {
      _changePage(_currentPage + 1);
    }
  }

  void _previousPage() {
    if (_currentPage > 0 && !_isTransitioning) {
      _changePage(_currentPage - 1);
    }
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
    double opacity = 1.0,
  }) {
    return GestureDetector(
      onTap: opacity > 0.5 ? onTap : null,
      child: AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 300),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (_isTransitioning) return;
          final velocity = details.primaryVelocity ?? 0;
          if (velocity > 300) _previousPage();
          else if (velocity < -300) _nextPage();
        },
        child: Stack(
          children: [
            // Background Animation
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Container(
                key: ValueKey<int>(_currentPage),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_gardenData[_currentPage]['image']!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0), // Optional: blur background for depth
                  child: Container(color: Colors.black.withOpacity(0.0)),
                ),
              ),
            ),

            // Top Left Title
            Positioned(
              top: 50,
              left: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _gardenData[_currentPage]['title']!,
                        key: ValueKey<String>(_gardenData[_currentPage]['title']!),
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Navigation Indicators & Controls
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Back Button
                      _buildGlassButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 15),
                      // Home Button
                      _buildGlassButton(
                        icon: Icons.home_rounded,
                        onTap: _goToHome,
                      ),
                    ],
                  ),
                  
                  // Pagination Controls
                  Row(
                    children: [
                       _buildGlassButton(
                        icon: Icons.chevron_left_rounded,
                        onTap: _previousPage,
                        opacity: _currentPage > 0 ? 1.0 : 0.3,
                      ),
                       const SizedBox(width: 15),
                       _buildGlassButton(
                        icon: Icons.chevron_right_rounded,
                        onTap: _nextPage,
                        opacity: _currentPage < _gardenData.length - 1 ? 1.0 : 0.3,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'home.dart';

// class GardenPage extends StatefulWidget {
//   const GardenPage({Key? key}) : super(key: key);

//   @override
//   State<GardenPage> createState() => _GardenPageState();
// }

// class _GardenPageState extends State<GardenPage> {
//   late TransformationController _transformationController;

//   @override
//   void initState() {
//     super.initState();
//     _transformationController = TransformationController();
//   }

//   @override
//   void dispose() {
//     _transformationController.dispose();
//     super.dispose();
//   }

//   void _goToHome() {
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => const HomePage()),
//       (route) => false,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           /// Garden Image with Zoom
//           Positioned.fill(
//             child: InteractiveViewer(
//               transformationController: _transformationController,
//               panEnabled: true,
//               scaleEnabled: true,
//               minScale: 1.0,
//               maxScale: 5.0,
//               child: Image.asset(
//                 'assets/images/garden.jpg', // Garden ki image
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),

//           /// Top Bar
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.black.withOpacity(0.7),
//                     Colors.transparent,
//                   ],
//                 ),
//               ),
//               child: SafeArea(
//                 child: Row(
//                   children: [
//                     IconButton(
//                       onPressed: () => Navigator.pop(context),
//                       icon: const Icon(Icons.arrow_back, color: Colors.white),
//                     ),
//                     const SizedBox(width: 10),
//                     const Text(
//                       'Garden',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           /// Bottom Buttons
//           Positioned(
//             bottom: 40,
//             left: 20,
//             child: Row(
//               children: [
//                 /// Close Button
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: Container(
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       color: Colors.redAccent,
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.redAccent.withOpacity(0.4),
//                           blurRadius: 8,
//                           spreadRadius: 2,
//                         ),
//                       ],
//                     ),
//                     child: const Icon(
//                       Icons.close,
//                       color: Colors.white,
//                       size: 28,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 15),

//                 /// Home Button
//                 GestureDetector(
//                   onTap: _goToHome,
//                   child: Container(
//                     padding: const EdgeInsets.all(14),
//                     decoration: BoxDecoration(
//                       color: Colors.blue,
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.blue.withOpacity(0.4),
//                           blurRadius: 8,
//                           spreadRadius: 2,
//                         ),
//                       ],
//                     ),
//                     child: const Icon(
//                       Icons.home,
//                       color: Colors.white,
//                       size: 28,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

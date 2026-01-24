import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart';

class TennisCourtPage extends StatefulWidget {
  const TennisCourtPage({Key? key}) : super(key: key);

  @override
  State<TennisCourtPage> createState() => _TennisCourtPageState();
}

class _TennisCourtPageState extends State<TennisCourtPage>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  bool _isTransitioning = false;
  bool _imagesPreloaded = false;
  late AnimationController _buttonAnimationController;

  final List<Map<String, String>> _buildingData = [
    {
      'image': 'assets/build/Aerial Cam .jpg',
      'title': 'Aerial Cam',
    },
    {
      'image': 'assets/build/Balcony Cam_Day.jpg',
      'title': 'Balcony Cam Day',
    },
    {
      'image': 'assets/build/Balcony_Cam Night.jpg',
      'title': 'Balcony Cam Night',
    },
    {
      'image': 'assets/build/Cafe Area.jpg',
      'title': 'Cafe Area',
    },
    {
      'image': 'assets/build/CAM STORY WALK.jpg',
      'title': 'Cam Story Walk',
    },
    {
      'image': 'assets/build/Entry Gate Cam.jpg',
      'title': 'Entry Gate Cam',
    },
    {
      'image': 'assets/build/Hero Cam.jpg',
      'title': 'Hero Cam',
    },
    {
      'image': 'assets/build/Kidsplay cam.jpg',
      'title': 'Kidsplay Cam',
    },
    {
      'image': 'assets/build/Music Cam.jpg',
      'title': 'Music Cam',
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
    // Preload images only once when the widget is first built
    if (!_imagesPreloaded) {
      _precacheImages();
      _imagesPreloaded = true;
    }
  }

  // Preload all images for smooth transitions
  Future<void> _precacheImages() async {
    for (var data in _buildingData) {
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
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
  }

  void _changePage(int newPage) {
    if (_isTransitioning || newPage < 0 || newPage >= _buildingData.length) {
      return;
    }

    setState(() {
      _isTransitioning = true;
      _currentPage = newPage;
    });

    // Extended delay for smooth, slow animation
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _isTransitioning = false;
        });
      }
    });
  }

  void _nextPage() {
    if (_currentPage < _buildingData.length - 1 && !_isTransitioning) {
      _changePage(_currentPage + 1);
    }
  }

  void _previousPage() {
    if (_currentPage > 0 && !_isTransitioning) {
      _changePage(_currentPage - 1);
    }
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
    double opacity = 1.0,
  }) {
    return GestureDetector(
      onTapDown: (_) {
        if (opacity > 0.5) {
          _buttonAnimationController.forward();
        }
      },
      onTapUp: (_) {
        if (opacity > 0.5) {
          _buttonAnimationController.reverse();
          onTap();
        }
      },
      onTapCancel: () => _buttonAnimationController.reverse(),
      child: AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 28,
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

          if (velocity > 300) {
            _previousPage();
          } else if (velocity < -300) {
            _nextPage();
          }
        },
        child: Stack(
          children: [
            /// Background Image (Static Fallback)
            Positioned.fill(
              child: RepaintBoundary(
                child: Image.asset(
                  'assets/images/hero.png',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
                ),
              ),
            ),

            /// Smooth Fade In/Out Transition - NO JERKY MOTION
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              reverseDuration: const Duration(milliseconds: 800),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: <Widget>[
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              transitionBuilder: (Widget child, Animation<double> animation) {
                // Pure Fade Transition - Smooth and Slow
                return FadeTransition(
                  opacity: Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: child,
                );
              },
              child: RepaintBoundary(
                key: ValueKey<int>(_currentPage),
                child: InteractiveViewer(
                  panEnabled: true,
                  scaleEnabled: true,
                  minScale: 1.0,
                  maxScale: 4.0,
                  boundaryMargin: EdgeInsets.zero,
                  constrained: true,
                  clipBehavior: Clip.none,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black,
                    child: Image.asset(
                      _buildingData[_currentPage]['image']!,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      cacheWidth: 1920,
                      cacheHeight: 1080,
                      isAntiAlias: true,
                      gaplessPlayback: true, // Critical for smooth transitions
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.black,
                          child: const Center(
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.white54,
                              size: 48,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            /// Top Left Title with Smooth Animation
            Positioned(
              top: 50,
              left: 20,
              child: RepaintBoundary(
                child: AnimatedOpacity(
                  opacity: _isTransitioning ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: Text(
                            _buildingData[_currentPage]['title']!,
                            key: ValueKey<String>(
                              _buildingData[_currentPage]['title']!,
                            ),
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// Bottom Navigation Buttons with Enhanced Styling
            Positioned(
              bottom: 40,
              left: 20,
              child: RepaintBoundary(
                child: AnimatedOpacity(
                  opacity: _isTransitioning ? 0.5 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Row(
                    children: [
                      /// Close Button
                      _buildNavigationButton(
                        icon: Icons.close_rounded,
                        backgroundColor: Colors.redAccent,
                        iconColor: Colors.white,
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(width: 14),

                      /// Home Button
                      _buildNavigationButton(
                        icon: Icons.home_rounded,
                        backgroundColor: Colors.white,
                        iconColor: Colors.black,
                        onTap: _goToHome,
                      ),
                      const SizedBox(width: 14),

                      /// Previous Button
                      _buildNavigationButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        backgroundColor: Colors.white,
                        iconColor: Colors.black,
                        onTap: _previousPage,
                        opacity: _currentPage > 0 ? 1.0 : 0.35,
                      ),
                      const SizedBox(width: 14),

                      /// Next Button
                      _buildNavigationButton(
                        icon: Icons.arrow_forward_ios_rounded,
                        backgroundColor: Colors.white,
                        iconColor: Colors.black,
                        onTap: _nextPage,
                        opacity:
                            _currentPage < _buildingData.length - 1 ? 1.0 : 0.35,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// Page Indicator with Smooth Transitions
            Positioned(
              bottom: 40,
              right: 20,
              child: RepaintBoundary(
                child: AnimatedOpacity(
                  opacity: _isTransitioning ? 0.3 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: Text(
                            '${_currentPage + 1}/${_buildingData.length}',
                            key: ValueKey<int>(_currentPage),
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
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
      ),
    );
  }
}




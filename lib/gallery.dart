import 'package:flutter/material.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> with TickerProviderStateMixin {
  final List<String> _images = [
    'assets/build/Aerial Cam .jpg',
    'assets/build/Balcony Cam_Day.jpg',
    'assets/build/Balcony_Cam Night.jpg',
    'assets/build/Cafe Area.jpg',
    'assets/build/CAM STORY WALK.jpg',
    'assets/build/Entry Gate Cam.jpg',
    'assets/build/Hero Cam.jpg',
    'assets/build/Kidsplay_cam.jpg',
    'assets/build/Music_Cam.jpg',
    'assets/gallery/Club house cam.png',
    'assets/gallery/Common Bedroom (untag).jpg',
    'assets/gallery/Entrance_lobby_cam02.jpg ( Untag ).jpg',
    'assets/gallery/Entrance_lobby+1 (untag).jpg',
    'assets/gallery/Kitchen (untag).jpg',
    'assets/gallery/Living room (untag).jpg',
    'assets/gallery/Master bedroom (untag).jpg',
  ];

  int _index = 0;
  bool _isGridVisible = true;
  bool _isSwapped = false;
  final TransformationController _transformationController = TransformationController();
  late final AnimationController _pageAnimController;
  late final Animation<double> _pageFade;
  late final Animation<double> _pageScale;
  
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _pageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pageFade = CurvedAnimation(parent: _pageAnimController, curve: Curves.easeOut);
    _pageScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _pageAnimController, curve: Curves.easeOut),
    );

    _pageAnimController.forward();
  }

  @override
  void dispose() {
    _pageAnimController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _selectImage(int newIndex) {
    if (_index == newIndex) return;
    _transformationController.value = Matrix4.identity();
    setState(() {
      _index = newIndex;
    });
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails!.localPosition;
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomHeight = size.height * 0.11; // Reduced by 50%

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _pageFade,
        child: ScaleTransition(
          scale: _pageScale,
          child: Column(
            children: [
              // 1. TOP AREA
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onDoubleTapDown: (details) => _doubleTapDetails = details,
                        onDoubleTap: _handleDoubleTap,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) {
                            final offsetAnimation = Tween<Offset>(
                              begin: const Offset(0.0, 1.0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ));
                            return SlideTransition(
                              position: offsetAnimation,
                              child: FadeTransition(opacity: animation, child: child),
                            );
                          },
                          child: InteractiveViewer(
                            key: ValueKey<int>(_index),
                            transformationController: _transformationController,
                            minScale: 1.0,
                            maxScale: 5.0,
                            child: SizedBox.expand(
                              child: Image.asset(
                                _images[_index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Floating Unified Control Bar
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Row(
                        textDirection: _isSwapped ? TextDirection.rtl : TextDirection.ltr,
                        children: [
                          _navButton(
                            icon: _isSwapped ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_new_rounded,
                            onTap: () => Navigator.pop(context),
                            size: 45,
                            backgroundColor: Colors.orange.shade800,
                            iconColor: Colors.white,
                            tooltip: 'Back',
                          ),
                          const SizedBox(width: 15),
                          _navButton(
                            icon: _isGridVisible ? Icons.visibility_off_rounded : Icons.grid_view_rounded,
                            onTap: () => setState(() => _isGridVisible = !_isGridVisible),
                            size: 45,
                            backgroundColor: Colors.white,
                            iconColor: Colors.orange.shade800,
                            borderColor: Colors.orange.shade800,
                            tooltip: _isGridVisible ? 'Hide Grid' : 'Show Grid',
                          ),
                          const SizedBox(width: 15),
                          _navButton(
                            icon: Icons.flip_camera_android_rounded,
                            onTap: () => setState(() => _isSwapped = !_isSwapped),
                            size: 45,
                            backgroundColor: Colors.white,
                            iconColor: Colors.orange.shade800,
                            borderColor: Colors.orange.shade800,
                            tooltip: 'Swap Layout',
                          ),
                          const SizedBox(width: 15),
                          _navButton(
                            icon: Icons.chevron_left_rounded,
                            onTap: () => _selectImage((_index - 1 + _images.length) % _images.length),
                            size: 45,
                            backgroundColor: Colors.white,
                            iconColor: Colors.orange.shade800,
                            borderColor: Colors.orange.shade800,
                            tooltip: 'Previous',
                          ),
                          const SizedBox(width: 15),
                          _navButton(
                            icon: Icons.chevron_right_rounded,
                            onTap: () => _selectImage((_index + 1) % _images.length),
                            size: 45,
                            backgroundColor: Colors.white,
                            iconColor: Colors.orange.shade800,
                            borderColor: Colors.orange.shade800,
                            tooltip: 'Next',
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. BOTTOM GRID AREA
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutCubic,
                height: _isGridVisible ? bottomHeight : 0,
                width: size.width,
                color: Colors.white,
                child: Column(
                  children: [
                    // Thumbnail Grid
                    if (_isGridVisible)
                      Expanded(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 400),
                          opacity: _isGridVisible ? 1.0 : 0.0,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _images.length,
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              final isSelected = _index == index;
                              return GestureDetector(
                                onTap: () => _selectImage(index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: EdgeInsets.only(right: 4, left: index == 0 ? 0 : 0),
                                  width: bottomHeight * 1.5,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected ? Colors.orange : Colors.transparent,
                                      width: 4,
                                    ),
                                    image: DecorationImage(
                                      image: AssetImage(_images[index]),
                                      fit: BoxFit.cover,
                                      colorFilter: isSelected
                                          ? null
                                          : ColorFilter.mode(
                                              Colors.white.withOpacity(0.2),
                                              BlendMode.lighten,
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            },
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

  Widget _navButton({
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
    double size = 60,
    Color backgroundColor = Colors.black45,
    Color iconColor = Colors.white,
    Color? borderColor,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.3,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: borderColor != null ? Border.all(color: borderColor, width: 2) : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: size * 0.45),
          ),
        ),
      ),
    );
  }
}


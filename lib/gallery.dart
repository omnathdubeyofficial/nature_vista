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
    'assets/build/Kidsplay cam.jpg',
    'assets/build/Music Cam.jpg',
    'assets/gallery/Club house cam.png',
    'assets/gallery/Common Bedroom (untag).jpg',
    'assets/gallery/Entrance_lobby_cam02.jpg ( Untag ).jpg',
    'assets/gallery/Entrance_lobby+1 (untag).jpg',
    'assets/gallery/Kitchen (untag).jpg',
    'assets/gallery/Living room (untag).jpg',
        'assets/gallery/Master bedroom (untag).jpg',
  ];

  int _index = 0;

  late final AnimationController _pageAnimController;
  late final Animation<double> _pageFade;
  late final Animation<double> _pageScale;

  static const Duration _imgTransitionDuration = Duration(milliseconds: 420);

  @override
  void initState() {
    super.initState();
    _pageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _pageFade = CurvedAnimation(parent: _pageAnimController, curve: Curves.easeOut);
    _pageScale = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(parent: _pageAnimController, curve: Curves.easeOut),
    );

    _pageAnimController.forward();
  }

  @override
  void dispose() {
    _pageAnimController.dispose();
    super.dispose();
  }

  void _showNext() {
    if (_index < _images.length - 1) {
      setState(() => _index += 1);
    }
  }

  void _showPrev() {
    if (_index > 0) {
      setState(() => _index -= 1);
    }
  }

  Future<void> _close() async {
    await _pageAnimController.reverse();
    if (mounted) Navigator.pop(context);
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0.0;
    if (velocity < -400) {
      _showNext();
    } else if (velocity > 400) {
      _showPrev();
    }
  }

  Widget _imageTransitionBuilder(Widget child, Animation<double> animation) {
    final fade = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
    final scale = Tween<double>(begin: 0.995, end: 1.0).animate(fade);
    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(scale: scale, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: FadeTransition(
        opacity: _pageFade,
        child: ScaleTransition(
          scale: _pageScale,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragEnd: _handleDragEnd,
                  child: AnimatedSwitcher(
                    duration: _imgTransitionDuration,
                    transitionBuilder: _imageTransitionBuilder,
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    child: InteractiveViewer(
                      key: ValueKey<int>(_index),
                      panEnabled: true,
                      scaleEnabled: true,
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: SizedBox.expand(
                        child: Image.asset(
                          _images[_index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 34,
                left: 0,
                right: 0,
                child: SafeArea(
                  minimum: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _circleControl(
                        icon: Icons.chevron_left,
                        onTap: _showPrev,
                        enabled: _index > 0,
                        size: 64,
                      ),
                      const SizedBox(width: 24),
                      _circleControl(
                        icon: Icons.close,
                        onTap: _close,
                        backgroundColor: Colors.white,
                        iconColor: Colors.black,
                        size: 64,
                        elevation: 8,
                      ),
                      const SizedBox(width: 24),
                      _circleControl(
                        icon: Icons.chevron_right,
                        onTap: _showNext,
                        enabled: _index < _images.length - 1,
                        size: 64,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleControl({
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
    Color backgroundColor = const Color(0x66000000),
    Color iconColor = Colors.white,
    double size = 54,
    double elevation = 4,
  }) {
    final effectiveBg = enabled ? backgroundColor : backgroundColor.withOpacity(0.28);
    final effectiveIcon = enabled ? iconColor : iconColor.withOpacity(0.4);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: effectiveBg,
          shape: BoxShape.circle,
          boxShadow: elevation > 0
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    blurRadius: elevation,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Icon(icon, color: effectiveIcon, size: size * 0.5),
        ),
      ),
    );
  }
}

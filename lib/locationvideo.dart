import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationVideo extends StatefulWidget {
  const LocationVideo({Key? key}) : super(key: key);

  @override
  State<LocationVideo> createState() => _LocationVideoState();
}

class _LocationVideoState extends State<LocationVideo>
    with TickerProviderStateMixin {
  Player? _player;
  VideoController? _videoController;
  File? _cachedVideoFile;

  bool _isMuted = false;
  bool _showControls = true;
  bool _isLoading = true;

  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _loadFlipAlignment();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final byteData = await rootBundle.load('assets/images/location.mp4');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/location.mp4');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      _cachedVideoFile = file;

      final player = Player();
      final controller = VideoController(player);

      await player.open(Media(file.path), play: true);
      await player.setVolume(100);

      // Loop playback automatically
      player.stream.completed.listen((_) async {
        await player.seek(Duration.zero);
        await player.play();
      });

      setState(() {
        _player = player;
        _videoController = controller;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Video init error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFlipAlignment() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool('locationvideo_flip_right_aligned');
    if (!mounted) return;
    setState(() => _isControlsRightAligned = saved ?? false);
  }

  Future<void> _saveFlipAlignment() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('locationvideo_flip_right_aligned', _isControlsRightAligned);
  }

  @override
  void dispose() {
    _player?.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_player == null) return;
    if (_player!.state.playing) {
      _player!.pause();
    } else {
      _player!.play();
    }
    setState(() {});
  }

  void _seekForward() async {
    if (_player == null) return;
    final pos = _player!.state.position;
    await _player!.seek(pos + const Duration(seconds: 10));
  }

  void _seekBackward() async {
    if (_player == null) return;
    final pos = _player!.state.position;
    await _player!.seek(pos - const Duration(seconds: 10));
  }

  /// 🔄 Auto-hide logic
  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _onUserInteraction() {
    if (!_showControls) {
      setState(() => _showControls = true);
    }
    _startHideTimer();
  }

  bool _isFullScreen = false;

  // Flip Layout State
  // Default is LEFT aligned (false = left, true = right)
  bool _isControlsRightAligned = false; 
  
  // Animation state for flipping content
  bool _isContentVisible = true;
  Duration _layoutDuration = const Duration(milliseconds: 600);

  void _handleFlip() async {
    setState(() {
      _isContentVisible = false; // Fade out
    });

    Future.delayed(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      setState(() {
        _isControlsRightAligned = !_isControlsRightAligned; // Flip side
      });

      await _saveFlipAlignment();

      Future.delayed(const Duration(milliseconds: 50), () {
        if (!mounted) return;
        setState(() {
          _isContentVisible = true; // Fade in
        });
      });
    });
  }

  /// 🔄 Toggle Fullscreen
  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black, // Cinema background
      body: GestureDetector(
        onTap: _onUserInteraction,
        child: Stack(
          children: [
            /// 🎥 Main Video Container
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                width: _isFullScreen ? size.width : size.width * 0.9,
                height: _isFullScreen ? size.height : size.height * 0.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_isFullScreen ? 0 : 30),
                  boxShadow: _isFullScreen
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 40,
                            spreadRadius: 2,
                          ),
                        ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_isFullScreen ? 0 : 30),
                  child: Stack(
                    children: [
                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      else if (_videoController != null)
                        Positioned.fill(
                          child: Video(
                            controller: _videoController!,
                            controls: null,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        const Center(
                          child: Text(
                            "Error loading video",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),

                      /// 🎛 Controls Overlay (Animated Left/Right)
                      if (_player != null && _showControls)
                         AnimatedPositioned(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                          bottom: 0,
                          // If Right Aligned: Right=0, Left=null. Else: Left=0, Right=null
                          // But we want it to span width, so we control content alignment instead
                          left: 0,
                          right: 0, 
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _isContentVisible ? 1.0 : 0.0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 20,
                                horizontal: _isFullScreen ? 50 : 30
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.9),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                // Align children based on flip state
                                crossAxisAlignment: _isControlsRightAligned 
                                    ? CrossAxisAlignment.end 
                                    : CrossAxisAlignment.start,
                                children: [
                                  // 1. Slider (Progress Bar)
                                  StreamBuilder<Duration>(
                                    stream: _player!.stream.position,
                                    builder: (context, snapshot) {
                                      final position = snapshot.data ?? Duration.zero;
                                      final duration = _player!.state.duration;
                                      final progress = duration.inMilliseconds == 0
                                          ? 0.0
                                          : position.inMilliseconds / duration.inMilliseconds;

                                      return SizedBox(
                                        // Limit width if we want side-specific look, or keep full width
                                        width: size.width, 
                                        child: Column(
                                          children: [
                                            SliderTheme(
                                              data: SliderTheme.of(context).copyWith(
                                                trackHeight: 4,
                                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                              ),
                                              child: Slider(
                                                value: progress.clamp(0.0, 1.0),
                                                onChanged: (value) async {
                                                  final seekPos = Duration(
                                                      milliseconds: (duration.inMilliseconds * value).toInt());
                                                  await _player!.seek(seekPos);
                                                },
                                                activeColor: Colors.white,
                                                inactiveColor: Colors.white24,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 5),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    _formatDuration(position),
                                                    style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12),
                                                  ),
                                                  Text(
                                                    _formatDuration(duration),
                                                    style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 15),

                                  // 2. Control Buttons Row
                                  // We use MainAxisAlignment based on flip state
                                  Row(
                                    mainAxisAlignment: _isControlsRightAligned 
                                        ? MainAxisAlignment.end 
                                        : MainAxisAlignment.start,
                                    children: [
                                      // Skip Back
                                      _controlButton(Icons.replay_10_rounded, _seekBackward),
                                      const SizedBox(width: 15),

                                      // Play/Pause
                                      GestureDetector(
                                        onTap: () {
                                          _onUserInteraction();
                                          _togglePlayPause();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.white.withOpacity(0.3),
                                                blurRadius: 20,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            _player!.state.playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                            color: Colors.black,
                                            size: 32,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 15),
                                      // Skip Forward
                                      _controlButton(Icons.forward_10_rounded, _seekForward),

                                      // Divider
                                      Container(
                                        height: 30,
                                        width: 1, 
                                        color: Colors.white24,
                                        margin: const EdgeInsets.symmetric(horizontal: 20)
                                      ),

                                      // Flip Layout Button
                                      _controlButton(Icons.swap_horiz_rounded, _handleFlip),
                                      const SizedBox(width: 15),

                                      // Fullscreen Button
                                      _controlButton(
                                        _isFullScreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded, 
                                        _toggleFullScreen
                                      ),
                                      const SizedBox(width: 15),

                                      // Close Button (Exit)
                                      _controlButton(Icons.close_rounded, () => Navigator.pop(context), isDestructive: true),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlButton(IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return GestureDetector(
      onTap: () {
        _onUserInteraction();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // If destructive (Close), use a slight red tint, else white glass
          color: isDestructive ? Colors.red.withOpacity(0.2) : Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDestructive ? Colors.red.withOpacity(0.3) : Colors.white.withOpacity(0.1)
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
    } else {
      return "${twoDigits(minutes)}:${twoDigits(seconds)}";
    }
  }
}

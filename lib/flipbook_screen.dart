import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlipbookPage extends StatefulWidget {
  const FlipbookPage({super.key});

  @override
  State<FlipbookPage> createState() => _FlipbookPageState();
}

class _FlipbookPageState extends State<FlipbookPage> {
  HttpServer? _server;
  int? _localPort;
  bool _serverReady = false;

  late InAppWebViewController _webController;

  /// toggle button position
  bool isRight = false;
  WebViewEnvironment? _webViewEnvironment; // To store custom environment

  @override
  void initState() {
    super.initState();
    _loadFlipAlignment();
    _initEverything();
  }

  Future<void> _initEverything() async {
    // 1. Fix for Windows "Program Files" permission issue
    if (Platform.isWindows) {
      try {
        final supportDir = await getApplicationSupportDirectory();
        final webViewDataDir = Directory(p.join(supportDir.path, 'webview_data'));
        
        // Ensure directory exists
        if (!await webViewDataDir.exists()) {
          await webViewDataDir.create(recursive: true);
        }

        // Initialize WebView Environment with writeable user data folder
        _webViewEnvironment = await WebViewEnvironment.create(
          settings: WebViewEnvironmentSettings(userDataFolder: webViewDataDir.path)
        );
      } catch (e) {
        debugPrint('WebView Environment Init Error: $e');
      }
    }

    // 2. Start Server
    await _initServer();
  }

  Future<void> _loadFlipAlignment() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool('flipbook_flip_right_aligned');
    if (!mounted) return;
    setState(() => isRight = saved ?? false);
  }

  Future<void> _saveFlipAlignment() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('flipbook_flip_right_aligned', isRight);
  }

  @override
  void dispose() {
    _server?.close(force: true);
    super.dispose();
  }

  Future<void> _initServer() async {
    try {
      final docDir = await getApplicationSupportDirectory();
      final wwwDir = Directory(p.join(docDir.path, 'www'));

      // Always refresh assets to ensure latest changes are reflected
      if (true) {
        if (await wwwDir.exists()) {
          await wwwDir.delete(recursive: true);
        }
        await wwwDir.create(recursive: true);

      /// Copy assets/www → local www folder
      final manifestContent =
          await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap =
          json.decode(manifestContent);

      final wwwAssets = manifestMap.keys
          .where((key) => key.startsWith('assets/www/'))
          .toList();

      for (final assetPath in wwwAssets) {
        final data = await rootBundle.load(assetPath);
        final bytes = data.buffer.asUint8List();
        final relativePath =
            assetPath.substring('assets/www/'.length);
        final file = File(p.join(wwwDir.path, relativePath));
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes);
      }
      } // End of Optimization IF block

      final handler = createStaticHandler(
        wwwDir.path,
        defaultDocument: 'index.html',
      );

      _server = await shelf_io.serve(handler, 'localhost', 0);
      _localPort = _server!.port;

      if (mounted) {
        setState(() => _serverReady = true);
      }
    } catch (e) {
      debugPrint('Server init error: $e');
    }
  }

  /// TOGGLE BUTTON SIDE (NO PAGE CHANGE)
  void _flipAndToggle() async {
    setState(() {
      isRight = !isRight;
    });
    await _saveFlipAlignment();
  }

  /// NAVIGATE TO NEXT PAGE
  void _goToNextPage() {
    _webController.evaluateJavascript(
      source: r"try{ $('.magazine').turn('next'); }catch(e){}",
    );
  }

  /// NAVIGATE TO PREVIOUS PAGE
  void _goToPreviousPage() {
    _webController.evaluateJavascript(
      source: r"try{ $('.magazine').turn('previous'); }catch(e){}",
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_serverReady || _localPort == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// WEBVIEW
          InAppWebView(
            webViewEnvironment: _webViewEnvironment, // Pass custom environment
            initialUrlRequest: URLRequest(
              url: WebUri('http://localhost:$_localPort/index.html'),
            ),
            onWebViewCreated: (controller) {
              _webController = controller;
            },
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              useWideViewPort: true,
              loadWithOverviewMode: true,
              transparentBackground: true,
            ),
          ),

          /// BUTTON GROUP (BOTTOM LEFT / RIGHT)
          Positioned(
            bottom: 20,
            left: isRight ? null : 20,
            right: isRight ? 20 : null,
            child: Row(
              children: [
                /// BACK BUTTON
                _circleButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),

                const SizedBox(width: 12),

                /// PREVIOUS BUTTON
                _circleButton(
                  icon: Icons.chevron_left,
                  onTap: _goToPreviousPage,
                ),

                const SizedBox(width: 12),

                /// NEXT BUTTON
                _circleButton(
                  icon: Icons.chevron_right,
                  onTap: _goToNextPage,
                ),

                const SizedBox(width: 12),

                /// FLIP BUTTON
                _circleButton(
                  icon: Icons.flip,
                  onTap: _flipAndToggle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// CIRCULAR ICON BUTTON (50% RADIUS)
  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle, // 🔴 perfect 50%
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
            )
          ],
        ),
        child: Icon(
          icon,
          color: Colors.black,
        ),
      ),
    );
  }
}

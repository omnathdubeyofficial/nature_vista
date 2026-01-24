import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart'; // ✅ REQUIRED
import 'package:nature_vista/home.dart';

import 'location.dart';
import 'gallery.dart';
import 'amenities.dart';
import 'plans.dart';
import 'view.dart';
import 'walkthrough.dart';
import 'flipbook_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized(); // 🔥 REQUIRED FOR WINDOWS
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nature Vista',
      home: const HomePage(),
      routes: {
        '/location': (_) => const LocationPage(),
        '/gallery': (_) => const GalleryPage(),
        '/amenities': (_) => const AmenitiesPage(),
        '/plans': (_) => const PlansPage(),
        '/views': (_) => const ViewPage(),
        '/walkthrough': (_) => const WalkthroughPage(),
        '/flipbook': (_) => const FlipbookPage(),
      },
    );
  }
}

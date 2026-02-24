import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart'; // ✅ REQUIRED
import 'package:nature_vista/home.dart';

import 'location.dart';
import 'gallery.dart';
import 'amenities.dart';
import 'plans_selection.dart';
import 'plans.dart';
import 'view.dart';
import 'walkthrough.dart';
import 'flipbook_screen.dart';
import 'tour_video_page.dart';
import 'package:nature_vista/master_layout_page.dart';
import 'package:nature_vista/sector_layout_page.dart';
import 'package:nature_vista/building_1_page.dart';
import 'package:nature_vista/building_2_page.dart';

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
        '/plans': (_) => const PlansSelectionPage(),
        '/plans_internal': (_) => const PlansPage(),
        '/views': (_) => const ViewPage(),
        '/walkthrough': (_) => const TourVideoPage(),
        '/walkthrough_internal': (_) => const WalkthroughPage(),
        '/flipbook': (_) => const FlipbookPage(),
        '/master_layout': (_) => const MasterLayoutPage(),
        '/sector_layout': (_) => const SectorLayoutPage(),
        '/building_1': (_) => const Building1Page(),
        '/building_2': (_) => const Building2Page(),
      },
    );
  }
}

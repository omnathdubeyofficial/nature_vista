import 'package:flutter/material.dart';
import 'area_detail_page.dart';

class LayoutPage extends StatefulWidget {
  const LayoutPage({Key? key}) : super(key: key);

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {
  String? _selectedArea;

  void _navigateToArea(String areaName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AreaDetailPage(areaName: areaName),
      ),
    );
  }

  Widget _buildHotspot({
    required double top,
    required double left,
    required double width,
    required double height,
    required String label,
    required Color color,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () => _navigateToArea(label),
        onTapDown: (_) => setState(() => _selectedArea = label),
        onTapUp: (_) => setState(() => _selectedArea = null),
        onTapCancel: () => setState(() => _selectedArea = null),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: _selectedArea == label
                ? color.withOpacity(0.5)
                : color.withOpacity(0.2),
            border: Border.all(
              color: color,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nature Vista Layout',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive coordinates based on screen size
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            minScale: 1.0,
            maxScale: 4.0,
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                children: [
                  /// Main Layout Image
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/layout.jpg',
                      fit: BoxFit.contain,
                    ),
                  ),

                  /// Hotspots - Responsive coordinates
                  
                  // Swimming Pool (Top Center-Left)
                  _buildHotspot(
                    top: height * 0.12,
                    left: width * 0.25,
                    width: width * 0.15,
                    height: height * 0.12,
                    label: 'Swimming Pool',
                    color: Colors.blue,
                  ),

                  // Basketball Court (Top Right)
                  _buildHotspot(
                    top: height * 0.10,
                    left: width * 0.52,
                    width: width * 0.12,
                    height: height * 0.14,
                    label: 'Basketball',
                    color: Colors.orange,
                  ),

                  // Tennis Courts (Top Far Right)
                  _buildHotspot(
                    top: height * 0.10,
                    left: width * 0.66,
                    width: width * 0.15,
                    height: height * 0.14,
                    label: 'Tennis Courts',
                    color: Colors.green,
                  ),

                  // Central Garden (Center)
                  _buildHotspot(
                    top: height * 0.35,
                    left: width * 0.32,
                    width: width * 0.20,
                    height: height * 0.20,
                    label: 'Central Garden',
                    color: Colors.lightGreen,
                  ),

                  // Yoga Lawn (Right Side)
                  _buildHotspot(
                    top: height * 0.40,
                    left: width * 0.70,
                    width: width * 0.15,
                    height: height * 0.15,
                    label: 'Yoga Lawn',
                    color: Colors.teal,
                  ),

                  // Kids Play Area (Bottom Center-Right)
                  _buildHotspot(
                    top: height * 0.62,
                    left: width * 0.42,
                    width: width * 0.12,
                    height: height * 0.10,
                    label: 'Kids Zone',
                    color: Colors.pink,
                  ),

                  // Jogging Track (Left Side)
                  _buildHotspot(
                    top: height * 0.50,
                    left: width * 0.08,
                    width: width * 0.10,
                    height: height * 0.15,
                    label: 'Jogging Track',
                    color: Colors.purple,
                  ),

                  // Building Complex (Bottom)
                  _buildHotspot(
                    top: height * 0.75,
                    left: width * 0.25,
                    width: width * 0.30,
                    height: height * 0.12,
                    label: 'Main Building',
                    color: Colors.red,
                  ),

                  // Parking Area (Bottom Left)
                  _buildHotspot(
                    top: height * 0.78,
                    left: width * 0.08,
                    width: width * 0.12,
                    height: height * 0.10,
                    label: 'Parking',
                    color: Colors.amber,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

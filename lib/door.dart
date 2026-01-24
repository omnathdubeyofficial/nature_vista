import 'package:flutter/material.dart';

class DoorPage extends StatefulWidget {
  const DoorPage({Key? key}) : super(key: key);

  @override
  State<DoorPage> createState() => _DoorPageState();
}

class _DoorPageState extends State<DoorPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _closePage() {
    _fadeController.reverse().then((_) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// Door/Building Image
          Positioned.fill(
            child: FadeTransition(
              opacity: CurvedAnimation(
                  parent: _fadeController, curve: Curves.easeInOut),
              child: InteractiveViewer(
                panEnabled: true,
                scaleEnabled: true,
                minScale: 1.0,
                maxScale: 4.0,
                child: Image.asset(
                  'assets/images/door.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          /// Close Button
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: _closePage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

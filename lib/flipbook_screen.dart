import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfrx/pdfrx.dart';

class FlipbookPage extends StatefulWidget {
  const FlipbookPage({super.key});

  @override
  State<FlipbookPage> createState() => _FlipbookPageState();
}

class _FlipbookPageState extends State<FlipbookPage> with SingleTickerProviderStateMixin {
  final PdfViewerController _controller = PdfViewerController();
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isSwapped = false;
  bool _isFading = false;
  double _controlsOpacity = 1.0;

  late AnimationController _swapController;
  late Animation<double> _swapAnimation;

  final String _pdfPath = 'assets/pdf/E-BROCHURE-AYODHYA CITY at NATURE VISTA_260211_181058_compressed (1).pdf';

  @override
  void initState() {
    super.initState();
    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _swapAnimation = CurvedAnimation(
      parent: _swapController,
      curve: Curves.easeInOutBack,
    );
  }

  @override
  void dispose() {
    _swapController.dispose();
    super.dispose();
  }

  void _toggleSwap() async {
    // START FADE OUT
    setState(() {
      _controlsOpacity = 0.0;
      _isFading = true;
    });

    // Wait for fade out to complete fully
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _isSwapped = !_isSwapped;
      if (_isSwapped) {
        _swapController.forward();
      } else {
        _swapController.reverse();
      }
    });

    // Let layout settle
    await Future.delayed(const Duration(milliseconds: 100));

    // START FADE IN
    setState(() {
      _controlsOpacity = 1.0;
      _isFading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          // 📖 MAIN PDF VIEWER
          Positioned.fill(
            child: PdfViewer.asset(
              _pdfPath,
              controller: _controller,
              params: PdfViewerParams(
                maxScale: 10.0,
                onPageChanged: (pageNumber) {
                  if (pageNumber != null) {
                    setState(() => _currentPage = pageNumber);
                  }
                },
                onDocumentChanged: (document) {
                  setState(() => _totalPages = document?.pages.length ?? 0);
                },
                backgroundColor: const Color(0xFFF5F5F7),
              ),
            ),
          ),

          // 🎚️ BOTTOM INTEGRATED CONTROL SYSTEM
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _controlsOpacity,
              child: _buildIntegratedBottomBar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegratedBottomBar() {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _swapAnimation,
      builder: (context, child) {
        return Container(
          width: size.width - 40,
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // CONTROLS + PAGE INDICATORS GRID
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                           // THE CONTROL GROUP: [BACK, SWAP, PREV, NEXT]
                           _animatedPositionedElement(
                             index: 0,
                             child: _navIconButton(Icons.arrow_back_rounded, () => Navigator.pop(context), "Go Back"),
                           ),
                           _animatedPositionedElement(
                             index: 1,
                             child: _navIconButton(Icons.swap_horiz_rounded, _toggleSwap, "Swap Side"),
                           ),
                           _animatedPositionedElement(
                             index: 2,
                             child: _navIconButton(Icons.chevron_left_rounded, () => _controller.goToPage(pageNumber: _currentPage - 1), "Previous"),
                           ),
                           _animatedPositionedElement(
                             index: 3,
                             child: _navIconButton(Icons.chevron_right_rounded, () => _controller.goToPage(pageNumber: _currentPage + 1), "Next"),
                           ),

                           // THE PAGE NUMBERS GROUP (Mini Circles)
                           _animatedPositionedPageIndicators(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _animatedPositionedElement({required int index, required Widget child}) {
    final double buttonWidth = 50.0;
    final double spacing = 10.0;
    final double totalBarWidth = MediaQuery.of(context).size.width - 70; // Inner width (minus horizontal padding)
    
    // Left-aligned: 0, 60, 120, 180
    // Right-aligned: totalBarWidth - (4-index)*60
    final double leftPos = _isSwapped 
        ? (totalBarWidth - (4 - index) * (buttonWidth + spacing)) 
        : index * (buttonWidth + spacing);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 10),
      curve: Curves.linear,
      left: leftPos,
      top: 10,
      child: child,
    );
  }

  Widget _animatedPositionedPageIndicators() {
    final double buttonWidth = 50.0;
    final double spacing = 10.0;
    final double totalBarWidth = MediaQuery.of(context).size.width - 70;
    
    // Page indicators start after the 4 buttons OR end before them
    final double leftPos = _isSwapped 
        ? 0 
        : 250; // 4 buttons * 60 + a bit extra

    final double rightPos = _isSwapped
        ? 250
        : 0;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 10),
      curve: Curves.linear,
      left: leftPos,
      right: rightPos,
      top: 10,
      bottom: 10,
      child: Container(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _totalPages,
          itemBuilder: (context, index) {
            final pageNum = index + 1;
            final isCurrent = pageNum == _currentPage;
            return GestureDetector(
              onTap: () => _controller.goToPage(pageNumber: pageNum),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 35,
                height: 35,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isCurrent ? const Color(0xFFFF9100) : Colors.grey.shade100,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCurrent ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$pageNum',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _navIconButton(IconData icon, VoidCallback onTap, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFFF9100).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFFE65100), size: 28),
        ),
      ),
    );
  }
}

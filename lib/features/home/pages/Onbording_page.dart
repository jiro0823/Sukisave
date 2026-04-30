import 'package:flutter/material.dart';
import 'package:sukisave/features/auth/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<_OnboardingContent> _pages = const [
    // FIRST PAGE (IMAGE ONLY)
    _OnboardingContent(
      imagePath: 'assets/images/onboarding/onboarding_logo.png',
      title: '',
      body: '',
    ),

    // SECOND PAGE (DESIGN MATCH)
    _OnboardingContent(
      imagePath: 'assets/images/onboarding/onboarding01_logo.png',
      title: 'Bawas Tapon,\nDagdag Kita.',
      body:
          'Every meal deserves a table. SukiSave helps vendors sell extra food '
          'while customers discover delicious meals at better prices.',
    ),

    // THIRD PAGE (SAME STYLE)
    _OnboardingContent(
      imagePath: 'assets/images/onboarding/onboarding01_logo.png',
      title: 'Save. Share. Suki.',
      body:
          'A smart platform where surplus food, excess ingredients, and safe '
          'near-expiry items are exchanged instead of wasted. It also connects '
          'users to essential vendor supplies like utensils and packaging, '
          'keeping resources in circulation while supporting local sellers and '
          'building a more sustainable community.',
      useGridTop: true,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentIndex < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
      return;
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    final bool isGridPage = _currentIndex == _pages.length - 1;
    return Scaffold(
      backgroundColor: isGridPage ? Colors.white : const Color(0xFF0F5513),
      body: SafeArea(
        child: PageView.builder(
          controller: _controller,
          itemCount: _pages.length,
          physics: _currentIndex == 0
              ? const PageScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            // FIRST PAGE (IMAGE ONLY)
            if (index == 0) {
              return _FirstOnboardingSlide(imagePath: _pages[index].imagePath);
            }

            // SECOND & THIRD PAGE (STYLED)
            return _StyledOnboardingSlide(
              content: _pages[index],
              currentIndex: _currentIndex,
              total: _pages.length,
              onNext: _goNext,
              isLast: index == _pages.length - 1,
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingContent {
  final String imagePath;
  final String title;
  final String body;
  final bool useGridTop;

  const _OnboardingContent({
    required this.imagePath,
    required this.title,
    required this.body,
    this.useGridTop = false,
  });
}

// ================= FIRST PAGE =================

class _FirstOnboardingSlide extends StatelessWidget {
  final String imagePath;

  const _FirstOnboardingSlide({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(imagePath, width: 260, fit: BoxFit.contain),
    );
  }
}

class _AsymGridLayout extends StatelessWidget {
  const _AsymGridLayout();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = 8;
        const double baseSmallW = 125;
        const double baseSmallH = 104;
        const double baseCenterW = 150;
        const double baseCenterH = 140;
        final double maxRowWidth =
            baseSmallW + baseCenterW + baseSmallW + spacing * 2;
        final double scale = (constraints.maxWidth / maxRowWidth).clamp(
          0.0,
          1.0,
        );
        final double smallW = baseSmallW * scale;
        final double smallH = baseSmallH * scale;
        final double centerW = baseCenterW * scale;
        final double centerH = baseCenterH * scale;

        Widget tile(double width, double height) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF),
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                tile(smallW, smallH),
                const SizedBox(height: 8),
                tile(smallW, smallH),
                const SizedBox(height: 8),
                tile(smallW, smallH),
              ],
            ),
            Column(
              children: [
                tile(centerW, centerH),
                const SizedBox(height: 8),
                tile(centerW, centerH),
                const SizedBox(height: 8),
                tile(centerW, centerH),
              ],
            ),
            Column(
              children: [
                tile(smallW, smallH),
                const SizedBox(height: 8),
                tile(smallW, smallH),
                const SizedBox(height: 8),
                tile(smallW, smallH),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ================= STYLED PAGES =================

class _StyledOnboardingSlide extends StatelessWidget {
  final _OnboardingContent content;
  final int currentIndex;
  final int total;
  final VoidCallback onNext;
  final bool isLast;

  const _StyledOnboardingSlide({
    required this.content,
    required this.currentIndex,
    required this.total,
    required this.onNext,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSecondImage =
        content.imagePath == 'assets/images/onboarding/onboarding01_logo.png';
    final bool isThirdPanel = content.useGridTop;
    return Stack(
      children: [
        // TOP IMAGE
        Column(
          children: [
            SizedBox(height: isSecondImage ? 6 : 20),
            if (content.useGridTop)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: _AsymGridLayout(),
              )
            else
              Image.asset(
                content.imagePath,
                width: double.infinity,
                height: isSecondImage ? 420 : 380,
                fit: BoxFit.cover,
              ),
          ],
        ),

        // WHITE PANEL
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            decoration: BoxDecoration(
              color: isThirdPanel ? const Color(0xFF0F5513) : Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(isThirdPanel ? 60 : 40),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TITLE
                Text(
                  content.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isThirdPanel
                        ? Colors.white
                        : const Color(0xFF0F5513),
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                  ),
                ),

                const SizedBox(height: 12),

                // BODY
                Text(
                  content.body,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Geist',
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: isThirdPanel
                        ? const Color(0xFFF0F2F0)
                        : const Color(0xFF555555),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                // DOT INDICATOR
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    total,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: currentIndex == index ? 14 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: currentIndex == index
                            ? (isThirdPanel
                                  ? Colors.white
                                  : const Color(0xFF0F5513))
                            : (isThirdPanel
                                  ? Colors.white.withValues(alpha: 0.5)
                                  : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isThirdPanel
                          ? Colors.white
                          : const Color(0xFF0F5513),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      isLast ? 'Get Started' : 'Next',
                      style: TextStyle(
                        fontSize: 16,
                        color: isThirdPanel
                            ? const Color(0xFF0F5513)
                            : const Color(0xFFF0F2F0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
